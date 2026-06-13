import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_link_manager/app/app.dart';
import 'package:nfc_link_manager/app/router.dart';
import 'package:nfc_link_manager/core/utils/ndef_size_calculator.dart';
import 'package:nfc_link_manager/core/utils/url_normalizer.dart';
import 'package:nfc_link_manager/features/link_writer/link_writer_state.dart';
import 'package:nfc_link_manager/features/link_writer/models/link_type.dart';
import 'package:nfc_link_manager/features/link_writer/models/nfc_error.dart';
import 'package:nfc_link_manager/features/link_writer/models/nfc_read_result.dart';
import 'package:nfc_link_manager/features/link_writer/models/nfc_tag_info.dart';
import 'package:nfc_link_manager/features/link_writer/models/nfc_write_result.dart';
import 'package:nfc_link_manager/features/link_writer/services/nfc_service.dart';
import 'package:nfc_link_manager/features/link_writer/services/recent_url_store.dart';
import 'package:nfc_link_manager/features/link_writer/widgets/nfc_status_widgets.dart';
import 'package:nfc_link_manager/features/link_writer/models/url_draft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('normalizes Instagram username', () {
    expect(
      UrlNormalizer.normalizeInstagramUsername(' @romrom_official '),
      'https://instagram.com/romrom_official',
    );
    expect(
      UrlNormalizer.normalizeInstagramUsername(
        'https://www.instagram.com/romrom.official/?hl=ko',
      ),
      'https://instagram.com/romrom.official',
    );
    expect(UrlNormalizer.normalizeInstagramUsername('@'), isNull);
    expect(UrlNormalizer.normalizeInstagramUsername('romrom official'), isNull);
    expect(UrlNormalizer.normalizeInstagramUsername('romrom!'), isNull);
  });

  test('normalizes full URL and removes tracking parameters', () {
    final normalized = UrlNormalizer.normalizeFullUrl(
      'github.com/romrom?utm_source=ig&id=123&igsh=abc',
    );

    expect(
      normalized,
      'https://github.com/romrom?utm_source=ig&id=123&igsh=abc',
    );
    expect(
      UrlNormalizer.removeTrackingParams(normalized!),
      'https://github.com/romrom?id=123',
    );
    expect(
      UrlNormalizer.removeTrackingParams('https://github.com/romrom?q=%G1'),
      'https://github.com/romrom?q=%G1',
    );
    expect(
      UrlNormalizer.normalizeFullUrl('google.com:80/profile'),
      'https://google.com:80/profile',
    );
    expect(
      UrlNormalizer.normalizeFullUrl('localhost:8080'),
      'https://localhost:8080',
    );
    expect(UrlNormalizer.normalizeFullUrl('mailto:hello@example.com'), isNull);
    expect(UrlNormalizer.normalizeFullUrl('tel:1234'), isNull);
  });

  test('preserves duplicate query keys when removing tracking parameters', () {
    final cleaned = UrlNormalizer.removeTrackingParams(
      'https://example.com/profile?id=1&utm_source=ig&ref=home&id=2&utm_content=copy&utm_term=nfc&igsh=abc',
    );

    expect(cleaned, 'https://example.com/profile?id=1&ref=home&id=2');
    final queryParameters = Uri.parse(cleaned).queryParametersAll;
    expect(queryParameters['id'], ['1', '2']);
    expect(queryParameters['ref'], ['home']);
    expect(queryParameters.containsKey('utm_source'), isFalse);
    expect(queryParameters.containsKey('utm_content'), isFalse);
    expect(queryParameters.containsKey('utm_term'), isFalse);
    expect(queryParameters.containsKey('igsh'), isFalse);
  });

  test('rejects URL boundary cases before NFC write', () {
    expect(UrlNormalizer.normalizeFullUrl('example.com/%G1'), isNull);
    expect(UrlNormalizer.normalizeFullUrl('example.com/%0Aprofile'), isNull);
    expect(UrlNormalizer.normalizeFullUrl('example.com/a b'), isNull);
    expect(UrlNormalizer.normalizeFullUrl('example.com/\u0000profile'), isNull);

    final tooLongUrl =
        'https://example.com/${'a' * UrlNormalizer.maxUrlLength}';
    expect(UrlNormalizer.isValidHttpUrl(tooLongUrl), isFalse);
  });

  test('estimates NTAG213 URL capacity', () {
    expect(
      NdefSizeCalculator.canStoreInNtag213('https://github.com/romrom'),
      isTrue,
    );
    expect(
      NdefSizeCalculator.estimateUrlRecordBytes('https://github.com/romrom'),
      greaterThan(0),
    );
  });

  test('maps NFC error codes to user-friendly Korean messages', () {
    expect(NfcError.fromCode('unsupported').title, 'NFC 미지원');
    expect(NfcError.fromCode('read_only').actionLabel, '쓰기 가능한 태그 사용');
    expect(NfcError.fromCode('invalid_url').title, 'URL 확인 필요');
    expect(NfcError.fromCode('unsupported_uri').title, '지원하지 않는 URI');
    expect(NfcError.fromCode('session_in_progress').title, 'NFC 작업 진행 중');
    expect(NfcError.fromCode('unknown-code').title, '알 수 없는 오류');
  });

  test(
    'NfcService rejects invalid and oversized URLs before opening a session',
    () async {
      final manager = _HangingNfcManager();
      final service = NfcManagerNfcService(manager: manager);

      final invalidResult = await service.writeUrl('mailto:hello@example.com');
      expect(invalidResult.success, isFalse);
      expect(invalidResult.errorCode, NfcError.invalidUrl.code);

      final oversizedUrl = 'https://example.com/${'a' * 180}';
      final oversizedResult = await service.writeUrl(oversizedUrl);
      expect(oversizedResult.success, isFalse);
      expect(oversizedResult.errorCode, NfcError.capacityExceeded.code);
      expect(manager.startSessionCount, 0);
    },
  );

  test('NfcService blocks duplicate NFC sessions', () async {
    final manager = _HangingNfcManager();
    final service = NfcManagerNfcService(manager: manager);
    final firstRead = service.readTag();
    final firstReadExpectation = expectLater(
      firstRead,
      throwsA(
        isA<NfcException>().having(
          (error) => error.error.code,
          'code',
          NfcError.sessionCancelled.code,
        ),
      ),
    );

    await Future<void>.delayed(Duration.zero);

    await expectLater(
      service.checkTag(),
      throwsA(
        isA<NfcException>().having(
          (error) => error.error.code,
          'code',
          NfcError.sessionInProgress.code,
        ),
      ),
    );

    await service.stopSession();
    await firstReadExpectation;
    expect(manager.startSessionCount, 1);
  });

  test(
    'NfcService waits for pending session cleanup before next session',
    () async {
      final stopCompleter = Completer<void>();
      final manager = _HangingNfcManager(
        onStopSession: () => stopCompleter.future,
      );
      final service = NfcManagerNfcService(manager: manager);
      final firstRead = service.readTag();
      final firstReadExpectation = expectLater(
        firstRead,
        throwsA(
          isA<NfcException>().having(
            (error) => error.error.code,
            'code',
            NfcError.sessionCancelled.code,
          ),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      final stopFuture = service.stopSession();
      final secondRead = service.readTag();
      await Future<void>.delayed(Duration.zero);

      expect(manager.startSessionCount, 1);

      stopCompleter.complete();
      await stopFuture;
      await firstReadExpectation;
      await Future<void>.delayed(Duration.zero);

      expect(manager.startSessionCount, 2);

      final secondReadExpectation = expectLater(
        secondRead,
        throwsA(
          isA<NfcException>().having(
            (error) => error.error.code,
            'code',
            NfcError.sessionCancelled.code,
          ),
        ),
      );
      await service.stopSession();
      await secondReadExpectation;
    },
  );

  test('LinkWriterState stores and loads the recent URL', () async {
    final store = _MemoryRecentUrlStore(
      initialUrl: 'https://stored.example/profile',
    );
    final state = LinkWriterState(recentUrlStore: store);
    addTearDown(state.dispose);

    await state.loadRecentUrl();
    expect(state.recentUrl, 'https://stored.example/profile');

    state.setDraft(
      const UrlDraft(
        linkType: LinkType.custom,
        originalInput: 'example.com/new',
        normalizedUrl: 'https://example.com/new',
        estimatedBytes: 31,
        isValid: true,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(state.recentUrl, 'https://example.com/new');
    expect(store.savedUrl, 'https://example.com/new');

    await state.clearRecentUrl();
    expect(state.recentUrl, isNull);
    expect(store.cleared, isTrue);
  });

  testWidgets('masks raw NFC tag IDs in tag info UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NfcTagInfoCard(
            tagInfo: NfcTagInfo(
              tagId: 'FA:KE:00:01',
              ndefAvailable: true,
              isWritable: true,
              maxSize: 144,
              currentSize: 40,
              isReadOnly: false,
              tagType: 'Fake NDEF',
            ),
          ),
        ),
      ),
    );

    expect(find.text('FA:KE:00:01'), findsNothing);
    expect(find.text('보안상 숨김'), findsOneWidget);
  });

  testWidgets('route guard redirects NFC write without a valid draft', (
    WidgetTester tester,
  ) async {
    final linkWriterState = LinkWriterState(
      recentUrlStore: _MemoryRecentUrlStore(),
    );
    addTearDown(linkWriterState.dispose);

    await tester.pumpWidget(
      NfcLinkWriterApp(
        nfcService: _FakeNfcService(),
        linkWriterState: linkWriterState,
      ),
    );

    GoRouter.of(
      tester.element(find.text('NFC Link Manager')),
    ).go(AppRoutes.nfcWrite);
    await tester.pumpAndSettle();

    expect(find.text('링크 유형을 선택하세요'), findsOneWidget);
  });

  testWidgets('home lets the user clear the recent URL', (
    WidgetTester tester,
  ) async {
    final linkWriterState = LinkWriterState(
      recentUrlStore: _MemoryRecentUrlStore(
        initialUrl: 'https://stored.example/profile',
      ),
    );
    addTearDown(linkWriterState.dispose);

    await linkWriterState.loadRecentUrl();
    await tester.pumpWidget(
      NfcLinkWriterApp(
        nfcService: _FakeNfcService(),
        linkWriterState: linkWriterState,
      ),
    );

    expect(find.text('https://stored.example/profile'), findsOneWidget);
    await tester.tap(find.text('최근 URL 삭제'));
    await tester.pumpAndSettle();

    expect(find.text('https://stored.example/profile'), findsNothing);
    expect(linkWriterState.recentUrl, isNull);
  });

  testWidgets('creates an Instagram URL draft through the first flow', (
    WidgetTester tester,
  ) async {
    final linkWriterState = LinkWriterState(
      recentUrlStore: _MemoryRecentUrlStore(),
    );
    addTearDown(linkWriterState.dispose);

    await tester.pumpWidget(
      NfcLinkWriterApp(
        nfcService: _FakeNfcService(),
        linkWriterState: linkWriterState,
      ),
    );

    expect(find.text('NFC Link Manager'), findsOneWidget);
    expect(find.text('NFC 태그 만들기'), findsOneWidget);

    await tester.tap(find.text('NFC 태그 만들기'));
    await tester.pumpAndSettle();

    expect(find.text('링크 유형을 선택하세요'), findsOneWidget);

    await tester.tap(find.text('Instagram'));
    await tester.pumpAndSettle();

    expect(find.text('Instagram 계정명을 입력하세요'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '@romrom_official');
    await tester.pump();

    expect(find.text('https://instagram.com/romrom_official'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('저장할 링크를 확인하세요'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
    expect(find.text('https://instagram.com/romrom_official'), findsOneWidget);
    expect(find.text('저장 가능합니다'), findsOneWidget);

    await tester.tap(find.text('수정하기'));
    await tester.pumpAndSettle();

    expect(find.text('Instagram 계정명을 입력하세요'), findsOneWidget);
    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.controller.text, '@romrom_official');
  });

  testWidgets('routes NFC-only home actions to NFC screens', (
    WidgetTester tester,
  ) async {
    final linkWriterState = LinkWriterState(
      recentUrlStore: _MemoryRecentUrlStore(),
    );
    addTearDown(linkWriterState.dispose);

    await tester.pumpWidget(
      NfcLinkWriterApp(
        nfcService: _FakeNfcService(),
        linkWriterState: linkWriterState,
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NFC 태그 읽기'));
    await tester.pumpAndSettle();
    expect(find.text('NFC 태그 읽기'), findsOneWidget);
    expect(find.text('https://github.com/romrom'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('태그 상태 확인'));
    await tester.pumpAndSettle();
    expect(find.text('URL 저장에 적합합니다'), findsOneWidget);
  });

  testWidgets('shows an explicit error for unsupported NFC URI reads', (
    WidgetTester tester,
  ) async {
    final linkWriterState = LinkWriterState(
      recentUrlStore: _MemoryRecentUrlStore(),
    );
    addTearDown(linkWriterState.dispose);

    await tester.pumpWidget(
      NfcLinkWriterApp(
        nfcService: _UnsupportedUriNfcService(),
        linkWriterState: linkWriterState,
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NFC 태그 읽기'));
    await tester.pumpAndSettle();

    expect(find.text('지원하지 않는 URI'), findsOneWidget);
    expect(find.textContaining('http:// 또는 https:// URL만'), findsOneWidget);
  });
}

final class _MemoryRecentUrlStore implements RecentUrlStore {
  _MemoryRecentUrlStore({String? initialUrl}) : _currentUrl = initialUrl;

  String? _currentUrl;
  String? savedUrl;
  bool cleared = false;

  @override
  Future<String?> loadRecentUrl() async => _currentUrl;

  @override
  Future<void> saveRecentUrl(String url) async {
    _currentUrl = url;
    savedUrl = url;
  }

  @override
  Future<void> clearRecentUrl() async {
    cleared = true;
    _currentUrl = null;
    savedUrl = null;
  }
}

final class _HangingNfcManager implements NfcManager {
  _HangingNfcManager({this.onStopSession});

  final Future<void> Function()? onStopSession;
  int startSessionCount = 0;
  int stopSessionCount = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> startSession({
    required Set<NfcPollingOption> pollingOptions,
    required void Function(NfcTag) onDiscovered,
    String? alertMessageIos,
    bool invalidateAfterFirstReadIos = true,
    void Function(NfcReaderSessionErrorIos)? onSessionErrorIos,
    bool noPlatformSoundsAndroid = false,
  }) async {
    startSessionCount += 1;
  }

  @override
  Future<void> stopSession({
    String? alertMessageIos,
    String? errorMessageIos,
  }) async {
    stopSessionCount += 1;
    await onStopSession?.call();
  }
}

final class _FakeNfcService implements NfcService {
  static const _tagInfo = NfcTagInfo(
    tagId: 'FA:KE:00:01',
    ndefAvailable: true,
    isWritable: true,
    maxSize: 144,
    currentSize: 40,
    isReadOnly: false,
    tagType: 'Fake NDEF',
  );

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<NfcReadResult> readTag() async {
    return const NfcReadResult(
      url: 'https://github.com/romrom',
      tagInfo: _tagInfo,
    );
  }

  @override
  Future<NfcWriteResult> writeUrl(String url) async {
    return NfcWriteResult(success: true, url: url);
  }

  @override
  Future<NfcTagInfo> checkTag() async => _tagInfo;

  @override
  Future<void> stopSession() async {}
}

final class _UnsupportedUriNfcService implements NfcService {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<NfcReadResult> readTag() async {
    throw const NfcException(NfcError.unsupportedUri);
  }

  @override
  Future<NfcWriteResult> writeUrl(String url) async {
    return NfcWriteResult(success: true, url: url);
  }

  @override
  Future<NfcTagInfo> checkTag() async => _FakeNfcService._tagInfo;

  @override
  Future<void> stopSession() async {}
}

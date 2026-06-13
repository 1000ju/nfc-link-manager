import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_link_manager/app/app.dart';
import 'package:nfc_link_manager/core/utils/ndef_size_calculator.dart';
import 'package:nfc_link_manager/core/utils/url_normalizer.dart';

void main() {
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

  testWidgets('creates an Instagram URL draft through the first flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NfcLinkWriterApp());

    expect(find.text('NFC Link Writer'), findsOneWidget);
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

  testWidgets('shows pending message for NFC-only home action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NfcLinkWriterApp());

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('NFC 태그 읽기'));
    await tester.pump();
    expect(find.text('NFC 태그 읽기는 다음 작업에서 구현합니다.'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(find.text('태그 상태 확인'), findsOneWidget);
  });
}

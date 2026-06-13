import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

import '../../../core/utils/ndef_size_calculator.dart';
import '../../../core/utils/url_normalizer.dart';
import '../models/nfc_error.dart';
import '../models/nfc_read_result.dart';
import '../models/nfc_tag_info.dart';
import '../models/nfc_write_result.dart';

abstract interface class NfcService {
  Future<bool> isAvailable();

  Future<NfcReadResult> readTag();

  Future<NfcWriteResult> writeUrl(String url);

  Future<NfcTagInfo> checkTag();

  Future<void> stopSession();
}

final class NfcManagerNfcService implements NfcService {
  NfcManagerNfcService({NfcManager? manager}) : _manager = manager;

  static const _sessionTimeout = Duration(seconds: 30);
  static const _pollingOptions = {
    NfcPollingOption.iso14443,
    NfcPollingOption.iso15693,
  };
  static const _uriPrefixes = <int, String>{
    0x00: '',
    0x01: 'http://www.',
    0x02: 'https://www.',
    0x03: 'http://',
    0x04: 'https://',
    0x05: 'tel:',
    0x06: 'mailto:',
    0x07: 'ftp://anonymous:anonymous@',
    0x08: 'ftp://ftp.',
    0x09: 'ftps://',
    0x0A: 'sftp://',
    0x0B: 'smb://',
    0x0C: 'nfs://',
    0x0D: 'ftp://',
    0x0E: 'dav://',
    0x0F: 'news:',
    0x10: 'telnet://',
    0x11: 'imap:',
    0x12: 'rtsp://',
    0x13: 'urn:',
    0x14: 'pop:',
    0x15: 'sip:',
    0x16: 'sips:',
    0x17: 'tftp:',
    0x18: 'btspp://',
    0x19: 'btl2cap://',
    0x1A: 'btgoep://',
    0x1B: 'tcpobex://',
    0x1C: 'irdaobex://',
    0x1D: 'file://',
    0x1E: 'urn:epc:id:',
    0x1F: 'urn:epc:tag:',
    0x20: 'urn:epc:pat:',
    0x21: 'urn:epc:raw:',
    0x22: 'urn:epc:',
    0x23: 'urn:nfc:',
  };

  final NfcManager? _manager;
  Completer<Object?>? _activeSessionCompleter;
  Future<void> _sessionCleanup = Future<void>.value();

  NfcManager get _nfcManager => _manager ?? NfcManager.instance;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _nfcManager.isAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<NfcReadResult> readTag() async {
    return _runSession(
      alertMessageIos: 'NFC 태그를 가까이 대세요.',
      successMessageIos: '태그 읽기가 완료되었습니다.',
      onDiscovered: (tag) async {
        final tagInfo = await _readTagInfo(tag);
        if (!tagInfo.ndefAvailable) {
          throw const NfcException(NfcError.ndefUnsupported);
        }

        final message = await _readNdefMessage(tag);
        if (message == null) {
          throw const NfcException(NfcError.readFailed);
        }

        final url = _extractUrlFromMessage(message);
        if (url == null) {
          throw const NfcException(NfcError.readFailed);
        }
        if (!UrlNormalizer.isValidHttpUrl(url)) {
          throw const NfcException(NfcError.unsupportedUri);
        }

        return NfcReadResult(url: url, tagInfo: tagInfo);
      },
    );
  }

  @override
  Future<NfcWriteResult> writeUrl(String url) async {
    final validationError = _validateWritableUrl(url);
    if (validationError != null) {
      return NfcWriteResult(
        success: false,
        url: url,
        errorCode: validationError.code,
        errorMessage: validationError.description,
      );
    }

    try {
      return await _runSession(
        alertMessageIos: 'URL을 저장할 NFC 태그를 가까이 대세요.',
        successMessageIos: 'URL 저장이 완료되었습니다.',
        onDiscovered: (tag) async {
          final validationError = _validateWritableUrl(url);
          if (validationError != null) {
            throw NfcException(validationError);
          }

          final message = _createUriMessage(url);
          await _writeMessage(tag, message);
          return NfcWriteResult(success: true, url: url);
        },
      );
    } on NfcException catch (error) {
      return NfcWriteResult(
        success: false,
        url: url,
        errorCode: error.error.code,
        errorMessage: error.error.description,
      );
    }
  }

  @override
  Future<NfcTagInfo> checkTag() async {
    return _runSession(
      alertMessageIos: '상태를 확인할 NFC 태그를 가까이 대세요.',
      successMessageIos: '태그 상태 확인이 완료되었습니다.',
      onDiscovered: _readTagInfo,
    );
  }

  @override
  Future<void> stopSession() async {
    final activeSessionCompleter = _activeSessionCompleter;
    if (activeSessionCompleter != null && !activeSessionCompleter.isCompleted) {
      activeSessionCompleter.completeError(
        const NfcException(NfcError.sessionCancelled),
      );
    }
    _activeSessionCompleter = null;

    _sessionCleanup = _stopManagerSession();
    await _sessionCleanup;
  }

  Future<void> _stopManagerSession({
    String? alertMessageIos,
    String? errorMessageIos,
  }) async {
    try {
      await _nfcManager.stopSession(
        alertMessageIos: alertMessageIos,
        errorMessageIos: errorMessageIos,
      );
    } catch (_) {
      return;
    }
  }

  Future<T> _runSession<T>({
    required String alertMessageIos,
    required String successMessageIos,
    required Future<T> Function(NfcTag tag) onDiscovered,
  }) async {
    await _sessionCleanup;

    if (!await isAvailable()) {
      throw NfcException(_availabilityError);
    }
    if (_activeSessionCompleter != null) {
      throw const NfcException(NfcError.sessionInProgress);
    }

    final completer = Completer<Object?>();
    _activeSessionCompleter = completer;

    try {
      await _nfcManager.startSession(
        pollingOptions: _pollingOptions,
        alertMessageIos: alertMessageIos,
        invalidateAfterFirstReadIos: false,
        onSessionErrorIos: (error) {
          if (!completer.isCompleted) {
            completer.completeError(
              NfcException(NfcError.fromException(error.message)),
            );
          }
        },
        onDiscovered: (tag) {
          _handleDiscoveredTag(
            tag: tag,
            completer: completer,
            successMessageIos: successMessageIos,
            onDiscovered: onDiscovered,
          );
        },
      );

      final result = await completer.future.timeout(
        _sessionTimeout,
        onTimeout: () async {
          await _stopManagerSession();
          throw const NfcException(NfcError.tagNotDetected);
        },
      );
      return result as T;
    } on NfcException {
      rethrow;
    } catch (error) {
      throw NfcException(NfcError.fromException(error));
    } finally {
      if (identical(_activeSessionCompleter, completer)) {
        _activeSessionCompleter = null;
      }
    }
  }

  Future<void> _handleDiscoveredTag<T>({
    required NfcTag tag,
    required Completer<Object?> completer,
    required String successMessageIos,
    required Future<T> Function(NfcTag tag) onDiscovered,
  }) async {
    if (completer.isCompleted) {
      return;
    }

    try {
      final result = await onDiscovered(tag);
      await _stopManagerSession(alertMessageIos: successMessageIos);
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } on NfcException catch (error) {
      await _stopSessionWithError(error.error.description);
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    } catch (error) {
      final nfcError = NfcError.fromException(error);
      await _stopSessionWithError(nfcError.description);
      if (!completer.isCompleted) {
        completer.completeError(NfcException(nfcError));
      }
    }
  }

  Future<void> _stopSessionWithError(String message) async {
    await _stopManagerSession(errorMessageIos: message);
  }

  Future<NfcTagInfo> _readTagInfo(NfcTag tag) async {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _readAndroidTagInfo(tag),
      TargetPlatform.iOS => _readIosTagInfo(tag),
      _ => throw const NfcException(NfcError.unsupported),
    };
  }

  Future<NfcTagInfo> _readAndroidTagInfo(NfcTag tag) async {
    final androidTag = NfcTagAndroid.from(tag);
    final ndef = NdefAndroid.from(tag);

    if (ndef == null) {
      return NfcTagInfo(
        tagId: _formatAndroidTagId(androidTag),
        ndefAvailable: false,
        isWritable: false,
        maxSize: 0,
        currentSize: 0,
        isReadOnly: false,
        tagType: androidTag?.techList.join(', '),
      );
    }

    final currentMessage =
        ndef.cachedNdefMessage ?? await ndef.getNdefMessage();
    return NfcTagInfo(
      tagId: _formatAndroidTagId(androidTag),
      ndefAvailable: true,
      isWritable: ndef.isWritable,
      maxSize: ndef.maxSize,
      currentSize: currentMessage?.byteLength ?? 0,
      isReadOnly: !ndef.isWritable,
      tagType: ndef.type,
    );
  }

  Future<NfcTagInfo> _readIosTagInfo(NfcTag tag) async {
    final ndef = NdefIos.from(tag);

    if (ndef == null) {
      return const NfcTagInfo(
        tagId: 'iOS NFC 태그',
        ndefAvailable: false,
        isWritable: false,
        maxSize: 0,
        currentSize: 0,
        isReadOnly: false,
        tagType: 'iOS',
      );
    }

    final status = await ndef.queryNdefStatus();
    if (status.status == NdefStatusIos.notSupported) {
      return NfcTagInfo(
        tagId: 'iOS NFC 태그',
        ndefAvailable: false,
        isWritable: false,
        maxSize: status.capacity,
        currentSize: 0,
        isReadOnly: false,
        tagType: 'iOS',
      );
    }

    final currentMessage = ndef.cachedNdefMessage ?? await ndef.readNdef();
    final isWritable = status.status == NdefStatusIos.readWrite;

    return NfcTagInfo(
      tagId: 'iOS NFC 태그',
      ndefAvailable: status.status != NdefStatusIos.notSupported,
      isWritable: isWritable,
      maxSize: status.capacity,
      currentSize: currentMessage?.byteLength ?? 0,
      isReadOnly: status.status == NdefStatusIos.readOnly,
      tagType: 'iOS NDEF',
    );
  }

  Future<NdefMessage?> _readNdefMessage(NfcTag tag) async {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => NdefAndroid.from(tag)?.getNdefMessage(),
      TargetPlatform.iOS => _readIosNdefMessage(tag),
      _ => throw const NfcException(NfcError.unsupported),
    };
  }

  Future<NdefMessage?> _readIosNdefMessage(NfcTag tag) async {
    final ndef = NdefIos.from(tag);
    if (ndef == null) {
      return null;
    }

    final status = await ndef.queryNdefStatus();
    if (status.status == NdefStatusIos.notSupported) {
      throw const NfcException(NfcError.ndefUnsupported);
    }

    return ndef.readNdef();
  }

  Future<void> _writeMessage(NfcTag tag, NdefMessage message) async {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => _writeAndroidMessage(tag, message),
      TargetPlatform.iOS => _writeIosMessage(tag, message),
      _ => throw const NfcException(NfcError.unsupported),
    };
  }

  Future<void> _writeAndroidMessage(NfcTag tag, NdefMessage message) async {
    final ndef = NdefAndroid.from(tag);
    if (ndef == null) {
      throw const NfcException(NfcError.ndefUnsupported);
    }
    if (!ndef.isWritable) {
      throw const NfcException(NfcError.readOnly);
    }
    if (message.byteLength > ndef.maxSize) {
      throw const NfcException(NfcError.capacityExceeded);
    }

    try {
      await ndef.writeNdefMessage(message);
    } catch (error) {
      throw NfcException(NfcError.fromException(error));
    }
  }

  Future<void> _writeIosMessage(NfcTag tag, NdefMessage message) async {
    final ndef = NdefIos.from(tag);
    if (ndef == null) {
      throw const NfcException(NfcError.ndefUnsupported);
    }

    final status = await ndef.queryNdefStatus();
    if (status.status == NdefStatusIos.notSupported) {
      throw const NfcException(NfcError.ndefUnsupported);
    }
    if (status.status == NdefStatusIos.readOnly) {
      throw const NfcException(NfcError.readOnly);
    }
    if (message.byteLength > status.capacity) {
      throw const NfcException(NfcError.capacityExceeded);
    }

    try {
      await ndef.writeNdef(message);
    } catch (error) {
      throw NfcException(NfcError.fromException(error));
    }
  }

  NdefMessage _createUriMessage(String url) {
    return NdefMessage(records: [_createUriRecord(url)]);
  }

  NdefRecord _createUriRecord(String url) {
    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList('U'.codeUnits),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([0x00, ...utf8.encode(url)]),
    );
  }

  String? _extractUrlFromMessage(NdefMessage message) {
    for (final record in message.records) {
      final url = _extractUrlFromRecord(record);
      if (url != null) {
        return url;
      }
    }

    return null;
  }

  String? _extractUrlFromRecord(NdefRecord record) {
    if (record.typeNameFormat == TypeNameFormat.wellKnown &&
        _bytesToAscii(record.type) == 'U' &&
        record.payload.isNotEmpty) {
      final prefix = _uriPrefixes[record.payload.first] ?? '';
      final value = utf8.decode(record.payload.skip(1).toList());
      return '$prefix$value';
    }

    if (record.typeNameFormat == TypeNameFormat.absoluteUri &&
        record.type.isNotEmpty) {
      return utf8.decode(record.type);
    }

    return null;
  }

  String _bytesToAscii(Iterable<int> bytes) {
    return String.fromCharCodes(bytes);
  }

  NfcError? _validateWritableUrl(String url) {
    if (!UrlNormalizer.isValidHttpUrl(url)) {
      return NfcError.invalidUrl;
    }
    if (!NdefSizeCalculator.canStoreInNtag213(url)) {
      return NfcError.capacityExceeded;
    }

    return null;
  }

  String _formatAndroidTagId(NfcTagAndroid? _) {
    return 'Android NFC 태그';
  }

  NfcError get _availabilityError {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => NfcError.disabled,
      TargetPlatform.iOS => NfcError.unsupported,
      _ => NfcError.unsupported,
    };
  }
}

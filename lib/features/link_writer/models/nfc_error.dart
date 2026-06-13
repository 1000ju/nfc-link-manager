final class NfcError {
  const NfcError({
    required this.code,
    required this.title,
    required this.description,
    required this.actionLabel,
  });

  final String code;
  final String title;
  final String description;
  final String actionLabel;

  static const unsupported = NfcError(
    code: 'unsupported',
    title: 'NFC 미지원',
    description: '이 기기는 NFC 기능을 지원하지 않습니다.',
    actionLabel: 'NFC 지원 기기에서 다시 시도',
  );

  static const disabled = NfcError(
    code: 'disabled',
    title: 'NFC 꺼짐',
    description: 'NFC가 꺼져 있어 태그를 사용할 수 없습니다. 설정에서 NFC를 켜 주세요.',
    actionLabel: '설정 확인 후 다시 시도',
  );

  static const tagNotDetected = NfcError(
    code: 'tag_not_detected',
    title: '태그 미감지',
    description: 'NFC 태그를 찾지 못했습니다. 태그를 휴대폰 뒷면에 다시 가까이 대 주세요.',
    actionLabel: '다시 스캔',
  );

  static const ndefUnsupported = NfcError(
    code: 'ndef_unsupported',
    title: 'NDEF 미지원 태그',
    description: '이 태그는 URL 저장 형식을 지원하지 않습니다. 다른 NFC 태그를 사용해 주세요.',
    actionLabel: '다른 태그 사용',
  );

  static const readOnly = NfcError(
    code: 'read_only',
    title: '읽기 전용 태그',
    description: '이 태그는 읽기 전용이라 URL을 새로 저장할 수 없습니다.',
    actionLabel: '쓰기 가능한 태그 사용',
  );

  static const capacityExceeded = NfcError(
    code: 'capacity_exceeded',
    title: '용량 부족',
    description: 'URL이 태그 용량보다 커서 저장할 수 없습니다. URL을 줄이거나 추적 파라미터를 제거해 주세요.',
    actionLabel: 'URL 수정',
  );

  static const invalidUrl = NfcError(
    code: 'invalid_url',
    title: 'URL 확인 필요',
    description: 'NFC 태그에는 http:// 또는 https:// 형식의 안전한 URL만 저장할 수 있습니다.',
    actionLabel: 'URL 수정',
  );

  static const unsupportedUri = NfcError(
    code: 'unsupported_uri',
    title: '지원하지 않는 URI',
    description: '이 앱은 NFC 태그에서 읽은 http:// 또는 https:// URL만 후속 작업에 사용할 수 있습니다.',
    actionLabel: '다시 스캔',
  );

  static const sessionInProgress = NfcError(
    code: 'session_in_progress',
    title: 'NFC 작업 진행 중',
    description: '이미 진행 중인 NFC 작업이 있습니다. 잠시 후 다시 시도해 주세요.',
    actionLabel: '다시 시도',
  );

  static const writeFailed = NfcError(
    code: 'write_failed',
    title: '쓰기 실패',
    description: 'URL 저장에 실패했습니다. 태그 위치를 조정하거나 다른 태그로 다시 시도해 주세요.',
    actionLabel: '다시 시도',
  );

  static const readFailed = NfcError(
    code: 'read_failed',
    title: '읽기 실패',
    description: '태그 내용을 읽지 못했습니다. 태그를 다시 가까이 대 주세요.',
    actionLabel: '다시 스캔',
  );

  static const sessionCancelled = NfcError(
    code: 'session_cancelled',
    title: '세션 취소',
    description: 'NFC 작업이 취소되었습니다. 필요하면 다시 시작해 주세요.',
    actionLabel: '다시 시작',
  );

  static const unknown = NfcError(
    code: 'unknown',
    title: '알 수 없는 오류',
    description: '알 수 없는 문제가 발생했습니다. 다시 시도해 주세요.',
    actionLabel: '다시 시도',
  );

  static NfcError fromCode(String? code) {
    return switch (code) {
      'unsupported' => unsupported,
      'disabled' => disabled,
      'tag_not_detected' => tagNotDetected,
      'ndef_unsupported' => ndefUnsupported,
      'read_only' => readOnly,
      'capacity_exceeded' => capacityExceeded,
      'invalid_url' => invalidUrl,
      'unsupported_uri' => unsupportedUri,
      'session_in_progress' => sessionInProgress,
      'write_failed' => writeFailed,
      'read_failed' => readFailed,
      'session_cancelled' => sessionCancelled,
      _ => unknown,
    };
  }

  static NfcError fromException(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('disabled') || message.contains('enable')) {
      return disabled;
    }
    if (message.contains('cancel') || message.contains('invalidate')) {
      return sessionCancelled;
    }
    if (message.contains('readonly') || message.contains('read only')) {
      return readOnly;
    }
    if (message.contains('capacity') ||
        message.contains('size') ||
        message.contains('overflow')) {
      return capacityExceeded;
    }
    if (message.contains('read')) {
      return readFailed;
    }
    if (message.contains('write')) {
      return writeFailed;
    }

    return unknown;
  }
}

final class NfcException implements Exception {
  const NfcException(this.error);

  final NfcError error;

  @override
  String toString() => '${error.title}: ${error.description}';
}

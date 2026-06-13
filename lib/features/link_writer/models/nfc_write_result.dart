final class NfcWriteResult {
  const NfcWriteResult({
    required this.success,
    required this.url,
    this.errorCode,
    this.errorMessage,
  });

  final bool success;
  final String url;
  final String? errorCode;
  final String? errorMessage;
}

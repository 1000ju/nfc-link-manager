final class NfcVerifyResult {
  const NfcVerifyResult({
    required this.expectedUrl,
    required this.actualUrl,
    required this.isMatched,
  });

  final String expectedUrl;
  final String? actualUrl;
  final bool isMatched;
}

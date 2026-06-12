abstract interface class NfcWriter {
  String get availabilityLabel;

  Future<NfcWriteResult> writeLink(NfcWritePayload payload);
}

final class NfcWritePayload {
  const NfcWritePayload({required this.url, this.title});

  final Uri url;
  final String? title;
}

final class NfcWriteResult {
  const NfcWriteResult({required this.isSuccess, required this.message});

  final bool isSuccess;
  final String message;
}

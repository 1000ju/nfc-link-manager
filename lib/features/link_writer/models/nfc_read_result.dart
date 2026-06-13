import 'nfc_tag_info.dart';

final class NfcReadResult {
  const NfcReadResult({required this.url, required this.tagInfo});

  final String? url;
  final NfcTagInfo tagInfo;
}

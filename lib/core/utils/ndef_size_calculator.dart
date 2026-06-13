import 'dart:convert';

final class NdefSizeCalculator {
  const NdefSizeCalculator._();

  static const maxBytes = 144;
  static const _estimatedNdefHeaderBytes = 8;

  static int estimateUrlRecordBytes(String url) {
    return utf8.encode(url).length + _estimatedNdefHeaderBytes;
  }

  static bool canStoreInNtag213(String url) {
    return estimateUrlRecordBytes(url) <= maxBytes;
  }
}

final class NfcTagInfo {
  const NfcTagInfo({
    required this.tagId,
    required this.ndefAvailable,
    required this.isWritable,
    required this.maxSize,
    required this.currentSize,
    required this.isReadOnly,
    this.tagType,
  });

  final String tagId;
  final bool ndefAvailable;
  final bool isWritable;
  final int maxSize;
  final int currentSize;
  final bool isReadOnly;
  final String? tagType;

  String get displayTagId => tagId.isEmpty ? '숨김' : '보안상 숨김';

  bool get canStoreNtag213Url {
    return ndefAvailable && isWritable && !isReadOnly && maxSize >= 144;
  }
}

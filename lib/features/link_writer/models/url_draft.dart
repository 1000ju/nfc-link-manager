import 'link_type.dart';

final class UrlDraft {
  const UrlDraft({
    required this.linkType,
    required this.originalInput,
    required this.normalizedUrl,
    required this.estimatedBytes,
    required this.isValid,
  });

  final LinkType linkType;
  final String originalInput;
  final String normalizedUrl;
  final int estimatedBytes;
  final bool isValid;
}

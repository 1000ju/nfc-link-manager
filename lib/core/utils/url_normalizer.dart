final class UrlNormalizer {
  const UrlNormalizer._();

  static const _trackingParams = {
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'igsh',
  };

  static final _instagramUsernamePattern = RegExp(r'^[a-zA-Z0-9._]{1,30}$');
  static final _invalidPercentEncodingPattern = RegExp(r'%(?![0-9a-fA-F]{2})');

  static String? normalizeInstagramUsername(String input) {
    var username = input.trim();
    if (username.isEmpty) {
      return null;
    }

    username = _extractInstagramUsername(username) ?? username;
    username = username.replaceFirst(RegExp(r'^@+'), '');

    if (!_instagramUsernamePattern.hasMatch(username)) {
      return null;
    }

    final url = 'https://instagram.com/$username';
    return isValidHttpUrl(url) ? url : null;
  }

  static String? normalizeFullUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final hasAllowedScheme =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');
    final hasOtherScheme = RegExp(
      r'^[a-zA-Z][a-zA-Z0-9+.-]*:',
    ).hasMatch(trimmed);

    if (!hasAllowedScheme && hasOtherScheme) {
      return null;
    }

    final normalized = hasAllowedScheme ? trimmed : 'https://$trimmed';
    return isValidHttpUrl(normalized) ? normalized : null;
  }

  static String removeTrackingParams(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !isValidHttpUrl(url) ||
        _hasInvalidPercentEncoding(url)) {
      return url;
    }

    try {
      final nextQueryParameters = Map<String, String>.from(uri.queryParameters)
        ..removeWhere((key, value) => _trackingParams.contains(key));

      return uri
          .replace(
            queryParameters:
                nextQueryParameters.isEmpty ? null : nextQueryParameters,
          )
          .toString();
    } on FormatException {
      return url;
    }
  }

  static bool isValidHttpUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      return false;
    }

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    return isHttp && uri.host.isNotEmpty && !url.trim().contains(' ');
  }

  static String? _extractInstagramUsername(String input) {
    final normalizedInput =
        RegExp(r'^https?://', caseSensitive: false).hasMatch(input)
            ? input
            : 'https://$input';

    final uri = Uri.tryParse(normalizedInput);
    if (uri == null || !_isInstagramHost(uri.host)) {
      return null;
    }

    try {
      final pathSegments = uri.pathSegments
          .where((pathSegment) => pathSegment.isNotEmpty)
          .toList(growable: false);

      return pathSegments.length == 1 ? pathSegments.first : null;
    } on FormatException {
      return null;
    }
  }

  static bool _isInstagramHost(String host) {
    final normalizedHost = host.toLowerCase();
    return normalizedHost == 'instagram.com' ||
        normalizedHost == 'www.instagram.com';
  }

  static bool _hasInvalidPercentEncoding(String url) {
    return _invalidPercentEncodingPattern.hasMatch(url);
  }
}

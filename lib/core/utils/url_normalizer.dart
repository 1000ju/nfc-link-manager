final class UrlNormalizer {
  const UrlNormalizer._();

  static const maxUrlLength = 2048;

  static const _trackingParams = {
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'utm_content',
    'utm_term',
    'igsh',
  };

  static final _instagramUsernamePattern = RegExp(r'^[a-zA-Z0-9._]{1,30}$');
  static final _invalidPercentEncodingPattern = RegExp(r'%(?![0-9a-fA-F]{2})');
  static final _encodedControlCharacterPattern = RegExp(
    r'%(?:0[0-9a-fA-F]|1[0-9a-fA-F]|7[fF])',
  );
  static final _controlCharacterPattern = RegExp(r'[\x00-\x1F\x7F]');
  static final _whitespacePattern = RegExp(r'\s');

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

    if (_hasUnsupportedScheme(trimmed)) {
      return null;
    }

    final normalized =
        _hasAllowedScheme(trimmed) ? trimmed : 'https://$trimmed';
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
      final nextQuery = _removeTrackingParamsFromQuery(uri.query);

      return uri
          .replace(query: nextQuery.isEmpty ? null : nextQuery)
          .toString();
    } on FormatException {
      return url;
    }
  }

  static bool isValidHttpUrl(String url) {
    final trimmed = url.trim();
    if (url != trimmed ||
        trimmed.isEmpty ||
        trimmed.length > maxUrlLength ||
        _containsControlCharacters(trimmed) ||
        _hasInvalidPercentEncoding(trimmed) ||
        _hasEncodedControlCharacters(trimmed) ||
        _containsWhitespace(trimmed)) {
      return false;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return false;
    }

    final scheme = uri.scheme.toLowerCase();
    final isHttp = scheme == 'http' || scheme == 'https';
    return isHttp && uri.hasAuthority && uri.host.isNotEmpty;
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

  static bool _hasEncodedControlCharacters(String url) {
    return _encodedControlCharacterPattern.hasMatch(url);
  }

  static bool _containsControlCharacters(String url) {
    return _controlCharacterPattern.hasMatch(url);
  }

  static bool _containsWhitespace(String url) {
    return _whitespacePattern.hasMatch(url);
  }

  static String _removeTrackingParamsFromQuery(String query) {
    if (query.isEmpty) {
      return '';
    }

    final nextQueryComponents = <String>[];
    for (final queryComponent in query.split('&')) {
      final keyEnd = queryComponent.indexOf('=');
      final rawKey =
          keyEnd == -1 ? queryComponent : queryComponent.substring(0, keyEnd);
      final decodedKey = Uri.decodeQueryComponent(rawKey);
      if (!_trackingParams.contains(decodedKey)) {
        nextQueryComponents.add(queryComponent);
      }
    }

    return nextQueryComponents.join('&');
  }

  static bool _hasAllowedScheme(String input) {
    return RegExp(r'^https?://', caseSensitive: false).hasMatch(input);
  }

  static bool _hasUnsupportedScheme(String input) {
    if (_hasAllowedScheme(input)) {
      return false;
    }

    final schemeMatch = RegExp(
      r'^([a-zA-Z][a-zA-Z0-9+.-]*):',
    ).firstMatch(input);
    if (schemeMatch == null) {
      return false;
    }

    final schemeCandidate = schemeMatch.group(1)!;
    final remainingInput = input.substring(schemeMatch.end);
    return !_looksLikeHostPort(schemeCandidate, remainingInput);
  }

  static bool _looksLikeHostPort(String hostCandidate, String remainingInput) {
    final normalizedHost = hostCandidate.toLowerCase();
    final canBeHost =
        normalizedHost == 'localhost' || normalizedHost.contains('.');
    final hasPort = RegExp(r'^\d{1,5}($|[/?#])').hasMatch(remainingInput);

    return canBeHost && hasPort;
  }
}

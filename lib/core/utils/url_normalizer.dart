final class UrlNormalizer {
  const UrlNormalizer._();

  static const _trackingParams = {
    'utm_source',
    'utm_medium',
    'utm_campaign',
    'igsh',
  };

  static String? normalizeInstagramUsername(String input) {
    final username = input.trim().replaceFirst(RegExp(r'^@+'), '');
    if (username.isEmpty || RegExp(r'\s').hasMatch(username)) {
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
    if (uri == null || !isValidHttpUrl(url)) {
      return url;
    }

    final nextQueryParameters = Map<String, String>.from(uri.queryParameters)
      ..removeWhere((key, value) => _trackingParams.contains(key));

    return uri
        .replace(
          queryParameters:
              nextQueryParameters.isEmpty ? null : nextQueryParameters,
        )
        .toString();
  }

  static bool isValidHttpUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      return false;
    }

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    return isHttp && uri.host.isNotEmpty && !url.trim().contains(' ');
  }
}

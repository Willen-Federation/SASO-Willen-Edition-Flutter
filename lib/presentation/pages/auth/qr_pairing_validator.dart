/// Pure helpers used by [QrPairingPage] for validating QR payloads.
///
/// Extracted into a non-Flutter file so they can be unit-tested without
/// pulling in the entire widget tree.
library;

class QrPairingValidator {
  const QrPairingValidator._();

  /// Resolves the server URL the pairing call should target.
  ///
  /// Security contract — see HIGH-003 in the security audit:
  ///
  /// * The URL embedded in the QR is **not trusted**. It must either be
  ///   absent / empty, or match the user's already-configured server URL
  ///   exactly (after trim + lowercase + trailing-slash normalisation).
  /// * The resulting URL must use the `https` scheme.
  /// * If no server URL has been configured yet, scanning is refused — the
  ///   user must configure the server before pairing.
  ///
  /// Returns the resolved URL, or `null` if the scan must be rejected.
  static String? resolveServerUrl({
    required String? qrServerUrl,
    required String configuredUrl,
  }) {
    if (configuredUrl.isEmpty) return null;

    final qrHasUrl = qrServerUrl != null && qrServerUrl.isNotEmpty;
    if (qrHasUrl && _normalize(qrServerUrl) != _normalize(configuredUrl)) {
      return null;
    }

    final uri = Uri.tryParse(configuredUrl);
    if (uri == null || uri.scheme != 'https') return null;

    return configuredUrl;
  }

  static String _normalize(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u.toLowerCase();
  }
}

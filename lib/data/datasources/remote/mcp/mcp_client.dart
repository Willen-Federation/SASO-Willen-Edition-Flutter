import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/problem_details.dart';

/// JSON-RPC 2.0 error from the MCP server.
class McpError implements Exception {
  const McpError({required this.code, required this.message});
  final int code;
  final String message;
  @override
  String toString() => 'McpError($code): $message';
}

/// Lightweight JSON-RPC 2.0 client for the SASO MCP endpoint (POST /mcp).
///
/// Auth: Bearer JWT — same token as the REST API v1 client.
///
/// Usage:
///   final result = await client.callTool('search_items', {'query': 'jacket'});
///
/// Issue #20 — init race:
/// The MCP protocol requires an `initialize` handshake before any
/// `tools/call`. Previously `initialize()` was a public method that
/// callers were expected to invoke manually; in practice nobody did,
/// and any concurrent `callTool()` invocations could fire before the
/// handshake landed. The client now self-initializes lazily via an
/// idempotent [Future] latch (`_initFuture`):
///   * First `callTool` starts the handshake and stores the in-flight
///     [Future] in `_initFuture`.
///   * Concurrent `callTool` invocations await the same [Future] — no
///     duplicate handshakes hit the server.
///   * Successful resolution leaves the latch set; later calls
///     short-circuit through the resolved [Future].
///   * On failure the latch is cleared so the next call retries —
///     transient network errors don't permanently brick the client.
class McpClient {
  McpClient({
    required this.serverUrl,
    required this.jwtToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String serverUrl;
  final String jwtToken;
  final http.Client _http;

  int _nextId = 1;

  /// Init-latch: holds the in-flight or resolved initialize() future.
  /// Null means "not yet started" (or last attempt failed and was
  /// cleared). Reading/writing this field is single-threaded — Dart's
  /// event-loop concurrency model means we don't need a mutex.
  Future<void>? _initFuture;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Initialize the MCP session (protocol handshake). Idempotent —
  /// safe to call multiple times; only the first invocation hits the
  /// network. Concurrent calls share the same [Future] and complete
  /// together.
  ///
  /// Callers typically don't need to invoke this directly: [callTool]
  /// awaits it implicitly. Exposed for tests and for the rare case
  /// where a caller wants to surface init errors eagerly.
  Future<void> initialize() => _ensureInitialized();

  Future<void> _ensureInitialized() {
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    try {
      await _send('initialize', {
        'protocolVersion': '2024-11-05',
        'capabilities': <String, dynamic>{},
        'clientInfo': {
          'name': 'SASO-WILLEN Flutter',
          'version': AppConstants.version,
        },
      });
    } catch (_) {
      // Clear the latch so the next call retries. Without this a
      // transient 503 during startup would permanently wedge the
      // client.
      _initFuture = null;
      rethrow;
    }
  }

  /// Call a named MCP tool with [arguments] and return the raw result
  /// map. Lazily completes the init handshake on the first call.
  Future<Map<String, dynamic>> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    await _ensureInitialized();
    final result = await _send('tools/call', {
      'name': toolName,
      'arguments': arguments,
    });
    return result as Map<String, dynamic>;
  }

  Future<dynamic> _send(String method, Map<String, dynamic> params) async {
    final id = _nextId++;
    final body = jsonEncode({
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': id,
    });

    final uri = Uri.parse('$serverUrl/mcp');
    http.Response response;
    try {
      response = await _http
          .post(uri, headers: _headers, body: body)
          .timeout(AppConstants.httpTimeout);
    } catch (e) {
      throw Exception('MCP network error: $e');
    }

    if (response.statusCode == 401) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw ProblemDetails.fromJson(json);
    }
    if (response.statusCode >= 400) {
      throw Exception('MCP HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['error'] != null) {
      final err = json['error'] as Map<String, dynamic>;
      throw McpError(
        code: err['code'] as int,
        message: err['message'] as String? ?? 'Unknown MCP error',
      );
    }
    return json['result'];
  }
}

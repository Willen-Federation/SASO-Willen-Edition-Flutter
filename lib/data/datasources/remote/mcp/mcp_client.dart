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
  bool _initialized = false;

  /// Whether [initialize] has completed successfully.
  bool get isInitialized => _initialized;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Initialize the MCP session (protocol handshake).
  /// Call once before using [callTool].
  Future<void> initialize() async {
    await _send('initialize', {
      'protocolVersion': '2024-11-05',
      'capabilities': <String, dynamic>{},
      'clientInfo': {
        'name': 'SASO Willen Flutter',
        'version': AppConstants.version,
      },
    });
    _initialized = true;
  }

  /// Call a named MCP tool with [arguments] and return the raw result map.
  ///
  /// Throws [StateError] if called before [initialize] has completed.
  Future<Map<String, dynamic>> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    if (!_initialized) {
      throw StateError(
        'McpClient.initialize() must be called before callTool().',
      );
    }
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

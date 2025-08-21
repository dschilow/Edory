// Avatales.Services.NetworkService
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/app_utils.dart';

/// Service für Netzwerk-Operations und API-Calls
class NetworkService {
  static NetworkService? _instance;
  static NetworkService get instance => _instance ??= NetworkService._();
  NetworkService._();

  // API Configuration
  static const String _baseUrl = 'https://api.avatales.com/v1';
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  // Headers
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Avatales-Mobile/1.0.0',
  };

  // Connection State
  bool _isConnected = true;
  final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityController.stream;

  // Request Queue für Offline-Support
  final List<QueuedRequest> _requestQueue = [];
  Timer? _connectivityCheckTimer;

  /// Initialisiert den Network Service
  Future<void> initialize() async {
    await _checkConnectivity();
    _startConnectivityMonitoring();
    AppUtils.debugLog('NetworkService initialized');
  }

  /// Prüft die Netzwerkverbindung
  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isConnected = false;
    }
    
    _connectivityController.add(_isConnected);
    return _isConnected;
  }

  /// GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
  }) async {
    return _performRequest<T>(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  /// POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _performRequest<T>(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
    );
  }

  /// PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _performRequest<T>(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
    );
  }

  /// DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _performRequest<T>(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      headers: headers,
      timeout: timeout,
    );
  }

  /// Führt einen HTTP-Request aus
  Future<ApiResponse<T>> _performRequest<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    int retryCount = 0,
  }) async {
    try {
      // URL zusammenbauen
      final uri = _buildUri(endpoint, queryParameters);
      
      // Headers vorbereiten
      final requestHeaders = Map<String, String>.from(_defaultHeaders);
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Request erstellen
      final client = HttpClient();
      client.connectionTimeout = timeout ?? _defaultTimeout;

      final request = await client.openUrl(method, uri);
      
      // Headers setzen
      requestHeaders.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Body hinzufügen (falls vorhanden)
      if (body != null) {
        final bodyString = jsonEncode(body);
        request.write(bodyString);
      }

      // Request senden
      final response = await request.close();

      // Response verarbeiten
      final responseBody = await response.transform(utf8.decoder).join();
      
      AppUtils.debugLog(
        'API Request: $method $uri - Status: ${response.statusCode}',
        tag: 'NetworkService',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Erfolgreiche Response
        dynamic data;
        if (responseBody.isNotEmpty) {
          try {
            data = jsonDecode(responseBody);
          } catch (e) {
            data = responseBody;
          }
        }

        return ApiResponse<T>(
          success: true,
          data: data,
          statusCode: response.statusCode,
          message: 'Success',
        );
      } else {
        // Fehler-Response
        String errorMessage = 'Request failed';
        try {
          final errorData = jsonDecode(responseBody);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = responseBody.isNotEmpty ? responseBody : errorMessage;
        }

        // Retry bei bestimmten Fehlern
        if (_shouldRetry(response.statusCode) && retryCount < _maxRetries) {
          await Future.delayed(Duration(seconds: retryCount + 1));
          return _performRequest<T>(
            method: method,
            endpoint: endpoint,
            body: body,
            headers: headers,
            queryParameters: queryParameters,
            timeout: timeout,
            retryCount: retryCount + 1,
          );
        }

        return ApiResponse<T>(
          success: false,
          statusCode: response.statusCode,
          message: errorMessage,
        );
      }
    } catch (e) {
      AppUtils.errorLog('Network request failed', error: e);

      // Retry bei Netzwerkfehlern
      if (retryCount < _maxRetries) {
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _performRequest<T>(
          method: method,
          endpoint: endpoint,
          body: body,
          headers: headers,
          queryParameters: queryParameters,
          timeout: timeout,
          retryCount: retryCount + 1,
        );
      }

      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Baut die Request-URI zusammen
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final url = endpoint.startsWith('http') ? endpoint : '$_baseUrl$endpoint';
    final uri = Uri.parse(url);
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return Uri.parse('$url?$queryString');
    }
    
    return uri;
  }

  /// Prüft ob ein Retry für den Status-Code sinnvoll ist
  bool _shouldRetry(int statusCode) {
    return statusCode >= 500 || statusCode == 408 || statusCode == 429;
  }

  /// Fügt Request zur Offline-Queue hinzu
  void _queueRequest(QueuedRequest request) {
    _requestQueue.add(request);
    AppUtils.debugLog('Request queued for offline processing: ${request.endpoint}');
  }

  /// Verarbeitet die Offline-Queue
  Future<void> _processQueuedRequests() async {
    if (_requestQueue.isEmpty || !await isConnected()) return;

    AppUtils.debugLog('Processing ${_requestQueue.length} queued requests');

    final requestsToProcess = List<QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final request in requestsToProcess) {
      try {
        await _performRequest(
          method: request.method,
          endpoint: request.endpoint,
          body: request.body,
          headers: request.headers,
          queryParameters: request.queryParameters,
        );
        AppUtils.debugLog('Queued request processed: ${request.endpoint}');
      } catch (e) {
        AppUtils.errorLog('Failed to process queued request', error: e);
        // Request wieder zur Queue hinzufügen bei kritischen Anfragen
        if (request.critical) {
          _requestQueue.add(request);
        }
      }
    }
  }

  /// Startet die Konnektivitäts-Überwachung
  void _startConnectivityMonitoring() {
    _connectivityCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) async {
        final wasConnected = _isConnected;
        await _checkConnectivity();
        
        // Bei Verbindungswiederherstellung Queue abarbeiten
        if (!wasConnected && _isConnected) {
          AppUtils.debugLog('Connection restored, processing queued requests');
          await _processQueuedRequests();
        }
      },
    );
  }

  /// Prüft die Konnektivität
  Future<void> _checkConnectivity() async {
    await isConnected();
  }

  /// Setzt Auth-Token für alle Requests
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// Entfernt Auth-Token
  void clearAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  /// Download-Datei mit Progress-Callback
  Future<ApiResponse<List<int>>> downloadFile(
    String url, {
    Function(int received, int total)? onProgress,
  }) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        return ApiResponse<List<int>>(
          success: false,
          statusCode: response.statusCode,
          message: 'Download failed',
        );
      }

      final bytes = <int>[];
      final contentLength = response.contentLength;
      int received = 0;

      await for (final chunk in response) {
        bytes.addAll(chunk);
        received += chunk.length;
        onProgress?.call(received, contentLength);
      }

      return ApiResponse<List<int>>(
        success: true,
        data: bytes,
        statusCode: 200,
        message: 'Download completed',
      );
    } catch (e) {
      AppUtils.errorLog('File download failed', error: e);
      return ApiResponse<List<int>>(
        success: false,
        message: 'Download error: ${e.toString()}',
      );
    }
  }

  /// Upload-Datei mit Progress-Callback
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    List<int> fileBytes,
    String fileName, {
    Map<String, String>? additionalFields,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      // Vereinfachte Upload-Implementierung
      // In einer echten App würde hier multipart/form-data verwendet
      
      final base64Data = base64Encode(fileBytes);
      final body = {
        'file': base64Data,
        'filename': fileName,
        if (additionalFields != null) ...additionalFields,
      };

      return await post<T>(endpoint, body: body);
    } catch (e) {
      AppUtils.errorLog('File upload failed', error: e);
      return ApiResponse<T>(
        success: false,
        message: 'Upload error: ${e.toString()}',
      );
    }
  }

  void dispose() {
    _connectivityCheckTimer?.cancel();
    _connectivityController.close();
  }
}

// ===== Data Models =====

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? headers;

  const ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.headers,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
  }
}

class QueuedRequest {
  final String method;
  final String endpoint;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final Map<String, dynamic>? queryParameters;
  final bool critical;
  final DateTime timestamp;

  QueuedRequest({
    required this.method,
    required this.endpoint,
    this.body,
    this.headers,
    this.queryParameters,
    this.critical = false,
  }) : timestamp = DateTime.now();
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message';
}
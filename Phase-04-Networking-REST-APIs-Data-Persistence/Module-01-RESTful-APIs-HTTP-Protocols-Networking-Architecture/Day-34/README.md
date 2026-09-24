# 📘 Day 34: Enterprise Network Client Architecture with Dio

**Module 01:** [RESTful APIs, HTTP Protocols & Networking Architecture](../README.md) • **Phase 04:** [Networking, REST APIs & Data Persistence](../../README.md)

> [!NOTE]
> **Lesson Objective:** Master enterprise HTTP networking with package:dio. Learn how to configure global BaseOptions, implement request and error interceptors, build automated JWT token refresh engines with QueuedInterceptor to prevent race conditions, handle file transfers with real-time progress callbacks, and physically abort network requests using CancelToken.

**Tags:** `Flutter` `Networking` `Dio` `Interceptors` `Token Refresh` `CancelToken` `File Transfer` `JWT`

---

## 🚦 Prerequisites
HTTP Networking Fundamentals, REST Protocols & JSON Serialization; Dart Asynchronous Streams; Object-Oriented Dependency Injection.
You should understand the HTTP request-response lifecycle, status codes, and asynchronous Future error handling.

## 📖 Overview
While Dart's official `package:http` is lightweight and well-suited for simple utilities, enterprise-scale mobile applications require advanced networking capabilities that standard HTTP clients do not provide out of the box:
- **Interceptors**: Pre-processing requests, post-processing responses, and centralizing error telemetry.
- **Request Serialization & Queuing**: Handling automated OAuth2/JWT token refreshes without race conditions.
- **Request Cancellation**: Instantly terminating in-flight HTTP sockets when users navigate away or type new search terms.
- **Streaming File Transfers**: Real-time progress monitoring for multi-part file uploads and large asset downloads.
- **Certificate Pinning**: Hardening mobile security against Man-in-the-Middle (MITM) attacks.

**Dio** (`package:dio`) is the battle-tested, standard HTTP client in the Flutter ecosystem engineered specifically to meet these enterprise requirements.

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        DIO INTERCEPTOR PIPELINE                        │
├────────────────────────────────────────────────────────────────────────┤
│  Dio Request (apiClient.get('/profile'))                               │
│       │                                                                │
│       ▼                                                                │
│  [ Request Interceptor ] ──▶ Injects Bearer Token, Adds Device Headers │
│       │                                                                │
│       ▼                                                                │
│  [ Network Transport ] ───▶ Dispatches HTTP/2 frame over persistent TCP │
│       │                                                                │
│       ▼                                                                │
│  [ Response Interceptor ] ─▶ Inspects Status, Logs Metrics, Caches     │
│       │                                                                │
│       ├───────────────────┬────────────────────────────────────┐       │
│       ▼ (200 OK)          ▼ (401 Unauthorized)                 ▼ (500) │
│  Returns Response    [ QueuedInterceptor ]              Throws         │
│  to BLoC / UI        • Pauses pending requests          DioException   │
│                      • Calls refresh token endpoint                    │
│                      • Replays original request!                       │
└────────────────────────────────────────────────────────────────────────┘
```

## 📚 Topics Covered
* **1. The Case for Dio in Enterprise Flutter Applications**: Pre-processing requests, post-processing responses, and centralizing error telemetry.
* **2. BaseOptions & Global Client Configuration**: `connectTimeout`: Fails if the server's TCP socket cannot be reached within the duration (essential for dead networks).
* **3. The Interceptor Architecture**: 1. `onRequest(RequestOptions options, RequestInterceptorHandler handler)`: Executed before the request leaves the device. Used to inject ...
* **4. The Token Refresh Flow: QueuedInterceptor vs InterceptorsWrapper**: In modern applications authenticated via JWT, access tokens have a short lifespan (e.g., 15 minutes). When the access token expires, the ...
* **5. Centralized Error Transformer & DioException**: `connectionTimeout`: Failed to connect to server within configured timeout.
* **6. Request Cancellation with CancelToken**: 2. `GET /search?q=Fl`

## 🎯 Implementation Objective
Build a production-grade Enterprise Dio Network Client demonstrating centralized `BaseOptions`, an automated JWT token refresh engine using `QueuedInterceptor`, typed `DioException` error transformation, file downloading with a real-time percentage progress bar, and request cancellation via `CancelToken`.

```dart
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DioEnterpriseApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. TYPED DOMAIN FAILURES
// ─────────────────────────────────────────────────────────────────────────────

sealed class NetworkFailure implements Exception {
  final String message;
  const NetworkFailure(this.message);
  @override
  String toString() => message;
}

class NoConnectionFailure extends NetworkFailure {
  const NoConnectionFailure() : super('No internet connection. Please verify your WiFi or cellular data.');
}

class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure() : super('Network connection timed out. Server is taking too long to respond.');
}

class UnauthorizedFailure extends NetworkFailure {
  const UnauthorizedFailure() : super('Session expired. Please log in again.');
}

class ServerFailure extends NetworkFailure {
  final int statusCode;
  const ServerFailure(this.statusCode, String msg) : super('Server Error ($statusCode): $msg');
}

class RequestCancelledFailure extends NetworkFailure {
  const RequestCancelledFailure() : super('The network operation was cancelled.');
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. ENTERPRISE DIO CLIENT & QUEUED TOKEN REFRESH INTERCEPTOR
// ─────────────────────────────────────────────────────────────────────────────

class EnterpriseDioClient {
  late final Dio dio;
  String? _accessToken = 'expired_mock_token_123';
  final String _refreshToken = 'valid_refresh_token_xyz';

  EnterpriseDioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://httpbin.org',
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          'X-Client-Platform': 'Flutter-Foundation-Enterprise',
        },
      ),
    );

    // Register our QueuedInterceptor to prevent token refresh race conditions
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers[HttpHeaders.authorizationHeader] = 'Bearer $_accessToken';
          }
          debugPrint('🌐 [DIO REQUEST] -> ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [DIO RESPONSE] <- ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException err, handler) async {
          debugPrint('🚨 [DIO ERROR] <- ${err.type} on ${err.requestOptions.uri}');

          // Check for 401 Unauthorized to trigger token refresh
          if (err.response?.statusCode == 401 && _accessToken != null) {
            try {
              debugPrint('🔄 [TOKEN REFRESH] Access token expired! Refreshing session...');
              
              // Perform refresh call on an isolated Dio instance to avoid interceptor recursion
              final newAccessToken = await _performTokenRefresh();
              _accessToken = newAccessToken;

              // Update the authorization header on the original failed request
              final requestOptions = err.requestOptions;
              requestOptions.headers[HttpHeaders.authorizationHeader] = 'Bearer $newAccessToken';

              // Replay the original request with the fresh token!
              final clonedResponse = await dio.fetch(requestOptions);
              return handler.resolve(clonedResponse);
            } catch (refreshError) {
              debugPrint('❌ [TOKEN REFRESH FAILED] Session could not be restored.');
              _accessToken = null; // Clear credentials
              return handler.reject(
                DioException(
                  requestOptions: err.requestOptions,
                  error: const UnauthorizedFailure(),
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }

          return handler.next(err);
        },
      ),
    );
  }

  /// Simulates a secure refresh token handshake with the backend
  Future<String> _performTokenRefresh() async {
    // In production, call: await _isolatedDio.post('/auth/refresh', data: {'refresh_token': _refreshToken});
    await Future.delayed(const Duration(milliseconds: 800));
    return 'fresh_valid_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Maps raw DioException into strongly typed domain failures
  NetworkFailure mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.connectionError => const NoConnectionFailure(),
      DioExceptionType.cancel => const RequestCancelledFailure(),
      DioExceptionType.badResponse => switch (error.response?.statusCode) {
          401 => const UnauthorizedFailure(),
          final code? => ServerFailure(code, error.response?.statusMessage ?? 'Unknown error'),
          null => const ServerFailure(500, 'Unknown server error'),
        },
      _ => ServerFailure(500, error.message ?? 'Unexpected network failure'),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. PRESENTATION LAYER: FILE DOWNLOADER & CANCELLATION DEMO
// ─────────────────────────────────────────────────────────────────────────────

class DioEnterpriseApp extends StatelessWidget {
  const DioEnterpriseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enterprise Dio Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DioDashboardScreen(),
    );
  }
}

class DioDashboardScreen extends StatefulWidget {
  const DioDashboardScreen({super.key});

  @override
  State<DioDashboardScreen> createState() => _DioDashboardScreenState();
}

class _DioDashboardScreenState extends State<DioDashboardScreen> {
  final EnterpriseDioClient _client = EnterpriseDioClient();
  CancelToken? _cancelToken;

  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = 'Ready for network operations';

  Future<void> _testProtectedEndpoint() async {
    setState(() {
      _statusMessage = 'Executing request with expired token...';
    });

    try {
      // httpbin /status/401 simulates a 401 Unauthorized response from a protected route
      final response = await _client.dio.get('/status/401');
      setState(() {
        _statusMessage = 'Request Succeeded: ${response.statusCode} (Token Refreshed!)';
      });
    } on DioException catch (e) {
      final failure = _client.mapDioException(e);
      setState(() {
        _statusMessage = 'Result: $failure';
      });
    }
  }

  Future<void> _startStreamDownload() async {
    _cancelToken = CancelToken();
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = 'Streaming asset download over HTTP/2 socket...';
    });

    try {
      // Simulate downloading a large 5MB payload from httpbin with real-time byte tracking
      await _client.dio.get(
        '/bytes/5000000', // 5 Megabytes
        cancelToken: _cancelToken,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            setState(() {
              _downloadProgress = receivedBytes / totalBytes;
              _statusMessage = 'Downloaded ${(receivedBytes / 1024 / 1024).toStringAsFixed(2)} MB of '
                  '${(totalBytes / 1024 / 1024).toStringAsFixed(2)} MB';
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _statusMessage = 'Download Completed Successfully (5.00 MB)';
      });
    } on DioException catch (e) {
      final failure = _client.mapDioException(e);
      setState(() {
        _isDownloading = false;
        _statusMessage = failure is RequestCancelledFailure
            ? 'Download was cancelled by user via CancelToken.'
            : 'Download failed: $failure';
      });
    }
  }

  void _cancelDownload() {
    _cancelToken?.cancel('User aborted file transfer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enterprise Dio Client'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 20),
          _buildAuthCard(),
          const SizedBox(height: 20),
          _buildDownloadCard(),
          const SizedBox(height: 24),
          _buildStatusDisplay(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.shield_rounded, color: Colors.indigo, size: 32),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Enterprise Features: Queued Interceptors, Auto-Retry with Token Refresh, and CancelToken Socket Aborts.',
                style: TextStyle(fontSize: 13, height: 1.4, color: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Queued Token Refresh Flow',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Triggers an endpoint that returns 401. The QueuedInterceptor catches the 401, locks incoming requests, refreshes the JWT, and replays the original call.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _testProtectedEndpoint,
              icon: const Icon(Icons.lock_reset_rounded),
              label: const Text('Trigger 401 & Auto-Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Streaming Transfer with CancelToken',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Streams a 5MB payload with onReceiveProgress. Tap Cancel to immediately close the underlying socket via CancelToken.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 16),
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress > 0 ? _downloadProgress : null,
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _isDownloading ? null : _startStreamDownload,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download 5MB'),
                ),
                const SizedBox(width: 12),
                if (_isDownloading)
                  OutlinedButton.icon(
                    onPressed: _cancelDownload,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                    icon: const Icon(Icons.cancel_rounded),
                    label: const Text('Cancel Stream'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONSOLE / TELEMETRY LOG',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.1, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            _statusMessage,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **5 Interview Prep Scenarios** included
* **Technology Comparisons:** Dio vs package:http Enterprise Comparison Matrix, InterceptorsWrapper vs QueuedInterceptorsWrapper, CancelToken vs Future.timeout()
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[⬅️ Day 33: HTTP Networking Fundamentals, REST Protocols & JSON Serialization](../Day-33/README.md) | [📂 Module Index](../README.md) | [Day 35: Real-Time & Query-Based API Communication: WebSockets & GraphQL ➡️](../Day-35/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!


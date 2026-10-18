import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/device.dart';
import '../models/sensor_reading.dart';

/// The API URL is supplied at run time with --dart-define=API_BASE_URL=...
/// Android emulator default: http://10.0.2.2:5000
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  Future<List<Device>> getDevices() async {
    final json = await _getJson('/api/devices');
    if (json is! List) {
      throw const ApiException('The devices endpoint did not return a JSON list.');
    }

    return json
        .whereType<Map<String, dynamic>>()
        .map(Device.fromJson)
        .toList();
  }

  Future<SensorReading> getLatestReading(int deviceId) async {
    final json = await _getJson('/api/devices/$deviceId/latest-reading');
    if (json is! Map<String, dynamic>) {
      throw const ApiException('The latest-reading endpoint returned an unexpected response.');
    }
    return SensorReading.fromJson(json);
  }

  Future<List<SensorReading>> getReadingHistory(
    int deviceId, {
    int limit = 50,
  }) async {
    final json = await _getJson('/api/devices/$deviceId/readings?limit=$limit');
    if (json is! List) {
      throw const ApiException('The readings endpoint did not return a JSON list.');
    }

    return json
        .whereType<Map<String, dynamic>>()
        .map(SensorReading.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> getPumpStatus(int deviceId) async {
    final json = await _getJson('/api/devices/$deviceId/pump-status');
    if (json is! Map<String, dynamic>) {
      throw const ApiException('The pump-status endpoint returned an unexpected response.');
    }
    return json;
  }

  Future<dynamic> _getJson(String path) async {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$normalizedBase$path');

    late http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw ApiException('The API request timed out. Check that your API is running.');
    } on Exception catch (error) {
      throw ApiException(
        'Could not connect to the API at $normalizedBase. '
        'Check the API URL and network connection. Details: $error',
      );
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        decoded = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'API request failed with status ${response.statusCode}.';
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
      throw ApiException(message);
    }

    return decoded;
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

final apiService = ApiService();

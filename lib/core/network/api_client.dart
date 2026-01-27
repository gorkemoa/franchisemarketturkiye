import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:franchisemarketturkiye/core/utils/logger.dart';

import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/app/api_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<ApiResult<Map<String, dynamic>>> get(String url) async {
    Logger.logRequest('GET', url);
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
        },
      );

      // Basic body decoding for logging purpose (if json)
      dynamic bodyLog;
      try {
        bodyLog = jsonDecode(response.body);
      } catch (_) {
        bodyLog = response.body;
      }

      Logger.logResponse(url, response.statusCode, bodyLog);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedBody = bodyLog is Map<String, dynamic>
            ? bodyLog
            : jsonDecode(response.body);
        return ApiResult.success(decodedBody as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.logError(url, e.toString());
      return ApiResult.failure('Network Error: $e');
    }
  }

  Future<ApiResult<Map<String, dynamic>>> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    Logger.logRequest('POST', url, body: body);
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
        },
        body: jsonEncode(body),
      );

      // Basic body decoding for logging purpose (if json)
      dynamic bodyLog;
      try {
        bodyLog = jsonDecode(response.body);
      } catch (_) {
        bodyLog = response.body;
      }

      Logger.logResponse(url, response.statusCode, bodyLog);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedBody = bodyLog is Map<String, dynamic>
            ? bodyLog
            : jsonDecode(response.body);
        return ApiResult.success(decodedBody as Map<String, dynamic>);
      } else {
        return ApiResult.failure(
          'Request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.logError(url, e.toString());
      return ApiResult.failure('Network Error: $e');
    }
  }
}

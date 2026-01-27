import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:franchisemarketturkiye/core/utils/logger.dart';

import 'package:franchisemarketturkiye/core/network/api_result.dart';
import 'package:franchisemarketturkiye/app/api_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();

  Future<ApiResult<Map<String, dynamic>>> get(
    String url, {
    String? token,
  }) async {
    Logger.logRequest('GET', url);
    try {
      final headers = {
        'Accept': 'application/json',
        'X-API-KEY': ApiConstants.apiKey,
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.get(Uri.parse(url), headers: headers);

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
    String? token,
  }) async {
    Logger.logRequest('POST', url, body: body);
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-KEY': ApiConstants.apiKey,
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
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

  Future<ApiResult<Map<String, dynamic>>> put(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    Logger.logRequest('PUT', url, body: body);
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-API-KEY': ApiConstants.apiKey,
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
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

  Future<ApiResult<Map<String, dynamic>>> postMultipart(
    String url, {
    Map<String, String>? fields,
    Map<String, String>? files,
    String? token,
  }) async {
    Logger.logRequest('POST MULTIPART', url, body: fields);
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Accept'] = 'application/json';
      request.headers['X-API-KEY'] = ApiConstants.apiKey;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        for (var entry in files.entries) {
          if (entry.value.isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value),
            );
          }
        }
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

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

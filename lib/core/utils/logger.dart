import 'dart:developer' as developer;

class Logger {
  static void logRequest(String method, String url, {dynamic body}) {
    developer.log(
      '------------------------------------------------------------------',
      name: 'API_REQUEST',
    );
    developer.log('✈️ REQUEST: $method $url', name: 'API_REQUEST');
    if (body != null) {
      developer.log('📦 BODY: $body', name: 'API_REQUEST');
    }
    developer.log(
      '------------------------------------------------------------------',
      name: 'API_REQUEST',
    );
  }

  static void logResponse(String url, int statusCode, dynamic body) {
    final bool isSuccess = statusCode >= 200 && statusCode < 300;
    final String emoji = isSuccess ? '✅' : '❌';

    developer.log(
      '------------------------------------------------------------------',
      name: 'API_RESPONSE',
    );
    developer.log('$emoji RESPONSE ($statusCode): $url', name: 'API_RESPONSE');
    if (body != null) {
      // Truncate if too long for simple logs, or just print all.
      // For "readability", let's print formatted string if it's very long or just standard.
      // developer.log doesn't strictly limit length, but console might.
      developer.log('📦 DATA: $body', name: 'API_RESPONSE');
    }
    developer.log(
      '------------------------------------------------------------------',
      name: 'API_RESPONSE',
    );
  }

  static void logError(String url, String error) {
    developer.log(
      '------------------------------------------------------------------',
      name: 'API_ERROR',
    );
    developer.log('🚨 ERROR: $url', name: 'API_ERROR');
    developer.log('🛑 MESSAGE: $error', name: 'API_ERROR');
    developer.log(
      '------------------------------------------------------------------',
      name: 'API_ERROR',
    );
  }
}

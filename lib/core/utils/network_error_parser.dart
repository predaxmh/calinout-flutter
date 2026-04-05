import 'package:dio/dio.dart';

class NetworkErrorParser {
  static String parseError(Object error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    // Handle other unknown errors
    return "An unexpected error occurred.";
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet.";

      case DioExceptionType.badResponse:
        return _parseHttpError(error.response);

      case DioExceptionType.connectionError:
        return "No internet connection available.";

      case DioExceptionType.cancel:
        return "Request was cancelled.";

      default:
        return "A network error occurred (${error.type.name}).";
    }
  }

  static String _parseHttpError(Response? response) {
    if (response == null) return "Server returned no response.";

    // 1. Look for the specific error format from your C# BaseController
    // You configured C# to return: BadRequest(new { error = result.Error })
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) return data['error'].toString();
      if (data.containsKey('message')) {
        return data['message'].toString(); // Default ASP.NET
      }
    }

    // 2. Fallback based on Status Code (if JSON body is empty)
    switch (response.statusCode) {
      case 400:
        return "Bad request. Please check your input.";
      case 401:
        return "Unauthorized. Please log in again.";
      case 403:
        return "Access denied.";
      case 404:
        return "The requested resource was not found.";
      case 409:
        // This handles your "Duplicate Name" conflict specifically
        return "This item already exists/conflict detected.";
      case 500:
        return "Internal server error. Please try again later.";
      default:
        return "Server error: ${response.statusCode}";
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../models/healthcare_models.dart';

final healthcareRepositoryProvider = Provider<HealthcareRepository>((ref) {
  return HealthcareRepository(ref.watch(dioProvider));
});

class HealthcareRepository {
  const HealthcareRepository(this._dio);

  final Dio _dio;

  Future<T> _withRetry<T>(Future<T> Function() request) async {
    DioException? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await request();
      } on DioException catch (error) {
        lastError = error;
        final canRetry =
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError;
        if (!canRetry || attempt == 1) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }
    throw lastError ?? StateError('Request failed');
  }

  Future<AnalyzeResponse> analyze(AnalyzeRequest request) {
    return _withRetry(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/analyze-request/',
        data: request.toJson(),
      );
      return AnalyzeResponse.fromJson(response.data ?? {});
    });
  }

  Future<BookingResponse> confirmBooking(BookingRequest request) {
    return _withRetry(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/simulate-booking/',
        data: request.toJson(),
      );
      return BookingResponse.fromJson(response.data ?? {});
    });
  }

  Future<BookingResponse> getBooking(String bookingId) {
    return _withRetry(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/simulate-booking/$bookingId',
      );
      return BookingResponse.fromJson(response.data ?? {});
    });
  }

  Future<List<AnalyticsResponse>> hospitalAnalytics({String city = 'Karachi'}) {
    return _withRetry(() async {
      final response = await _dio.get<List<dynamic>>(
        '/hospital-analytics/',
        queryParameters: {'city': city},
      );
      return (response.data ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AnalyticsResponse.fromJson)
          .toList();
    });
  }

  Future<Map<String, dynamic>?> trace(String traceId) {
    return _withRetry(() async {
      final response = await _dio.get<Map<String, dynamic>>('/traces/$traceId');
      return response.data;
    });
  }
}

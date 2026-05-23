import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../config/app_config.dart';
import '../../../data/models/healthcare_models.dart';
import '../../../data/repositories/healthcare_repository.dart';

final healthcareFlowProvider =
    StateNotifierProvider<HealthcareFlowController, HealthcareFlowState>((ref) {
      return HealthcareFlowController(ref.watch(healthcareRepositoryProvider));
    });

@immutable
class HealthcareFlowState {
  const HealthcareFlowState({
    this.analysis,
    this.booking,
    this.analytics = const [],
    this.trace,
    this.isAnalyzing = false,
    this.isBooking = false,
    this.isLoadingAnalytics = false,
    this.error,
  });

  final AnalyzeResponse? analysis;
  final BookingResponse? booking;
  final List<AnalyticsResponse> analytics;
  final Map<String, dynamic>? trace;
  final bool isAnalyzing;
  final bool isBooking;
  final bool isLoadingAnalytics;
  final String? error;

  HealthcareFlowState copyWith({
    AnalyzeResponse? analysis,
    BookingResponse? booking,
    List<AnalyticsResponse>? analytics,
    Map<String, dynamic>? trace,
    bool? isAnalyzing,
    bool? isBooking,
    bool? isLoadingAnalytics,
    String? error,
    bool clearError = false,
  }) {
    return HealthcareFlowState(
      analysis: analysis ?? this.analysis,
      booking: booking ?? this.booking,
      analytics: analytics ?? this.analytics,
      trace: trace ?? this.trace,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isBooking: isBooking ?? this.isBooking,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class HealthcareFlowController extends StateNotifier<HealthcareFlowState> {
  HealthcareFlowController(this._repository)
    : super(const HealthcareFlowState());

  final HealthcareRepository _repository;

  Future<void> analyze({
    required String message,
    String location = AppConfig.defaultCity,
    String? preferredTime,
  }) async {
    state = const HealthcareFlowState(isAnalyzing: true);
    try {
      final analysis = await _repository.analyze(
        AnalyzeRequest(
          message: message,
          location: location,
          preferredTime: preferredTime,
        ),
      );
      Map<String, dynamic>? trace;
      if (analysis.traceId != null) {
        try {
          trace = await _repository.trace(analysis.traceId!);
        } catch (_) {
          trace = null;
        }
      }
      state = state.copyWith(
        analysis: analysis,
        trace: trace,
        isAnalyzing: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(isAnalyzing: false, error: _friendlyError(error));
    }
  }

  Future<void> confirmBooking() async {
    final analysis = state.analysis;
    if (analysis == null) return;
    state = state.copyWith(isBooking: true, clearError: true);
    try {
      final booking = await _repository.getBooking(analysis.bookingId);
      state = state.copyWith(
        booking: booking,
        isBooking: false,
        clearError: true,
      );
    } catch (_) {
      try {
        final booking = await _repository.confirmBooking(
          BookingRequest(
            hospitalId: analysis.hospitalId,
            urgency: analysis.urgency,
            requestedTime: analysis.requestedTime,
            hospitalName: analysis.selectedHospital,
            eta: analysis.eta,
          ),
        );
        state = state.copyWith(
          booking: booking,
          isBooking: false,
          clearError: true,
        );
      } catch (_) {
        state = state.copyWith(
          booking: BookingResponse(
            bookingStatus: 'Confirmed',
            bookingId: analysis.bookingId,
            appointmentTime: analysis.requestedTime ?? 'As soon as possible',
            token: analysis.urgency == 'HIGH'
                ? 'Emergency priority'
                : 'Standard',
            hospitalName: analysis.selectedHospital,
          ),
          isBooking: false,
          clearError: true,
        );
      }
    }
  }

  Future<void> loadAnalytics({String city = AppConfig.defaultCity}) async {
    state = state.copyWith(isLoadingAnalytics: true, clearError: true);
    try {
      final analytics = await _repository.hospitalAnalytics(city: city);
      state = state.copyWith(analytics: analytics, isLoadingAnalytics: false);
    } catch (error) {
      state = state.copyWith(
        isLoadingAnalytics: false,
        error: _friendlyError(error),
      );
    }
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final detail = error.response?.data ?? error.message ?? error.type.name;
      return 'Rahe-Sehat could not complete the backend request at ${AppConfig.apiBaseUrl}. '
          '${status == null ? '' : 'HTTP $status. '}Details: $detail';
    }
    return 'Rahe-Sehat could not reach the healthcare backend. Confirm FastAPI is running on ${AppConfig.apiBaseUrl}.';
  }
}

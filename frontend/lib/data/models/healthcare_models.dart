class AnalyzeRequest {
  const AnalyzeRequest({
    required this.message,
    required this.location,
    this.preferredTime,
  });

  final String message;
  final String location;
  final String? preferredTime;

  Map<String, dynamic> toJson() => {
    'message': message,
    'location': location,
    if (preferredTime != null) 'preferred_time': preferredTime,
  };
}

class AnalyzeResponse {
  const AnalyzeResponse({
    required this.urgency,
    required this.symptom,
    required this.requestType,
    required this.selectedHospital,
    this.location,
    required this.hospitalId,
    required this.distance,
    required this.eta,
    required this.waitTime,
    required this.hospitalRating,
    required this.bookingId,
    required this.reasoningLogs,
    this.congestionLevel,
    this.trafficCondition,
    this.hospitalLat,
    this.hospitalLng,
    this.originLat,
    this.originLng,
    this.routePolyline,
    this.vicinity,
    this.requestedTime,
    this.traceId,
    this.emergencyNote,
    this.opsInsights = const [],
    this.followUp,
    this.rankedHospitals = const [],
  });

  final String urgency;
  final String symptom;
  final String requestType;
  final String? location;
  final String? requestedTime;
  final String selectedHospital;
  final String hospitalId;
  final String distance;
  final String eta;
  final String waitTime;
  final double hospitalRating;
  final String? congestionLevel;
  final String? trafficCondition;
  final double? hospitalLat;
  final double? hospitalLng;
  final double? originLat;
  final double? originLng;
  final String? routePolyline;
  final String? vicinity;
  final String bookingId;
  final List<String> reasoningLogs;
  final String? traceId;
  final String? emergencyNote;
  final List<String> opsInsights;
  final String? followUp;
  final List<dynamic> rankedHospitals;

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      urgency: json['urgency']?.toString() ?? 'LOW',
      symptom: json['symptom']?.toString() ?? 'General medical issue',
      requestType: json['request_type']?.toString() ?? 'Routine',
      location: json['location']?.toString(),
      requestedTime: json['requested_time']?.toString(),
      selectedHospital:
          json['selected_hospital']?.toString() ?? 'No hospital found',
      hospitalId: json['hospital_id']?.toString() ?? 'N/A',
      distance: json['distance']?.toString() ?? 'N/A',
      eta: json['eta']?.toString() ?? 'N/A',
      waitTime: json['wait_time']?.toString() ?? 'N/A',
      hospitalRating: (json['hospital_rating'] as num?)?.toDouble() ?? 0,
      congestionLevel: json['congestion_level']?.toString(),
      trafficCondition: json['traffic_condition']?.toString(),
      hospitalLat: (json['hospital_lat'] as num?)?.toDouble(),
      hospitalLng: (json['hospital_lng'] as num?)?.toDouble(),
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      routePolyline: json['route_polyline']?.toString(),
      vicinity: json['vicinity']?.toString(),
      bookingId: json['booking_id']?.toString() ?? 'N/A',
      reasoningLogs: (json['reasoning_logs'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      traceId: json['trace_id']?.toString(),
      emergencyNote: json['emergency_note']?.toString(),
      opsInsights: (json['ops_insights'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      followUp: json['follow_up']?.toString(),
      rankedHospitals: (json['ranked_hospitals'] as List<dynamic>?) ?? const [],
    );
  }

  List<dynamic> get rankHospitalsNullSafe => rankedHospitals ?? const [];
}

class BookingRequest {
  const BookingRequest({
    required this.hospitalId,
    required this.urgency,
    this.patientName = 'Rahe-Sehat Patient',
    this.requestedTime,
    this.hospitalName,
    this.eta,
  });

  final String hospitalId;
  final String urgency;
  final String patientName;
  final String? requestedTime;
  final String? hospitalName;
  final String? eta;

  Map<String, dynamic> toJson() => {
    'hospital_id': hospitalId,
    'urgency': urgency,
    'patient_name': patientName,
    if (requestedTime != null) 'requested_time': requestedTime,
    if (hospitalName != null) 'hospital_name': hospitalName,
    if (eta != null) 'eta': eta,
  };
}

class BookingResponse {
  const BookingResponse({
    required this.bookingStatus,
    required this.bookingId,
    required this.appointmentTime,
    this.token,
    this.hospitalName,
  });

  final String bookingStatus;
  final String bookingId;
  final String appointmentTime;
  final String? token;
  final String? hospitalName;

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      bookingStatus: json['booking_status']?.toString() ?? 'Unknown',
      bookingId: json['booking_id']?.toString() ?? 'N/A',
      appointmentTime: json['appointment_time']?.toString() ?? 'N/A',
      token: json['token']?.toString(),
      hospitalName: json['hospital_name']?.toString(),
    );
  }
}

class AnalyticsResponse {
  const AnalyticsResponse({
    required this.hospitalName,
    required this.peakDay,
    required this.peakHours,
    required this.mostBusyWard,
    required this.emergencyLoad,
  });

  final String hospitalName;
  final String peakDay;
  final String peakHours;
  final String mostBusyWard;
  final String emergencyLoad;

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      hospitalName: json['hospital_name']?.toString() ?? 'Unknown hospital',
      peakDay: json['peak_day']?.toString() ?? 'Unknown',
      peakHours: json['peak_hours']?.toString() ?? 'N/A',
      mostBusyWard: json['most_busy_ward']?.toString() ?? 'General',
      emergencyLoad: json['emergency_load']?.toString() ?? 'LOW',
    );
  }
}

class AgentStep {
  const AgentStep({
    required this.name,
    required this.description,
    required this.iconCodePoint,
  });

  final String name;
  final String description;
  final int iconCodePoint;
}

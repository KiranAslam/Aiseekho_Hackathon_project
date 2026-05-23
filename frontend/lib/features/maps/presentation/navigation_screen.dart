import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_chrome.dart';
import '../../healthcare_request/presentation/healthcare_flow_controller.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  bool _mapReady = false;
  bool _showFallback = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _fallbackTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && !_mapReady) {
        setState(() => _showFallback = true);
      }
    });
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(healthcareFlowProvider).analysis;
    if (analysis == null) {
      return const AppScaffold(
        title: 'Navigation',
        showBack: true,
        child: StateMessage(
          title: 'Route unavailable',
          message: 'Run an analysis before opening navigation.',
        ),
      );
    }

    final hospitalPosition = LatLng(
      analysis.hospitalLat ?? 24.8607,
      analysis.hospitalLng ?? 67.0011,
    );
    final originPosition = LatLng(
      analysis.originLat ?? 24.8607,
      analysis.originLng ?? 67.0011,
    );
    final hasLiveCoordinates =
        analysis.hospitalLat != null && analysis.hospitalLng != null;
    final route = _decodePolyline(analysis.routePolyline);
    final routePoints = route.isEmpty
        ? [originPosition, hospitalPosition]
        : route;

    return AppScaffold(
      title: 'Maps & Navigation',
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassPanel(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: SizedBox(
                height: 380,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFFE9F5F3),
                        child: GoogleMap(
                          onMapCreated: (_) {
                            if (!mounted) return;
                            setState(() {
                              _mapReady = true;
                              _showFallback = false;
                            });
                          },
                          initialCameraPosition: CameraPosition(
                            target: hospitalPosition,
                            zoom: hasLiveCoordinates ? 14 : 11,
                          ),
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: true,
                          trafficEnabled: true,
                          markers: {
                            Marker(
                              markerId: const MarkerId('origin'),
                              position: originPosition,
                              infoWindow: const InfoWindow(
                                title: 'Current search area',
                              ),
                            ),
                            Marker(
                              markerId: const MarkerId('hospital'),
                              position: hospitalPosition,
                              infoWindow: InfoWindow(
                                title: analysis.selectedHospital,
                                snippet: '${analysis.eta} | ${analysis.distance}',
                              ),
                            ),
                          },
                          polylines: {
                            Polyline(
                              polylineId: const PolylineId('optimized_route'),
                              points: routePoints,
                              color: AppColors.teal,
                              width: 5,
                              geodesic: true,
                            ),
                          },
                        ),
                      ),
                    ),
                    if (_showFallback || !_mapReady)
                      Positioned.fill(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.94),
                                Colors.white.withValues(alpha: 0.84),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.map_rounded,
                                size: 54,
                                color: AppColors.teal,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _mapReady
                                    ? 'Map loaded successfully.'
                                    : 'Map is taking time to initialize.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hasLiveCoordinates
                                    ? 'Route data is available for ${analysis.selectedHospital}. If the map plugin cannot render, the route summary below is still active.'
                                    : 'The backend returned fallback coordinates. Route summary is still available below.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          MetricGrid(
            children: [
              MetricTile(
                label: 'ETA',
                value: analysis.eta,
                icon: Icons.schedule_rounded,
              ),
              MetricTile(
                label: 'Traffic',
                value: _readableTraffic(analysis.trafficCondition),
                icon: Icons.traffic_rounded,
                color: AppColors.amber,
              ),
              MetricTile(
                label: 'Emergency mode',
                value: analysis.urgency == 'HIGH' ? 'On' : 'Ready',
                icon: Icons.emergency_rounded,
              ),
              MetricTile(
                label: 'Distance',
                value: analysis.distance,
                icon: Icons.route_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          GlassPanel(
            child: Row(
              children: [
                Icon(
                  hasLiveCoordinates
                      ? Icons.satellite_alt_rounded
                      : Icons.location_searching_rounded,
                  color: hasLiveCoordinates
                      ? AppColors.success
                      : AppColors.amber,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasLiveCoordinates
                        ? 'Live Google Places coordinates and Directions ETA are active for ${analysis.selectedHospital}.'
                        : 'Map is using Karachi fallback coordinates because the backend did not return precise coordinates for this result.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _readableTraffic(String? value) {
  if (value == null || value.isEmpty) return 'Live';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

List<LatLng> _decodePolyline(String? encoded) {
  if (encoded == null || encoded.isEmpty) return const [];
  final points = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lng = 0;

  while (index < encoded.length) {
    var shift = 0;
    var result = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);
    lat += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

    shift = 0;
    result = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20 && index < encoded.length);
    lng += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

    points.add(LatLng(lat / 1e5, lng / 1e5));
  }
  return points;
}

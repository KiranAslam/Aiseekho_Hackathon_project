import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_processing/presentation/ai_processing_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/booking/presentation/booking_confirmation_screen.dart';
import '../../features/followup/presentation/followup_screen.dart';
import '../../features/healthcare_request/presentation/request_screen.dart';
import '../../features/healthcare_request/presentation/splash_screen.dart';
import '../../features/hospital_recommendation/presentation/recommendation_screen.dart';
import '../../features/maps/presentation/navigation_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/request',
        builder: (context, state) => const RequestScreen(),
      ),
      GoRoute(
        path: '/processing',
        builder: (context, state) => const AiProcessingScreen(),
      ),
      GoRoute(
        path: '/recommendation',
        builder: (context, state) => const RecommendationScreen(),
      ),
      GoRoute(
        path: '/navigation',
        builder: (context, state) => const NavigationScreen(),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        path: '/followup',
        builder: (context, state) => const FollowUpScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});

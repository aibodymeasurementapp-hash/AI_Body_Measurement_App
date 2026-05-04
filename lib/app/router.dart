import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/category/category_selection_screen.dart';
import '../screens/dress_type/dress_type_screen.dart';
import '../screens/measurements/manual_measurement_screen.dart'
    show ManualMeasurementScreen;
import '../screens/measurements/camera_measurement_screen.dart';
import '../screens/measurements/result_display_screen.dart'
    show ResultDisplayScreen;
import '../screens/recommendations/recommended_dresses_screen.dart';
import '../screens/measurements/live_camera_screen.dart';
import '../screens/payment/payment_screen.dart' show PaymentScreen;
import '../screens/payment/plan_screen.dart' show PlanScreen;
import '../screens/payment/payment_success_screen.dart';
import '../screens/measurements/measurement_history_screen.dart';
import '../screens/recommendations/dress_detail_screen.dart';

<<<<<<< HEAD
=======
// ✅ Fix: Dress model must be imported so router.dart can cast state.extra
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
import '../models/dress.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/category',
        name: 'category',
        builder: (context, state) => const CategorySelectionScreen(),
      ),

      GoRoute(
        path: '/dress-type',
        name: 'dress-type',
        builder: (context, state) => const DressTypeScreen(),
      ),

      GoRoute(
        path: '/manual-measurement',
        name: 'manual-measurement',
        builder: (context, state) => const ManualMeasurementScreen(),
      ),

      GoRoute(
        path: '/camera-measurement',
        name: 'camera-measurement',
        builder: (context, state) => const CameraMeasurementScreen(),
      ),

      GoRoute(
        path: '/live-camera',
        name: 'live-camera',
        builder: (context, state) => const LiveCameraScreen(),
      ),

      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) {
          final source = state.uri.queryParameters['source'] ?? 'manual';
          return ResultDisplayScreen(source: source);
        },
      ),

      GoRoute(
        path: '/recommended-dresses',
        name: 'recommended-dresses',
        builder: (context, state) => const RecommendedDressesScreen(),
      ),

<<<<<<< HEAD
=======
      // Optional teaser screen.
      // It should only show features and send user to /payment.
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      GoRoute(
        path: '/plans',
        name: 'plans',
        builder: (context, state) => const PlanScreen(),
      ),

<<<<<<< HEAD
=======
      // RevenueCat paywall screen.
      // Monthly, yearly, and one-time lifetime plans are handled by RevenueCat.
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentScreen(),
      ),

<<<<<<< HEAD
      // ✅ extra carries { chargeId, receiptUrl } from PaymentScreen
=======
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      GoRoute(
        path: '/payment-success',
        name: 'payment-success',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),

      GoRoute(
        path: '/measurement-history',
        name: 'measurement-history',
        builder: (context, state) => const MeasurementHistoryScreen(),
      ),

<<<<<<< HEAD
=======
      // ✅ Dress detail route — receives Dress object via state.extra
>>>>>>> 545a1120d8ac65c628454bf89699a4ff8fd55a89
      GoRoute(
        path: '/dress-detail',
        name: 'dress-detail',
        builder: (context, state) => DressDetailScreen(
          dress: state.extra as Dress,
        ),
      ),
    ],
  );
});
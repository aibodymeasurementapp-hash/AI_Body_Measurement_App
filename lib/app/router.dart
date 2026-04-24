// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/category/category_selection_screen.dart';
import '../screens/dress_type/dress_type_screen.dart';
import '../screens/measurements/manual_measurement_screen.dart';
import '../screens/measurements/camera_measurement_screen.dart';
import '../screens/measurements/result_display_screen.dart';
import '../screens/recommendations/recommended_dresses_screen.dart';
import '../screens/measurements/live_camera_screen.dart';
// import '../screens/recommendations/dress_detail_screen.dart';

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
        builder: (context, state) => const ResultDisplayScreen(),
      ),
      GoRoute(
        path: '/recommended-dresses',
        name: 'recommended-dresses',
        builder: (context, state) => const RecommendedDressesScreen(),
      ),
      // GoRoute(
      //   path: '/dress-detail/:dressId',
      //   name: 'dress-detail',
      //   builder: (context, state) {
      //     final dressId = state.pathParameters['dressId']!;
      //     return DressDetailScreen(dressId: dressId);
      //   },
      // ),
    ],
  );
});



// android/app/src/main/kotlin/YOUR_PACKAGE_NAME/MainActivity.kt
//
// ⚠️  REPLACE "YOUR_PACKAGE_NAME" with your actual package name
//     (find it at the top of your current MainActivity.kt)
//
// This is the #1 fix for RevenueCat paywall not showing on Android.
// FlutterActivity → FlutterFragmentActivity  (one word change)

package com.example.ai_body_measure_app   // ← paste your real package name here

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
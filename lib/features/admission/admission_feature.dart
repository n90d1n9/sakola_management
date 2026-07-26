import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/features/feature_routes.dart';
import '../../core/features/features_base.dart';

import '../screens/admission_dashboard.dart';
import '../screens/admission_main_screen.dart';
import '../screens/admission_form_screen.dart';

class AdmissionFeature implements FeaturesBase {
  @override
  List<FeatureRoutes> registerScreens() => [
    FeatureRoutes(
      name: 'Admission',
      items: [
        FeatureRoutes(
          name: 'PPDB Dashboard',
          path: '/admission',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              MaterialPage(child: AdmissionDashboardScreen()),
        ),
        FeatureRoutes(
          name: 'Admission Management',
          path: '/admission/manage',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              MaterialPage(child: AdmissionMainScreen()),
        ),
        FeatureRoutes(
          name: 'Admission Form',
          path: '/admission/form',
          pageBuilder: (BuildContext context, GoRouterState state) {
            // You can pass admission ID for edit mode via state
            return MaterialPage(child: AdmissionFormScreen());
          },
        ),
      ],
    ),
  ];
}

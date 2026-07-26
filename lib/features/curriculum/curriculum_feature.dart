import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/features/features_base.dart';
import '../screens/curriculum_dashboard.dart';
import '../screens/curriculum_main_screen.dart';

/// Curriculum Feature Registration
/// Manages Kurikulum Merdeka, lesson plans (RPP/Modul Ajar)
class CurriculumFeature extends FeaturesBase {
  @override
  String get name => 'Kurikulum';

  @override
  IconData get icon => Icons.menu_book_rounded;

  @override
  ScreenType get screenType => ScreenType.branch;

  @override
  String? get description => 'Manajemen Kurikulum & Perangkat Pembelajaran';

  @override
  String? get path => '/curriculum';

  @override
  WidgetBuilder? get builder => null;

  @override
  PageBuilder? get pageBuilder => (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: CurriculumDashboard(),
    );
  };

  @override
  List<FeatureRoutes> get items => [
        // Main curriculum management screen
        FeatureRoutes(
          name: 'CurriculumMain',
          path: '/curriculum/main',
          initialLocation: '/curriculum/main',
          screenType: ScreenType.singlePage,
          icon: Icons.list_alt_rounded,
          description: 'Kelola Peta Kurikulum & RPP',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: CurriculumMainScreen(),
            );
          },
        ),
        // Curriculum Map detail/edit
        FeatureRoutes(
          name: 'CurriculumMapDetail',
          path: '/curriculum/map/:id',
          pathBuilder: ':id',
          initialLocation: '/curriculum/map',
          screenType: ScreenType.withParam,
          icon: Icons.map_rounded,
          description: 'Detail Peta Kurikulum',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            // Return placeholder - implement detail screen
            return Scaffold(
              appBar: AppBar(title: Text('Detail Kurikulum')),
              body: Center(child: Text('Curriculum Map ID: $id')),
            );
          },
        ),
        // Lesson Plan detail/edit
        FeatureRoutes(
          name: 'LessonPlanDetail',
          path: '/curriculum/lesson/:id',
          pathBuilder: ':id',
          initialLocation: '/curriculum/lesson',
          screenType: ScreenType.withParam,
          icon: Icons.edit_note_rounded,
          description: 'Detail RPP/Modul Ajar',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            // Return placeholder - implement detail screen
            return Scaffold(
              appBar: AppBar(title: Text('Detail RPP')),
              body: Center(child: Text('Lesson Plan ID: $id')),
            );
          },
        ),
      ];
}

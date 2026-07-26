import '../core/features/features_base.dart';
import '../features/ibs/school_feature.dart';
import '../features/examination/screens/examination_dashboard.dart';
import '../features/finance/screens/finance_dashboard.dart';

List<FeaturesBase> registerFeatures() {
  return [
    SchoolFeature(),
    ExaminationFeature(),
    FinanceFeature(),
  ];
}

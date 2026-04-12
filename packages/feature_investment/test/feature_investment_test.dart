import 'package:flutter_test/flutter_test.dart';

import 'package:feature_investment/feature_investment.dart';

void main() {
  test('creates investment feature package marker', () {
    const package = FeatureInvestmentPackage();

    expect(package, isA<FeatureInvestmentPackage>());
  });
}

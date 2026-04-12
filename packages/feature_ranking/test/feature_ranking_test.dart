import 'package:flutter_test/flutter_test.dart';

import 'package:feature_ranking/feature_ranking.dart';

void main() {
  test('creates ranking feature package marker', () {
    const package = FeatureRankingPackage();

    expect(package, isA<FeatureRankingPackage>());
  });
}

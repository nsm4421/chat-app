import 'package:flutter_test/flutter_test.dart';

import 'package:feature_community/feature_community.dart';

void main() {
  test('creates community feature package marker', () {
    const package = FeatureCommunityPackage();

    expect(package, isA<FeatureCommunityPackage>());
  });
}

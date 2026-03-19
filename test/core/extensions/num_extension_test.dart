import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumExtension', () {
    test('h and v create spacing boxes with expected dimensions', () {
      expect(12.h.width, 12);
      expect(12.h.height, null);
      expect(16.v.height, 16);
      expect(16.v.width, null);
    });

    test('r returns the raw double value for radius helpers', () {
      expect(12.r, 12);
    });

    test('padding helpers create expected edge insets', () {
      expect(8.p, const EdgeInsets.all(8));
      expect(12.px, const EdgeInsets.symmetric(horizontal: 12));
      expect(16.py, const EdgeInsets.symmetric(vertical: 16));
    });

    test('radius helpers create circular radius objects', () {
      expect(10.radius, const Radius.circular(10));
      expect(14.br, BorderRadius.circular(14));
    });
  });
}

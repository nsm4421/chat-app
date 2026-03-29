import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  group('Debouncer', () {
    test('runs only the last action in trailing mode', () async {
      var callCount = 0;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 30));

      debouncer.run(() => callCount += 1);
      debouncer.run(() => callCount += 1);
      debouncer.run(() => callCount += 1);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(callCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(callCount, 1);
    });

    test('ignores repeated actions during cooldown in leading mode', () async {
      var callCount = 0;
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 30),
        leading: true,
      );

      debouncer.run(() => callCount += 1);
      debouncer.run(() => callCount += 1);
      debouncer.run(() => callCount += 1);

      expect(callCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      debouncer.run(() => callCount += 1);

      expect(callCount, 2);
    });
  });
}

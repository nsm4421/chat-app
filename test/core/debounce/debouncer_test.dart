import 'package:domodachi/core/debounce/debouncer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('runs only the last action in trailing mode', () {
      fakeAsync((async) {
        var callCount = 0;
        final debouncer = Debouncer(
          duration: const Duration(milliseconds: 300),
        );

        debouncer.run(() => callCount += 1);
        debouncer.run(() => callCount += 1);
        debouncer.run(() => callCount += 1);

        async.elapse(const Duration(milliseconds: 299));
        expect(callCount, 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(callCount, 1);
      });
    });

    test('ignores repeated actions during cooldown in leading mode', () {
      fakeAsync((async) {
        var callCount = 0;
        final debouncer = Debouncer(
          duration: const Duration(milliseconds: 300),
          leading: true,
        );

        debouncer.run(() => callCount += 1);
        debouncer.run(() => callCount += 1);
        debouncer.run(() => callCount += 1);

        expect(callCount, 1);

        async.elapse(const Duration(milliseconds: 300));
        debouncer.run(() => callCount += 1);

        expect(callCount, 2);
      });
    });
  });
}

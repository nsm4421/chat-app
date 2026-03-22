import 'dart:async';

typedef DebouncedAction = FutureOr<void> Function();

class Debouncer {
  Debouncer({
    this.duration = const Duration(milliseconds: 300),
    this.leading = false,
  });

  final Duration duration;
  final bool leading;

  Timer? _timer;
  bool _isDisposed = false;

  bool get isActive => _timer?.isActive ?? false;

  void run(DebouncedAction action) {
    if (_isDisposed) {
      return;
    }

    if (leading) {
      if (isActive) {
        return;
      }

      action();
      _timer = Timer(duration, _clearTimer);
      return;
    }

    _timer?.cancel();
    _timer = Timer(duration, () {
      _clearTimer();
      action();
    });
  }

  void cancel() {
    _timer?.cancel();
    _clearTimer();
  }

  void dispose() {
    cancel();
    _isDisposed = true;
  }

  void _clearTimer() {
    _timer = null;
  }
}

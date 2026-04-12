import 'package:feature_market/data/exception/market_data_exception.dart';
import 'package:feature_market/domain/failure/market_failure.dart';

mixin class MarketRepositoryErrorHandler {
  Future<T> guardMarketRequest<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on MarketDataException catch (error) {
      throw MarketFailure(error.message);
    } catch (_) {
      throw MarketFailure(fallbackMessage);
    }
  }
}

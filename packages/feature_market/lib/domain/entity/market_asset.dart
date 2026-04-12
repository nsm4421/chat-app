import 'package:freezed_annotation/freezed_annotation.dart';

part 'market_asset.freezed.dart';

@freezed
class MarketAsset with _$MarketAsset {
  const MarketAsset({
    required this.id,
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.displayName,
    required this.exchange,
    this.isActive = true,
  });

  @override
  final String id;

  @override
  final String symbol;

  @override
  final String baseAsset;

  @override
  final String quoteAsset;

  @override
  final String displayName;

  @override
  final String exchange;

  @override
  final bool isActive;
}

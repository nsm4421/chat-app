final class IngestReplayDayCommand {
  IngestReplayDayCommand({
    required DateTime referenceDate,
    required this.exchange,
    required this.quoteAsset,
    this.sourceMarketDate,
    this.symbols,
    this.marketLimit = 20,
    this.minuteUnit = 1,
  }) : referenceDate = DateTime.utc(
         referenceDate.year,
         referenceDate.month,
         referenceDate.day,
       );

  final DateTime referenceDate;
  final String exchange;
  final String quoteAsset;
  final DateTime? sourceMarketDate;
  final List<String>? symbols;
  final int marketLimit;
  final int minuteUnit;

  DateTime resolveSourceMarketDate() {
    final date =
        sourceMarketDate ?? referenceDate.subtract(const Duration(days: 1));
    return DateTime.utc(date.year, date.month, date.day);
  }
}

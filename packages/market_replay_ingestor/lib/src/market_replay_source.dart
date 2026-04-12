import 'ingest_replay_day_command.dart';
import 'market_replay_models.dart';

abstract interface class MarketReplaySource {
  Future<SourceReplayDayBundle> fetchReplayDay(IngestReplayDayCommand command);
}

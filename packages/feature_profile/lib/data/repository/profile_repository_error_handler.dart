import 'package:feature_profile/data/exception/profile_data_exception.dart';
import 'package:feature_profile/domain/failure/profile_failure.dart';

mixin class ProfileRepositoryErrorHandler {
  Future<T> guardProfileRequest<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on ProfileDataException catch (error) {
      throw ProfileFailure(error.message);
    } catch (_) {
      throw ProfileFailure(fallbackMessage);
    }
  }
}

import 'package:domodachi/features/auth/domain/use_case/auth_use_cases.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_cubit.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteAccountCubit extends AuthRequestCubit {
  DeleteAccountCubit(this._authUseCases);

  final AuthUseCases _authUseCases;

  Future<void> deleteAccount() {
    return run(
      () => _authUseCases.deleteAccount(),
      successMessage: '계정이 삭제되었어요.',
    );
  }
}

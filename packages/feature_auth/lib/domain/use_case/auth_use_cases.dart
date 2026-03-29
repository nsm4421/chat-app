import 'package:feature_auth/domain/repository/auth_repository.dart';
import 'package:feature_auth/domain/use_case/scenario/delete_account_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/get_current_user_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/is_profile_complete_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/observe_auth_state_changes_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/send_password_reset_email_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/sign_in_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/sign_out_use_case.dart';
import 'package:feature_auth/domain/use_case/scenario/sign_up_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthUseCases {
  final AuthRepository _repository;

  AuthUseCases(this._repository);

  late final GetCurrentUserUseCase _currentUser = GetCurrentUserUseCase(
    _repository,
  );
  late final ObserveAuthStateChangesUseCase _observeAuthStateChanges =
      ObserveAuthStateChangesUseCase(_repository);
  late final IsProfileCompleteUseCase _isProfileComplete =
      IsProfileCompleteUseCase(_repository);
  late final SignInUseCase _signIn = SignInUseCase(_repository);
  late final SignUpUseCase _signUp = SignUpUseCase(_repository);
  late final SignOutUseCase _signOut = SignOutUseCase(_repository);
  late final DeleteAccountUseCase _deleteAccount = DeleteAccountUseCase(
    _repository,
  );
  late final SendPasswordResetEmailUseCase _sendPasswordResetEmail =
      SendPasswordResetEmailUseCase(_repository);

  GetCurrentUserUseCase get currentUser => _currentUser;
  ObserveAuthStateChangesUseCase get observeAuthStateChanges =>
      _observeAuthStateChanges;
  IsProfileCompleteUseCase get isProfileComplete => _isProfileComplete;
  SignInUseCase get signIn => _signIn;
  SignUpUseCase get signUp => _signUp;
  SignOutUseCase get signOut => _signOut;
  DeleteAccountUseCase get deleteAccount => _deleteAccount;
  SendPasswordResetEmailUseCase get sendPasswordResetEmail =>
      _sendPasswordResetEmail;
}

import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:domodachi/core/extensions/string_extension.dart';
import 'package:domodachi/core/widgets/debounce/debounced_buttons.dart';
import 'package:domodachi/core/widgets/profile_avatar.dart';
import 'package:domodachi/features/auth/domain/validation/auth_input_validator.dart';
import 'package:domodachi/features/auth/presentation/cubit/base/auth_request_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/profile_edit/profile_edit_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_state.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ProfileEditCubit>(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _didInitialize = false;
  bool _isPickingAvatar = false;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarExtension;

  @override
  void initState() {
    super.initState();
    _restoreLostAvatar();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = context.read<AuthSessionCubit>().state.maybeWhen(
      authenticated: (user) => user,
      profileIncomplete: (user) => user,
      orElse: () => null,
    );
    final initialUsername = (user?.username ?? '').trim();

    context.read<ProfileEditCubit>().submitProfile(
      initialUsername: initialUsername,
      username: _usernameController.text.trimmed,
      avatarBytes: _selectedAvatarBytes,
      avatarFileExtension: _selectedAvatarExtension,
    );
  }

  String? _validateUsername(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) {
      return '아이디를 입력해 주세요.';
    }
    return AuthInputValidator.username(username);
  }

  Future<void> _pickAvatar() async {
    if (_isPickingAvatar) {
      return;
    }

    setState(() => _isPickingAvatar = true);

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );
      if (picked == null || !mounted) {
        return;
      }

      await _applyPickedAvatar(picked);
    } on PlatformException catch (error) {
      _showMessage(error.message ?? '갤러리에서 사진을 불러오지 못했어요.');
    } catch (_) {
      _showMessage('프로필 사진을 선택하지 못했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) {
        setState(() => _isPickingAvatar = false);
      }
    }
  }

  Future<void> _restoreLostAvatar() async {
    try {
      final response = await _imagePicker.retrieveLostData();
      if (!mounted || response.isEmpty) {
        return;
      }

      final file = response.files?.firstOrNull;
      if (file != null) {
        await _applyPickedAvatar(file);
      } else if (response.exception != null) {
        _showMessage('이전 사진 선택을 복구하지 못했어요.');
      }
    } catch (_) {
      // Ignore restore failures and let the user retry manually.
    }
  }

  Future<void> _applyPickedAvatar(XFile picked) async {
    final bytes = await picked.readAsBytes();
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedAvatarBytes = bytes;
      _selectedAvatarExtension = _resolveFileExtension(picked);
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String? _resolveFileExtension(XFile picked) {
    final path = picked.path;
    final lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex < 0 || lastDotIndex == path.length - 1) {
      return null;
    }
    return path.substring(lastDotIndex + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return AuthRequestListener<ProfileEditCubit>(
      onSuccess: () {
        context.read<AuthSessionCubit>().refresh();
        context.pop();
      },
      child: BlocBuilder<AuthSessionCubit, AuthSessionState>(
        builder: (context, sessionState) {
          final user = sessionState.maybeWhen(
            authenticated: (user) => user,
            profileIncomplete: (user) => user,
            orElse: () => null,
          );

          if (!_didInitialize) {
            _usernameController.text = user?.username ?? '';
            _didInitialize = true;
          }

          final currentName = (user?.username ?? '').trim();
          final email = user?.email ?? '';
          final currentAvatarUrl = user?.avatarUrl;
          final normalizedInput = _usernameController.text.trim();
          final usernameValidation = _validateUsername(normalizedInput);
          final hasUsernameChanged = normalizedInput != currentName;
          final hasAvatarChanged = _selectedAvatarBytes != null;
          final canSubmit =
              (hasUsernameChanged || hasAvatarChanged) &&
              normalizedInput.isNotEmpty &&
              usernameValidation == null;

          return Scaffold(
            appBar: AppBar(
              title: const Text('프로필 수정'),
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _ProfileHero(
                    username: currentName.isEmpty ? 'guest' : currentName,
                    email: email,
                    avatarUrl: currentAvatarUrl,
                    selectedAvatarBytes: _selectedAvatarBytes,
                  ),
                  24.v,
                  Card(
                    child: Padding(
                      padding: 20.p,
                      child: BlocBuilder<ProfileEditCubit, AuthRequestState>(
                        builder: (context, requestState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '아이디',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              8.v,
                              Text(
                                '중복되지 않는 고유 아이디를 사용할 수 있어요.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              20.v,
                              OutlinedButton.icon(
                                onPressed:
                                    requestState.isLoading || _isPickingAvatar
                                    ? null
                                    : _pickAvatar,
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: Text(
                                  _isPickingAvatar
                                      ? '사진 불러오는 중...'
                                      : _selectedAvatarBytes == null
                                      ? '프로필 사진 선택'
                                      : '선택한 사진 변경',
                                ),
                              ),
                              10.v,
                              Text(
                                '갤러리에서 사진을 고르면 바로 미리보기에 반영돼요.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              20.v,
                              Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _usernameController,
                                  textCapitalization: TextCapitalization.none,
                                  autocorrect: false,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: '아이디',
                                    hintText: '예: domodachi_01',
                                  ),
                                  validator: _validateUsername,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                              ),
                              20.v,
                              DebouncedFilledButton(
                                onPressed:
                                    requestState.isLoading || !canSubmit
                                    ? null
                                    : _submit,
                                child: Text(
                                  requestState.isLoading ? '저장 중...' : '저장하기',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.username,
    required this.email,
    this.avatarUrl,
    this.selectedAvatarBytes,
  });

  final String username;
  final String email;
  final String? avatarUrl;
  final Uint8List? selectedAvatarBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            radius: 28,
            username: username,
            imageUrl: avatarUrl,
            memoryImageBytes: selectedAvatarBytes,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            textStyle: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          16.h,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  4.v,
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

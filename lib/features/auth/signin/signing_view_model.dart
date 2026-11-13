import '../../../core/network/api_result.dart';
import '../../../data/repository/auth_repository.dart';
import '../auth_event.dart';
import '../base_auth_view_model.dart';
import 'signing_ui_state.dart';

class SigningViewModel extends BaseAuthViewModel<SigningUiState> {
  SigningViewModel(this._repo) : super(const SigningUiState());

  final AuthRepository _repo;

  void onEmailChange(String v) => state = state.copyWith(email: v, error: null);

  void onPwdChange(String v) => state = state.copyWith(password: v, error: null);

  Future<void> login() async {
    state = state.copyWith(isLoading: true);
    final email = state.email.trim();

    final result = await _repo.login(email, state.password.trim());
    if (result case ApiError(:final message, :final code)) {
      state = state.copyWith(error: message);
      if (code == 'EMAIL_NOT_VERIFIED') emit(GoVerify(email));
    }
    // on success the session swap takes the user to their home graph

    state = state.copyWith(isLoading: false);
  }
}

import '../../../../core/storage/models/persisted_auth_session.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> persist(AuthSessionModel session) {
    return _tokenStorage.save(
      PersistedAuthSession(
        token: session.token,
        tokenType: session.tokenType,
        userJson: session.user.toJson(),
      ),
    );
  }

  Future<AuthSessionModel?> read() async {
    final persisted = await _tokenStorage.readSession();
    if (persisted == null) {
      return null;
    }

    return AuthSessionModel(
      token: persisted.token,
      tokenType: persisted.tokenType,
      user: AuthUserModel.fromJson(persisted.userJson),
    );
  }

  Future<void> updateUser(AuthUserModel user) async {
    final persisted = await _tokenStorage.readSession();
    if (persisted == null) {
      return;
    }

    await _tokenStorage.save(
      PersistedAuthSession(
        token: persisted.token,
        tokenType: persisted.tokenType,
        userJson: user.toJson(),
      ),
    );
  }

  Future<void> clear() {
    return _tokenStorage.clear();
  }
}

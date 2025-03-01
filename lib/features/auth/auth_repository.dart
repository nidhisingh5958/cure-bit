class AuthRepository {
  final AuthDataSource _authDataSource;

  AuthRepository(this._authDataSource);

  Future<User> login(String email, String password) async {
    return _authDataSource.login(email, password);
  }

  Future<void> logout() async {
    return _authDataSource.logout();
  }
}

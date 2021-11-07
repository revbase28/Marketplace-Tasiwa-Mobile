import 'package:zcart/data/models/user/user_model.dart';

abstract class IUserRepository {
  Future<User?> logIn(String username, String password);

  Future<User?> logInUsingGoogle(String accessToken);

  Future<User?> logInUsingFacebook(String accessToken);

  Future<User?> logInUsingApple(String accessToken);

  Future<User?> register(String name, email, password,
      bool agreeToTermsAndCondition, acceptMarkeing);

  Future logout();

  Future<User?> fetchUserInfo();

  Future<void> updateBasicInfo({
    required String fullName,
    required String nickName,
    required String bio,
    required dynamic dob,
    required String email,
  });

  Future updatePassword(
      String currentPassword, String newPassword, String confirmPassword);

  Future forgotPassword(String email);
}

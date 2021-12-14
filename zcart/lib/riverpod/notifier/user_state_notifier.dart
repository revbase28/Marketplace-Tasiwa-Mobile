import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/interface/i_user_repository.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/riverpod/state/user_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class UserNotifier extends StateNotifier<UserState> {
  final IUserRepository _iUserRepository;

  UserNotifier(this._iUserRepository) : super(const UserInitialState());

  Future<void> login(String username, String password) async {
    try {
      state = const UserLoadingState();
      final user = await _iUserRepository.logIn(username, password);
      state = UserLoadedState(user);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> loginUsingGoogle(String accessToken) async {
    try {
      state = const UserLoadingState();
      final user = await _iUserRepository.logInUsingGoogle(accessToken);
      state = UserLoadedState(user);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> loginUsingFacebook(String accessToken) async {
    try {
      state = const UserLoadingState();
      final user = await _iUserRepository.logInUsingFacebook(accessToken);
      state = UserLoadedState(user);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> loginUsingApple(String accessToken) async {
    try {
      state = const UserLoadingState();
      final user = await _iUserRepository.logInUsingApple(accessToken);
      state = UserLoadedState(user);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> register(String name, email, password,
      bool agreeToTermsAndCondition, acceptMarkeing) async {
    try {
      state = const UserLoadingState();
      final user = await _iUserRepository.register(
          name, email, password, agreeToTermsAndCondition, acceptMarkeing);
      state = UserLoadedState(user);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> logout() async {
    try {
      await _iUserRepository.logout();
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> getUserInfo() async {
    try {
      state = const UserLoadingState();
      final user = await _iUserRepository.fetchUserInfo();
      state = UserLoadedState(user);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> updateUserInfo(String fullName, String nickName, String bio,
      String email, dynamic dob) async {
    try {
      await _iUserRepository.updateBasicInfo(
          fullName: fullName,
          nickName: nickName,
          bio: bio,
          email: email,
          dob: dob);
    } on NetworkException {
      // state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> updatePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    try {
      await _iUserRepository.updatePassword(
          oldPassword, newPassword, confirmPassword);
    } on NetworkException {
      // state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _iUserRepository.forgotPassword(email);
    } on NetworkException {
      state = UserErrorState(LocaleKeys.something_went_wrong.tr());
    }
  }
}

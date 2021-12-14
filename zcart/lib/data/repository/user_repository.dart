import 'package:flutter/material.dart';
import 'package:zcart/data/interface/i_user_repository.dart';
import 'package:zcart/data/models/user/user_model.dart';
import 'package:zcart/helper/constants.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class UserRepository implements IUserRepository {
  /// Login user
  @override
  Future<User?> logIn(username, password) async {
    await setValue(loggedIn, false);

    var requestBody = {'email': username.trim(), 'password': password};
    dynamic responseBody;

    try {
      responseBody =
          await handleResponse(await postRequest(API.login, requestBody));
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    UserModel userModel = UserModel.fromJson(responseBody);

    toast(LocaleKeys.sign_in_successfull.tr());
    await setValue(loggedIn, true);
    await setValue(access, userModel.data!.apiToken);

    return userModel.data;
  }

  /// Login user Using Google
  @override
  Future<User?> logInUsingGoogle(String accessToken) async {
    await setValue(loggedIn, false);

    var requestBody = {'access_token': accessToken};
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await postRequest(API.loginUsingGoogle, requestBody));
    } catch (e) {
      throw NetworkException();
    }

    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    UserModel userModel = UserModel.fromJson(responseBody);

    toast(LocaleKeys.sign_in_successfull.tr());
    await setValue(loggedIn, true);
    await setValue(access, userModel.data!.apiToken);

    return userModel.data;
  }

  @override
  Future<User?> logInUsingFacebook(String accessToken) async {
    await setValue(loggedIn, false);

    var requestBody = {'access_token': accessToken};
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await postRequest(API.loginUsingFacebook, requestBody));
    } catch (e) {
      throw NetworkException();
    }

    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    UserModel userModel = UserModel.fromJson(responseBody);

    toast(LocaleKeys.sign_in_successfull.tr());
    await setValue(loggedIn, true);
    await setValue(access, userModel.data!.apiToken);

    return userModel.data;
  }

  @override
  Future<User?> logInUsingApple(String accessToken) async {
    await setValue(loggedIn, false);

    var requestBody = {'access_token': accessToken};
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await postRequest(API.loginUsingApple, requestBody));
    } catch (e) {
      throw NetworkException();
    }

    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    UserModel userModel = UserModel.fromJson(responseBody);

    toast(LocaleKeys.sign_in_successfull.tr());
    await setValue(loggedIn, true);
    await setValue(access, userModel.data!.apiToken);

    return userModel.data;
  }

  /// Register User
  @override
  Future<User?> register(String name, email, password,
      bool agreeToTermsAndCondition, acceptMarkeing) async {
    var requestBody = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'password_confirmation': password,
      'agree': agreeToTermsAndCondition.toString(),
      'accepts_marketing': acceptMarkeing.toString()
    };
    dynamic responseBody;

    try {
      responseBody =
          await handleResponse(await postRequest(API.register, requestBody));
    } catch (e) {
      debugPrint(e.toString());
      throw NetworkException();
    }

    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    UserModel userModel = UserModel.fromJson(responseBody);

    toast(LocaleKeys.register_successful.tr());
    await setValue(loggedIn, true);
    await setValue(access, userModel.data!.apiToken);
    return userModel.data;
  }

  @override
  Future logout() async {
    var requestBody = {};
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await postRequest(API.logout, requestBody, bearerToken: true));
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    toast(LocaleKeys.logged_out.tr());
    await getSharedPref().then((value) => value.clear());
  }

  /// Fetch user info
  @override
  Future<User?> fetchUserInfo() async {
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await getRequest(API.userInfo, bearerToken: true));
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    UserModel userModel = UserModel.fromJson(responseBody);

    return userModel.data;
  }

  /// Update user account
  @override
  Future<void> updateBasicInfo(
      {String? fullName,
      String? nickName,
      String? bio,
      dynamic dob,
      String? email}) async {
    var requestBody = {
      'name': fullName,
      'nice_name': nickName,
      'description': bio,
      'dob': dob,
      'email': email
    };
    dynamic responseBody;

    try {
      responseBody =
          await handleResponse(await putRequest(API.userInfo, requestBody));
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    toast(
      LocaleKeys.profile_updated_successfully.tr(),
    );
  }

  @override
  Future updatePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    var requestBody = {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': confirmPassword,
    };
    dynamic responseBody;

    try {
      responseBody = await handleResponse(
          await putRequest(API.updatePassword, requestBody));
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    toast(
      LocaleKeys.password_updated_successfully.tr(),
    );
  }

  @override
  Future forgotPassword(String email) async {
    var requestBody = {
      'email': email,
    };
    dynamic responseBody;

    try {
      responseBody =
          await handleResponse(await postRequest(API.forgot, requestBody));
    } catch (e) {
      throw NetworkException();
    }
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    toast(
      LocaleKeys.password_reset_link_sent.tr(),
    );
  }
}

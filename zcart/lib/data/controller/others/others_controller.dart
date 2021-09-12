import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/others/privacy_policy_state.dart';
import 'package:zcart/data/controller/others/terms_and_condition_state.dart';
import 'package:zcart/data/models/others/about_us_model.dart';
import 'package:zcart/data/models/others/privacy_policy_model.dart';
import 'package:zcart/data/models/others/terms_and_condition_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';
import 'about_us_state.dart';

final aboutUsProvider = StateNotifierProvider<AboutUsRepository, AboutUsState>(
    (ref) => AboutUsRepository());

class AboutUsRepository extends StateNotifier<AboutUsState> {
  AboutUsRepository() : super(const AboutUsInitialState());

  Future fetchAboutUs({bool update = false}) async {
    if (!update) state = const AboutUsLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await getRequest(API.aboutUs));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      AboutUsModel othersModel = AboutUsModel.fromJson(responseBody);
      state = AboutUsLoadedState(othersModel);
    } on NetworkException {
      state = const AboutUsErrorState("Failed to fetch data!");
    }
  }
}

final privacyPolicyProvider =
    StateNotifierProvider<PrivacyPolicyRepository, PrivacyPolicyState>(
        (ref) => PrivacyPolicyRepository());

class PrivacyPolicyRepository extends StateNotifier<PrivacyPolicyState> {
  PrivacyPolicyRepository() : super(const PrivacyPolicyInitialState());

  Future fetchPrivacyPolicy({bool update = false}) async {
    if (!update) state = const PrivacyPolicyLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await getRequest(API.privacyPolicy));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      PrivacyPolicyModel othersModel =
          PrivacyPolicyModel.fromJson(responseBody);
      state = PrivacyPolicyLoadedState(othersModel);
    } on NetworkException {
      state = const PrivacyPolicyErrorState("Failed to fetch data!");
    }
  }
}

final termsAndConditionProvider =
    StateNotifierProvider<TermsAndConditionRepository, TermsAndConditionState>(
        (ref) => TermsAndConditionRepository());

class TermsAndConditionRepository
    extends StateNotifier<TermsAndConditionState> {
  TermsAndConditionRepository() : super(const TermsAndConditionInitialState());

  Future fetchTermsAndCondition({bool update = false}) async {
    if (!update) state = const TermsAndConditionLoadingState();
    dynamic responseBody;
    try {
      responseBody =
          await handleResponse(await getRequest(API.termsAndCondition));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      TermsAndConditionModel othersModel =
          TermsAndConditionModel.fromJson(responseBody);
      state = TermsAndConditionLoadedState(othersModel);
    } on NetworkException {
      state = const TermsAndConditionErrorState("Failed to fetch data!");
    }
  }
}

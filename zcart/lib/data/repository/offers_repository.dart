import 'package:zcart/data/interface/i_offers_repository.dart';
import 'package:zcart/data/models/offers/offers_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

class OffersRepository implements IOffersRepository {
  @override
  Future<OffersModel> fetchOffersFromOtherSellers(String? slug) async {
    dynamic responseBody;
    responseBody =
        await handleResponse(await getRequest(API.offersFromOtherSeller(slug)));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }
    OffersModel offersModel = OffersModel.fromJson(responseBody);
    return offersModel;
  }
}

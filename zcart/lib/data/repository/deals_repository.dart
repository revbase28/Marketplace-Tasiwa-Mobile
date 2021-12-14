import 'package:zcart/data/interface/i_deals_repository.dart';
import 'package:zcart/data/models/deals/deal_of_the_day_model.dart';
import 'package:zcart/data/models/deals/deals_under_the_price_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

class DealsRepository extends IDealsRepository {
  @override
  Future<DealsUnderThePrice> fetchDealsUnderThePrice() async {
    var responseBody =
        await handleResponse(await getRequest(API.dealsUnderThePrice));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    DealsUnderThePrice dealsUnderThePrice =
        DealsUnderThePrice.fromMap(responseBody);
    return dealsUnderThePrice;
  }

  @override
  Future<DealOfTheDay> fetchDealOfTheDay() async {
    var responseBody = await handleResponse(await getRequest(API.dealOfTheDay));
    if (responseBody.runtimeType == int && responseBody > 206) {
      throw NetworkException();
    }

    DealOfTheDay dealOfTheDay = DealOfTheDay.fromMap(responseBody);
    return dealOfTheDay;
  }
}

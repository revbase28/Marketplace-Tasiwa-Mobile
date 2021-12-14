import 'package:zcart/data/models/deals/deal_of_the_day_model.dart';
import 'package:zcart/data/models/deals/deals_under_the_price_model.dart';

abstract class IDealsRepository {
  Future<DealsUnderThePrice> fetchDealsUnderThePrice();
  Future<DealOfTheDay> fetchDealOfTheDay();
}

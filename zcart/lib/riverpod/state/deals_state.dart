import 'package:zcart/data/models/deals/deal_of_the_day_model.dart';
import 'package:zcart/data/models/deals/deals_under_the_price_model.dart';

/// Deals under the price  State
abstract class DealsUnderThePriceState {
  const DealsUnderThePriceState();
}

class DealsUnderThePriceStateInitialState extends DealsUnderThePriceState {
  const DealsUnderThePriceStateInitialState();
}

class DealsUnderThePriceStateLoadingState extends DealsUnderThePriceState {
  const DealsUnderThePriceStateLoadingState();
}

class DealsUnderThePriceStateLoadedState extends DealsUnderThePriceState {
  final DealsUnderThePrice? dealsUnderThePrice;

  const DealsUnderThePriceStateLoadedState(this.dealsUnderThePrice);
}

class DealsUnderThePriceStateErrorState extends DealsUnderThePriceState {
  final String message;

  const DealsUnderThePriceStateErrorState(this.message);
}

/// Deals of the day State
abstract class DealOfTheDayState {
  const DealOfTheDayState();
}

class DealOfTheDayStateInitialState extends DealOfTheDayState {
  const DealOfTheDayStateInitialState();
}

class DealOfTheDayStateLoadingState extends DealOfTheDayState {
  const DealOfTheDayStateLoadingState();
}

class DealOfTheDayStateLoadedState extends DealOfTheDayState {
  final DealOfTheDay? dealOfTheDay;

  const DealOfTheDayStateLoadedState(this.dealOfTheDay);
}

class DealOfTheDayStateErrorState extends DealOfTheDayState {
  final String message;

  const DealOfTheDayStateErrorState(this.message);
}

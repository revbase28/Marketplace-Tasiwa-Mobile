
import 'package:zcart/data/models/address/city_model.dart';

abstract class CityState {
  const CityState();
}

class CityInitialState extends CityState {
  const CityInitialState();
}

class CityLoadingState extends CityState {
  const CityLoadingState();
}

class CityLoadedState extends CityState {
  final List<City>? cityList;

  const CityLoadedState(this.cityList);
}

class CityErrorState extends CityState {
  final String message;

  const CityErrorState(this.message);
}

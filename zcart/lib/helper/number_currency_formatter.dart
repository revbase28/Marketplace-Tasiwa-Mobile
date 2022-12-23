
import 'package:zcart/riverpod/notifier/notifier.dart';

String formatCurrency(String symbol, String price, {String pattern= 'id_ID'}){
  var currencyFormat = NumberFormat.decimalPattern(pattern);
  return "$symbol ${currencyFormat.format(double.parse(price))}";
}
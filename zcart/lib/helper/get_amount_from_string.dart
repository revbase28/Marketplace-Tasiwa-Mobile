int getAmountFromString(String amount) {
  var l = amount.split("");

  if (l.contains(".")) {
    int _index = l.indexOf(".");

    l = l.sublist(0, _index + 3);
  }

  String value = "";
  List newL = [];

  for (var i = 0; i < l.length; i++) {
    int? _value = int.tryParse(l[i]);

    if (_value.runtimeType == int) {
      newL.add(l[i]);
    }
  }

  for (var item in newL) {
    value = value + item.toString();
  }

  return int.parse(value);
}

double getDoubleAmountFromString(String amount) {
  return getAmountFromString(amount) / 100;
}

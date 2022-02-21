import 'dart:convert';

SystemConfig systemConfigFromJson(String str) =>
    SystemConfig.fromJson(json.decode(str));

String systemConfigToJson(SystemConfig data) => json.encode(data.toJson());

class SystemConfig {
  SystemConfig({this.data});

  ConfigData? data;

  factory SystemConfig.fromJson(Map<String, dynamic> json) =>
      SystemConfig(data: ConfigData.fromJson(json["data"]));

  Map<String, dynamic> toJson() =>
      {"data": data == null ? null : data!.toJson()};
}

class ConfigData {
  ConfigData({
    this.maintenanceMode,
    this.installVerion,
    this.name,
    this.slogan,
    this.legalName,
    this.email,
    this.worldwideBusinessArea,
    this.timezoneId,
    this.currencyId,
    this.defaultLanguage,
    this.askCustomerForEmailSubscription,
    this.canCancelOrderWithin,
    this.supportPhone,
    this.supportPhoneTollFree,
    this.supportEmail,
    this.facebookLink,
    this.googlePlusLink,
    this.twitterLink,
    this.pinterestLink,
    this.instagramLink,
    this.youtubeLink,
    this.lengthUnit,
    this.weightUnit,
    this.valumeUnit,
    this.decimals,
    this.showCurrencySymbol,
    this.showSpaceAfterSymbol,
    this.maxImgSizeLimitKb,
    this.showItemConditions,
    this.addressDefaultCountry,
    this.addressDefaultState,
    this.showAddressTitle,
    this.addressShowCountry,
    this.addressShowMap,
    this.allowGuestCheckout,
    this.enableChat,
    this.currency,
  });

  bool? maintenanceMode;
  String? installVerion;
  String? name;
  dynamic slogan;
  String? legalName;
  String? email;
  bool? worldwideBusinessArea;
  int? timezoneId;
  int? currencyId;
  String? defaultLanguage;
  bool? askCustomerForEmailSubscription;
  int? canCancelOrderWithin;
  dynamic supportPhone;
  dynamic supportPhoneTollFree;
  String? supportEmail;
  String? facebookLink;
  String? googlePlusLink;
  String? twitterLink;
  String? pinterestLink;
  String? instagramLink;
  String? youtubeLink;
  String? lengthUnit;
  String? weightUnit;
  String? valumeUnit;
  String? decimals;
  bool? showCurrencySymbol;
  bool? showSpaceAfterSymbol;
  int? maxImgSizeLimitKb;
  bool? showItemConditions;
  int? addressDefaultCountry;
  int? addressDefaultState;
  bool? showAddressTitle;
  bool? addressShowCountry;
  bool? addressShowMap;
  bool? allowGuestCheckout;
  bool? enableChat;
  Currency? currency;

  factory ConfigData.fromJson(Map<String, dynamic> json) => ConfigData(
        maintenanceMode: json["maintenance_mode"],
        installVerion: json["install_verion"],
        name: json["name"],
        slogan: json["slogan"],
        legalName: json["legal_name"],
        email: json["email"],
        worldwideBusinessArea: json["worldwide_business_area"],
        timezoneId: json["timezone_id"],
        currencyId: json["currency_id"],
        defaultLanguage: json["default_language"],
        askCustomerForEmailSubscription:
            json["ask_customer_for_email_subscription"],
        canCancelOrderWithin: json["can_cancel_order_within"],
        supportPhone: json["support_phone"],
        supportPhoneTollFree: json["support_phone_toll_free"],
        supportEmail: json["support_email"],
        facebookLink: json["facebook_link"],
        googlePlusLink: json["google_plus_link"],
        twitterLink: json["twitter_link"],
        pinterestLink: json["pinterest_link"],
        instagramLink: json["instagram_link"],
        youtubeLink: json["youtube_link"],
        lengthUnit: json["length_unit"],
        weightUnit: json["weight_unit"],
        valumeUnit: json["valume_unit"],
        decimals: json["decimals"],
        showCurrencySymbol: json["show_currency_symbol"],
        showSpaceAfterSymbol: json["show_space_after_symbol"],
        maxImgSizeLimitKb: json["max_img_size_limit_kb"],
        showItemConditions: json["show_item_conditions"],
        addressDefaultCountry: json["address_default_country"],
        addressDefaultState: json["address_default_state"],
        showAddressTitle: json["show_address_title"],
        addressShowCountry: json["address_show_country"],
        addressShowMap: json["address_show_map"],
        allowGuestCheckout: json["allow_guest_checkout"],
        enableChat: json["enable_chat"],
        currency: Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
        "maintenance_mode": maintenanceMode,
        "install_verion": installVerion,
        "name": name,
        "slogan": slogan,
        "legal_name": legalName,
        "email": email,
        "worldwide_business_area": worldwideBusinessArea,
        "timezone_id": timezoneId,
        "currency_id": currencyId,
        "default_language": defaultLanguage,
        "ask_customer_for_email_subscription": askCustomerForEmailSubscription,
        "can_cancel_order_within": canCancelOrderWithin,
        "support_phone": supportPhone,
        "support_phone_toll_free": supportPhoneTollFree,
        "support_email": supportEmail,
        "facebook_link": facebookLink,
        "google_plus_link": googlePlusLink,
        "twitter_link": twitterLink,
        "pinterest_link": pinterestLink,
        "instagram_link": instagramLink,
        "youtube_link": youtubeLink,
        "length_unit": lengthUnit,
        "weight_unit": weightUnit,
        "valume_unit": valumeUnit,
        "decimals": decimals,
        "show_currency_symbol": showCurrencySymbol,
        "show_space_after_symbol": showSpaceAfterSymbol,
        "max_img_size_limit_kb": maxImgSizeLimitKb,
        "show_item_conditions": showItemConditions,
        "address_default_country": addressDefaultCountry,
        "address_default_state": addressDefaultState,
        "show_address_title": showAddressTitle,
        "address_show_country": addressShowCountry,
        "address_show_map": addressShowMap,
        "allow_guest_checkout": allowGuestCheckout,
        "enable_chat": enableChat,
        "currency": currency == null ? null : currency!.toJson(),
      };
}

class Currency {
  Currency({
    this.name,
    this.isoCode,
    this.symbol,
    this.symbolFirst,
    this.subunit,
    this.decimalMark,
    this.thousandsSeparator,
  });

  String? name;
  String? isoCode;
  String? symbol;
  bool? symbolFirst;
  String? subunit;
  String? decimalMark;
  String? thousandsSeparator;

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        name: json["name"],
        isoCode: json["iso_code"],
        symbol: json["symbol"],
        symbolFirst: json["symbol_first"],
        subunit: json["subunit"],
        decimalMark: json["decimal_mark"],
        thousandsSeparator: json["thousands_separator"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "iso_code": isoCode,
        "symbol": symbol,
        "symbol_first": symbolFirst,
        "subunit": subunit,
        "decimal_mark": decimalMark,
        "thousands_separator": thousandsSeparator,
      };
}

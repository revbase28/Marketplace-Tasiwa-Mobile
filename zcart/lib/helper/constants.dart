//Don't change anything here

import 'dart:io';

/// Shared Pref
const String access = 'ACCESS';
const String loggedIn = 'LOGGED_IN';

///Hive
const String hiveBox = 'hive_box';
const String recentlyReviewedIds = 'recently_reviewed_ids';

//Compatible API Version
const String apiVersion = '2.5.1';

/// Implemented payment methods

const String cod = 'cod';
const String wire = 'wire';
const String stripe = 'stripe';
const String paystack = 'paystack';
const String paypal = 'paypal-express';
const String razorpay = 'razorpay';
const String zcartWallet = 'zcart-wallet';

final List<String> paymentMethods = [
  cod,
  wire,
  stripe,
  paystack,
  paypal,
  zcartWallet,
  if (Platform.isAndroid) razorpay
];

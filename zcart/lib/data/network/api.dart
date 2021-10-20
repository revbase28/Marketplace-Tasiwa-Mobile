class API {
  //Change these values as your app requires
  static const String appName = "zCart";
  static const String appUrl = "https://zcart.incevio.com";

  /// Base URL
  //Change the base URL to point to your own API server.
  static const test = 'https://test.incevio.cloud/api/';
  static const live = 'https://zcart.incevio.com/api/';
  static const staging = 'https://staging.incevio.cloud/api/';

  //Point the API to the base URL
  static const base = test;

  /// Payment Gateway Keys

  //Change these values as your app requires

  // Paystack Configs
  static const String paystackKey =
      'pk_test_4b0bfd886ad641c03fc008017c0f127adb3eecb3';

  static const String paystackCurrency = "ZAR";

  //Paypal Configs

  static const bool paypalSandboxMode = true;
  static const String paypalTransactionDescription = "Payment for ZCart";
  static const String payPalCurrency = "USD";
  static const String paypalClientId =
      "AT1_wwlwFHefidTjEF4DYzjOVoI7ZK66ib1zlVA0YZUPuNj4D4IG_0Sxmto5Q6leByaxgdbHi-KkkaHz";

  static const String paypalClientSecret =
      "EO4T0rY9u0gcKlegpW8nGKoXS1QjUNHLlfgcGPjW5Sv5r7o7gMPVMaPAfGgmqbQWo7UB8OSG2Fgb2Nkt";

  //

  //

  //

  //Don't change anything below this line

  /// User
  static const register = 'auth/register';
  static const login = 'auth/login';
  static const loginUsingGoogle = 'auth/social/google';
  static const loginUsingFacebook = 'auth/social/facebook';
  static const logout = 'auth/logout';
  static const userInfo = 'account/update';
  static const updatePassword = 'password/update';

  /// Forgot password & Reset
  static const forgot = 'auth/forgot';
  static const resetPasswordToken = 'auth/reset/token';
  static const resetPassword = 'auth/reset';

  /// Category
  static const category = 'category-grps';

  static categoryItem(String? slug) => 'listing$slug';

  static categorySubgroup(String categoryID) => 'category-subgrps/$categoryID';

  static subgroupCategory(String subgroupID) => 'categories/$subgroupID';

  /// Banner
  static const banner = 'banners';

  /// Slider
  static const slider = 'sliders';

  /// Tending Now
  static const trending = 'listings/trending';

  /// Recently Added Item
  static const latest = 'listings/latest';

  /// Popular Items
  static const popular = 'listings/popular';

  /// Random Items
  static const random = 'listings/random';

  /// Recently Viewed Items
  static const recentlyViewed = 'recently_viewed_items';

  /// Shops
  static const vendors = 'shops';

  static vendorDetails(String? slug) => 'shop/$slug';

  static vendorItem(String? slug) => 'shop/$slug/listings';

  static vendorFeedback(String slug) => 'shop/$slug/feedbacks';

  ///Brands
  static const brands = 'brands';

  static const featuredBrands = 'brands/featured';

  static brandProfile(String? slug) => 'brand/$slug';

  static brandItems(String? slug) => 'brand/$slug/listings';

  ///DEALS

  static const dealsUnderThePrice = 'deals/under-the-price';
  static const dealOfTheDay = 'deals/deal-of-the-day';

  /// Product Details
  static productDetails(String? slug) => 'listing/$slug';

  static productVariantDetails(String? slug) => 'variant/$slug';

  static productList(String slug) => 'listing/$slug';

  static offersFromOtherSeller(String? slug) => 'offers/$slug';

  /// Search
  static search(String searchedItem) => 'search/$searchedItem';

  /// Carts
  static const carts = 'carts';

  static cartItemDetails(cartId) => 'cart/$cartId';

  static addToCart(String? slug) => 'addToCart/$slug';

  static updateCart(int? itemID) => 'cart/$itemID/update';

  static removeCart(cart, item) => 'cart/removeItem?cart=$cart&item=$item';

  static const coupons = 'coupons';

  /// Coupon
  static applyCoupon(cartId, coupon) =>
      'cart/$cartId/applyCoupon?coupon=$coupon';

  /// Checkout
  static checkout(cartId) => 'cart/$cartId/checkout';

  /// Order
  static const orders = 'orders';

  static order(orderId) => 'order/$orderId';

  static orderReceived(orderId) => 'order/$orderId/goodsReceived';

  /// Wish List
  static const wishList = 'wishlist';

  static addToWishList(String? slug) => 'wishlist/$slug/add';

  static removeFromWishList(int? id) => 'wishlist/$id/remove';

  /// Address
  static const addresses = 'addresses';
  static const createAddress = 'address/store';

  static editAddress(addressId) => 'address/$addressId';
  static deleteAddress(addressId) => 'address/$addressId';

  /// Countries
  static const countries = 'countries';

  /// States
  static states(countryId) => 'states/$countryId';

  /// Packaging
  static packaging(shopSlug) => 'packaging/$shopSlug';

  /// Shipping options
  static shipping(shopId, zoneId) => 'shipping/$shopId?zone=$zoneId';

  static shippingOptions(id) => 'listing/$id/shipTo';

  /// Payment options
  static paymentOptions(cartId) => 'cart/$cartId/paymentOptions';

  /// Dispute
  static const disputes = 'disputes';

  static disputeInfo(orderId) => 'order/$orderId/dispute';
  static disputeDetails(disputeId) => 'dispute/$disputeId';

  static openDispute(orderId) => 'order/$orderId/dispute';
  static markAsSolved(disputeId) => 'dispute/$disputeId/solved';

  static getDisputeResponse(disputeId) => 'dispute/$disputeId/response';
  static responseDispute(disputeId) => 'dispute/$disputeId/response';
  static appealDispute(disputeId) => 'dispute/$disputeId/appeal';

  /// Blog
  static const blogs = 'blogs';
  static blog(slug) => 'blog/$slug';

  /// Feedback
  static sellerFeedback(orderId) => 'shop/$orderId/feedback';
  static productFeedback(orderId) => 'order/$orderId/feedback';

  /// Order - Chat
  static orderConversation(orderId) => 'order/$orderId/conversation';
  static orderSendMessage(orderId) => 'order/$orderId/conversation';

  /// Product - Chat
  static productConversation(shopId) => 'shop/$shopId/contact';
  static productSendMessage(shopId) => 'shop/$shopId/contact';

  /// Conversation
  static const conversations = 'conversations';

  ///Others
  static const aboutUs = 'page/about-us';
  static const privacyPolicy = 'page/privacy-policy';
  static const termsAndCondition = 'page/terms-of-use-merchant';
}

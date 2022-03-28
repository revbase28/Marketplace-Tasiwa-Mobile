import 'package:zcart/config/config.dart';

class API {
  API._();
  static const String appName = MyConfig.appName;
  static const String appUrl = MyConfig.appUrl;

  /// Base URL
  //Point the API to the base URL
  static const base = MyConfig.appApiUrl;

  //

  //

  //

  /// User
  static const register = 'auth/register';
  static const login = 'auth/login';
  static const loginUsingGoogle = 'auth/social/google';
  static const loginUsingFacebook = 'auth/social/facebook';
  static const loginUsingApple = 'auth/social/apple';
  static const logout = 'auth/logout';
  static const userInfo = 'account/update';
  static const dashboard = 'dashboard';
  static const updatePassword = 'password/update';

  /// Forgot password & Reset
  static const forgot = 'auth/forgot';
  static const resetPasswordToken = 'auth/reset/token';
  static const resetPassword = 'auth/reset';

  /// Category
  static const allCategoryGroups = 'category-grps';

  static categorySubgroupOfGroups(String categoryGroupId) =>
      'category-subgrps/$categoryGroupId';

  static categoriesOfSubGroups(String subgroupID) => 'categories/$subgroupID';

  static categoryItem(String? slug) => 'listing$slug';

  static const String featuredCategories = "featured-categories";

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
  static productReviews(String? slug) => "listing/$slug/feedbacks";

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
  static const checkoutAll = "cart/checkout_all";

  /// Order
  static const orders = 'orders';

  static order(orderId) => 'order/$orderId';

  static orderReceived(orderId) => 'order/$orderId/goodsReceived';

  static String downloadOrderInvoice(int orderId) =>
      "download/invoice/$orderId";

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

  static shippingOptions(int id) => 'listing/$id/shipTo';
  static shippingOptionsForCart(int cartId) => 'cart/$cartId/shipping';

  /// Payment options
  static paymentOptions(cartId) => 'cart/$cartId/paymentOptions';

  ///Payment Method Credentials
  static paymentMethodCredential(String paymentMethodCode) =>
      'payment/$paymentMethodCode/credential';

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

  ///Plugins
  static checkPluginAvailability(pluginSlug) => 'plugin/$pluginSlug';
  static const flashDealPlugin = "deals/flash-deals";

  ///Wallet
  static const walletBalance = "wallet";
  static const walletTransactions = "wallet/transactions";
  static const walletTransfer = "wallet/transfer";
  static const walletPaymentMethods = "wallet/get_payment_methods";
  static const walletDeposit = "wallet/deposit";
  static String walletInvoice(int transactionId) =>
      "wallet/transaction/$transactionId/invoice";

  ///Others
  static const systemConfig = "system_configs";
  static const aboutUs = 'page/about-us';
  static const privacyPolicy = 'page/privacy-policy';
  static const termsAndCondition = 'page/terms-of-use-merchant';
}

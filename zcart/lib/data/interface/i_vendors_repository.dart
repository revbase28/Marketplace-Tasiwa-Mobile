import 'package:zcart/data/models/vendors/vendor_details_model.dart';
import 'package:zcart/data/models/vendors/vendor_items_model.dart';
import 'package:zcart/data/models/vendors/vendor_reviews_model.dart';
import 'package:zcart/data/models/vendors/vendors_model.dart';

abstract class IVendorsRepository {
  Future<List<VendorsList>?> fetchVendorsList();
  Future<VendorDetails?> fetchVendorDetails(String? slug);

  /// Fetch Items under vendor
  Future<List<VendorItemList>?> fetchVendorItemList(String? slug);
  Future<List<VendorItemList>?> fetchMoreVendorItemList();
}

abstract class IVendorReviewsRepository {
  Future<List<VendorReview>> fetchVendorReviews(String slug);
  Future<List<VendorReview>> fetchMoreVendorReviews();
}

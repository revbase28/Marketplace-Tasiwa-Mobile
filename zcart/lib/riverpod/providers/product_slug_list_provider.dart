// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final productSlugListProvider =
//     StateNotifierProvider<ProductSlugListNotifier, List<String?>>(
//         (ref) => ProductSlugListNotifier());

// class ProductSlugListNotifier extends StateNotifier<List<String?>> {
//   ProductSlugListNotifier() : super([]);

//   addProductSlug(String? slug) {
//     state.add(slug);

//     debugPrint("Addition: $state");
//   }

//   removeProductSlug() {
//     state.removeLast();
//     debugPrint("Remove: $state");
//   }
// }

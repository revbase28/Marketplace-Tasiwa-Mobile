/*Provider*/
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/blog/blog_state.dart';
import 'package:zcart/data/models/blog/blog_list_model.dart';
import 'package:zcart/data/models/blog/blog_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

/*Provider*/
final blogsProvider = StateNotifierProvider<BlogsRepository, BlogsState>(
    (ref) => BlogsRepository());
final blogProvider =
    StateNotifierProvider<BlogRepository, BlogState>((ref) => BlogRepository());

/*Repository & Notifier class Combined*/

/// Blog list
class BlogsRepository extends StateNotifier<BlogsState> {
  BlogsRepository() : super(const BlogsInitialState());

  Future blogs() async {
    state = const BlogsLoadingState();

    dynamic responseBody;
    try {
      responseBody = await handleResponse(await getRequest(API.blogs));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      BlogsModel blogsModel = BlogsModel.fromJson(responseBody);

      state = BlogsLoadedState(blogsModel.data);
    } on NetworkException {
      state = const BlogsErrorState("Failed to fetch blog data!");
    }
  }
}

/// Blog details
class BlogRepository extends StateNotifier<BlogState> {
  BlogRepository() : super(const BlogInitialState());

  Future blog(slug) async {
    state = const BlogLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await getRequest(API.blog(slug)));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      BlogModel blogModel = BlogModel.fromJson(responseBody);

      state = BlogLoadedState(blogModel.data);
    } on NetworkException {
      state = const BlogErrorState("Failed to fetch blog data!");
    }
  }
}

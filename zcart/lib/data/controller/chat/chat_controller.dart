import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/chat/chat_state.dart';
import 'package:zcart/data/models/chat/conversation/conversation_model.dart';
import 'package:zcart/data/models/chat/order/order_chat_model.dart';
import 'package:zcart/data/models/chat/product/product_chat_model.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/data/network/network_exception.dart';
import 'package:zcart/data/network/network_utils.dart';

/*Order - Chat*/
final orderChatProvider =
    StateNotifierProvider<OrderChatRepository, OrderChatState>(
        (ref) => OrderChatRepository());
final orderChatSendProvider =
    StateNotifierProvider<OrderChatSendRepository, OrderChatSendState>(
        (ref) => OrderChatSendRepository());

class OrderChatRepository extends StateNotifier<OrderChatState> {
  OrderChatRepository() : super(const OrderChatInitialState());

  Future orderConversation(orderId, {bool update = false}) async {
    if (!update) state = const OrderChatLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(
          await getRequest(API.orderConversation(orderId), bearerToken: true));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();

      if (responseBody['message'] == null) {
        OrderChatModel orderChatModel = OrderChatModel.fromJson(responseBody);
        state = OrderChatLoadedState(orderChatModel);
      } else {
        OrderChatInitialModel orderChatInitialModel =
            OrderChatInitialModel.fromJson(responseBody);
        state = OrderChatInitialLoadedState(orderChatInitialModel);
      }
    } on NetworkException {
      state = const OrderChatErrorState("Failed to fetch chat!");
    }
  }
}

class OrderChatSendRepository extends StateNotifier<OrderChatSendState> {
  OrderChatSendRepository() : super(const OrderChatSendInitialState());

  Future sendMessage(orderId, String message, {photo}) async {
    var body = {'message': message, if (photo != null) 'photo': photo};
    state = const OrderChatSendLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await postRequest(
        API.orderSendMessage(orderId),
        body,
        bearerToken: true,
      ));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      state = const OrderChatSendLoadedState();
    } on NetworkException {
      state = const OrderChatSendErrorState("Failed to fetch chat!");
    }
  }
}

/*Product- Chat*/
final productChatProvider =
    StateNotifierProvider<ProductChatRepository, ProductChatState>(
        (ref) => ProductChatRepository());
final productChatSendProvider =
    StateNotifierProvider<ProductChatSendRepository, ProductChatSendState>(
        (ref) => ProductChatSendRepository());

class ProductChatRepository extends StateNotifier<ProductChatState> {
  ProductChatRepository() : super(const ProductChatInitialState());

  Future productConversation(shopId, {bool update = false}) async {
    if (!update) state = const ProductChatLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(
          await getRequest(API.productConversation(shopId), bearerToken: true));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      if (responseBody['message'] == null) {
        ProductChatModel productChatModel =
            ProductChatModel.fromJson(responseBody);

        state = ProductChatLoadedState(productChatModel);
      } else {
        ProductChatInitialModel productChatInitialModel =
            ProductChatInitialModel.fromJson(responseBody);
        state = ProductChatInitialLoadedState(productChatInitialModel);
      }
    } on NetworkException {
      state = const ProductChatErrorState("Failed to fetch chat!");
    }
  }
}

class ProductChatSendRepository extends StateNotifier<ProductChatSendState> {
  ProductChatSendRepository() : super(const ProductChatSendInitialState());

  Future sendMessage(shopId, message, {photo}) async {
    var body = {'message': message, if (photo != null) 'photo': photo};
    state = const ProductChatSendLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(await postRequest(
        API.productSendMessage(shopId),
        body,
        bearerToken: true,
      ));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();
      state = const ProductChatSendLoadedState();
    } on NetworkException {
      state = const ProductChatSendErrorState("Failed to fetch chat!");
    }
  }
}

/*Conversation*/
final conversationProvider =
    StateNotifierProvider<ConversationRepository, ConversationState>((ref) {
  return ConversationRepository();
});

class ConversationRepository extends StateNotifier<ConversationState> {
  ConversationRepository() : super(const ConversationInitialState());

  Future conversation({bool update = false}) async {
    if (!update) state = const ConversationLoadingState();
    dynamic responseBody;
    try {
      responseBody = await handleResponse(
          await getRequest(API.conversations, bearerToken: true));
      if (responseBody is int) if (responseBody > 206) throw NetworkException();

      ConversationModel conversationModel =
          ConversationModel.fromJson(responseBody);
      state = ConversationLoadedState(conversationModel);
    } on NetworkException {
      state = const ConversationErrorState("Failed to fetch chat!");
    }
  }
}

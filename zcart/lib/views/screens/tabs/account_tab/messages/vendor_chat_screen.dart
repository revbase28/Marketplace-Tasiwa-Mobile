import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/controller/chat/chat_state.dart';
import 'package:zcart/data/models/chat/product/product_chat_model.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class VendorChatScreen extends StatelessWidget {
  final int? shopId;
  final String? shopImage;
  final String? shopName;
  final String? shopVerifiedText;
  VendorChatScreen({
    Key? key,
    required this.shopId,
    required this.shopImage,
    required this.shopName,
    required this.shopVerifiedText,
  }) : super(key: key);

  /// Controller
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                ? kDarkCardBgColor
                : kLightColor,
        flexibleSpace: SafeArea(
          child: Container(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),

                const SizedBox(width: 20),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.network(
                    shopImage!,
                    errorBuilder:
                        (BuildContext _, Object error, StackTrace? stack) {
                      return Container();
                    },
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        shopName!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        shopVerifiedText!,
                        style: context.textTheme.caption!
                            .copyWith(color: kFadeColor),
                      ),
                    ],
                  ),
                ),
                //Icon(Icons.settings, color: kDarkColor54),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await context
                    .read(productChatProvider.notifier)
                    .productConversation(shopId, update: true);
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: SafeArea(child: _chatBody(context)),
    );
  }

  Widget _chatBody(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
      },
      child: Column(
        children: [
          Expanded(
            child: Consumer(builder: (context, watch, _) {
              final _productChatState = watch(productChatProvider);
              return _productChatState is ProductChatInitialLoadedState
                  ? Center(
                      child: Text(
                        _productChatState.productChatModel.message!,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _productChatState is ProductChatLoadedState
                      ? _chatLoadedBody(context, _productChatState)
                      : const LoadingWidget();
            }),
          ),
          _chatTextBox(context),
        ],
      ),
    );
  }

  Padding _chatTextBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {
              //TODO: Attach Images
            },
            icon: Icon(Icons.add, color: kPrimaryColor),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: kAccentColor),
                color: EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                    ? kDarkCardBgColor
                    : kLightColor,
              ),
              child: TextField(
                controller: messageController,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8),
                  border: InputBorder.none,
                  hintText: LocaleKeys.type_a_message.tr(),
                  hintStyle: context.textTheme.caption,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          IconButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                String message = messageController.text.trim();
                messageController.clear();
                context
                    .read(productChatSendProvider.notifier)
                    .sendMessage(
                        //TODO: Send attachement
                        shopId,
                        message)
                    .then(
                  (value) {
                    messageController.clear();
                    context
                        .read(productChatProvider.notifier)
                        .productConversation(shopId, update: true);
                  },
                );
              } else {
                toast(LocaleKeys.empty_message.tr());
              }
            },
            icon: Icon(Icons.send, color: kPrimaryColor),
          )
        ],
      ),
    );
  }

  Widget _chatLoadedBody(
      BuildContext context, ProductChatLoadedState productChatState) {
    List<Reply> _messageList = productChatState.productChatModel.data!.replies!;
    List<Reply> _reversedMessageList = _messageList.reversed.toList();
    return Container(
      child: productChatState.productChatModel.data!.replies!.isEmpty
          ? Column(
              children: [
                FirstMessageBox(
                  productChatModel: productChatState.productChatModel,
                ).py(10),
                const Expanded(child: SizedBox()),
              ],
            )
          : ListView(
              shrinkWrap: true,
              reverse: true,
              children: _reversedMessageList.map((message) {
                return Column(
                  children: [
                    Visibility(
                      visible: _messageList.indexOf(message) == 0,
                      child: FirstMessageBox(
                        productChatModel: productChatState.productChatModel,
                      ).py(10),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, bottom: 5),
                      child: Align(
                        alignment: (message.customer == null
                            ? Alignment.topLeft
                            : Alignment.topRight),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: context.screenWidth * 0.75),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: (message.customer == null
                                ? EasyDynamicTheme.of(context).themeMode ==
                                        ThemeMode.dark
                                    ? kDarkCardBgColor
                                    : Colors.grey.shade200
                                : kPrimaryColor.withOpacity(0.1)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: message.customer == null
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              //TODO: Send Attachement
                              message.attachments!.isEmpty
                                  ? const SizedBox()
                                  : Text(message.attachments.toString()),
                              HtmlWidget(
                                message.reply!,
                                onTapUrl: (url) {
                                  launchURL(url);
                                  return true;
                                },
                              ),
                              const SizedBox(height: 5),
                              message.customer != null
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(message.updatedAt!,
                                            style:
                                                const TextStyle(fontSize: 10)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          message.read == null
                                              ? Icons.watch_later_outlined
                                              : Icons.check,
                                          size: 14,
                                        )
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          message.read == null
                                              ? Icons.watch_later_outlined
                                              : Icons.check,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          message.updatedAt!,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

class FirstMessageBox extends StatelessWidget {
  final ProductChatModel productChatModel;
  const FirstMessageBox({
    Key? key,
    required this.productChatModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: kPrimaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: productChatModel.data!.subject != null,
            child: Text(
              "${productChatModel.data!.subject ?? "Hello"}",
              style: context.textTheme.caption!
                  .copyWith(color: kPrimaryLightTextColor),
            ).paddingBottom(5),
          ),
          HtmlWidget(
            productChatModel.data!.message!,
            onTapUrl: (url) {
              launchURL(url);
              return true;
            },
            textStyle: const TextStyle(color: kPrimaryLightTextColor),
          ).paddingBottom(5),

          //TODO: Attatchments
          Visibility(
            visible: productChatModel.data!.attachments!.isNotEmpty,
            child: Text(
              "${productChatModel.data!.attachments}",
              style: context.textTheme.caption!
                  .copyWith(color: kPrimaryLightTextColor),
            ).paddingBottom(5),
          ),
        ],
      ),
    );
  }
}

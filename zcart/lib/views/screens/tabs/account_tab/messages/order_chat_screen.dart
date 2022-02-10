import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/controller/chat/chat_state.dart';
import 'package:zcart/data/models/chat/order/order_chat_model.dart';
import 'package:zcart/data/models/orders/orders_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:zcart/data/network/api.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/pick_image_helper.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/image_viewer_page.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderChatScreen extends StatefulWidget {
  final Orders orders;
  const OrderChatScreen({
    Key? key,
    required this.orders,
  }) : super(key: key);

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _attachment = "";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor:
              getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
          actions: [
            IconButton(
              onPressed: () async {
                await context
                    .read(orderChatProvider.notifier)
                    .orderConversation(widget.orders.id, update: true);
              },
              icon: Icon(Icons.sync,
                  color:
                      getColorBasedOnTheme(context, kDarkColor, kLightColor)),
            )
          ],
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
                    child: CachedNetworkImage(
                      imageUrl: widget.orders.shop!.image!,
                      errorWidget: (context, url, error) => const SizedBox(),
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child:
                            CircularProgressIndicator(value: progress.progress),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          LocaleKeys.order_chat.tr(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.orders.shop!.name!,
                          style: context.textTheme.caption!
                              .copyWith(color: kFadeColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(child: _chatBody(context)),
      ),
    );
  }

  Widget _chatBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color:
                  getColorBasedOnTheme(context, kLightColor, kDarkCardBgColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runSpacing: 10,
                  children: [
                    Text(
                      "${LocaleKeys.order_number.tr()} : \n${widget.orders.orderNumber}",
                      textAlign: TextAlign.center,
                      style: context.textTheme.overline!.copyWith(fontSize: 11),
                    ),
                    Text(
                      "${LocaleKeys.ordered_at.tr()} : \n${widget.orders.orderDate}",
                      textAlign: TextAlign.center,
                      style: context.textTheme.overline!.copyWith(fontSize: 11),
                    ),
                    Text(
                      "${LocaleKeys.order_status.tr()} : \n${widget.orders.orderStatus}",
                      textAlign: TextAlign.center,
                      style: context.textTheme.overline!.copyWith(fontSize: 11),
                    ),
                  ],
                ).pOnly(top: 10, bottom: 10),
              ],
            ),
          ),
        ),
        Expanded(
          child: Consumer(builder: (context, watch, _) {
            final _orderChatProvider = watch(orderChatProvider);
            return _orderChatProvider is OrderChatInitialLoadedState
                ? Center(
                    child: Text(
                      _orderChatProvider.orderChatInitialModel.message!,
                      textAlign: TextAlign.center,
                    ),
                  )
                : _orderChatProvider is OrderChatLoadedState
                    ? _chatLoadedBody(context, _orderChatProvider)
                    : const LoadingWidget();
          }),
        ),
        _chatTextBox(context),
      ],
    );
  }

  // Padding _chatTextBox(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(4),
  //     child: Column(
  //       children: [
  //         _attachment.isNotEmpty
  //             ? _attachmentsWidget(context)
  //             : const SizedBox(),
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             IconButton(
  //               onPressed: () async {
  //                 final _file = await pickImageToBase64();
  //                 //  print("_attachments : $_attachments");

  //                 if (_file != null) {
  //                   _attachment = _file;

  //                   setState(() {});
  //                 }
  //               },
  //               icon: const Icon(Icons.add),
  //             ),
  //             Expanded(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(width: 1, color: kAccentColor),
  //                   color: getColorBasedOnTheme(
  //                       context, kLightColor, kDarkCardBgColor),
  //                 ),
  //                 child: TextField(
  //                   controller: _messageController,
  //                   keyboardType: TextInputType.multiline,
  //                   maxLines: 3,
  //                   minLines: 1,
  //                   decoration: InputDecoration(
  //                     contentPadding: const EdgeInsets.all(8),
  //                     border: InputBorder.none,
  //                     hintText: LocaleKeys.type_a_message.tr(),
  //                     hintStyle: context.textTheme.caption,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(
  //               width: 4,
  //             ),
  //             IconButton(
  //               onPressed: () async {
  //                 if (_messageController.text.isNotEmpty) {
  //                   String message = _messageController.text.trim();
  //                   _messageController.clear();
  //                   context
  //                       .read(orderChatSendProvider.notifier)
  //                       .sendMessage(
  //                         widget.orders.id,
  //                         message,
  //                         photo: _attachment.isNotEmpty ? _attachment : null,
  //                       )
  //                       .then(
  //                     (value) {
  //                       _messageController.clear();
  //                       _attachment = "";
  //                       setState(() {});
  //                       context
  //                           .read(orderChatProvider.notifier)
  //                           .orderConversation(widget.orders.id, update: true);
  //                     },
  //                   );
  //                 } else {
  //                   toast(LocaleKeys.empty_message.tr());
  //                 }
  //               },
  //               icon: Icon(Icons.send, color: kPrimaryColor),
  //             )
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Padding _chatTextBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          _attachment.isNotEmpty
              ? _attachmentsWidget(context)
              : const SizedBox(),
          CupertinoTextField(
            controller: _messageController,
            keyboardType: TextInputType.text,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: kAccentColor),
              borderRadius: BorderRadius.circular(10),
              color: getColorBasedOnTheme(context, kLightColor, kDarkBgColor),
            ),
            placeholder: LocaleKeys.type_a_message.tr(),
            style: context.textTheme.subtitle2!
                .copyWith(fontWeight: FontWeight.bold),
            prefixMode: OverlayVisibilityMode.always,
            textAlignVertical: TextAlignVertical.center,
            padding: const EdgeInsets.only(right: 16),
            prefix: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final _file = await pickImageToBase64();

                if (_file != null) {
                  _attachment = _file;

                  setState(() {});
                }
              },
              child: Icon(Icons.add_photo_alternate, color: kPrimaryColor),
            ),
            suffix: CupertinoButton(
              borderRadius: BorderRadius.circular(2),
              padding: EdgeInsets.zero,
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  String message = _messageController.text.trim();
                  _messageController.clear();
                  context
                      .read(orderChatSendProvider.notifier)
                      .sendMessage(
                        widget.orders.id,
                        message,
                        photo: _attachment.isNotEmpty ? _attachment : null,
                      )
                      .then(
                    (value) {
                      _messageController.clear();
                      _attachment = "";
                      setState(() {});
                      context
                          .read(orderChatProvider.notifier)
                          .orderConversation(widget.orders.id, update: true);
                    },
                  );
                } else {
                  toast(LocaleKeys.empty_message.tr());
                }
              },
              color: kPrimaryColor,
              child: const Icon(Icons.send, color: kLightColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                Image.memory(
                  base64Decode(_attachment),
                  fit: BoxFit.fitHeight,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      _attachment = "";
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatLoadedBody(
      BuildContext context, OrderChatLoadedState orderChatState) {
    List<Reply> _messageList = orderChatState.orderChatModel.data!.replies!;
    List<Reply> _reversedMessageList = _messageList.reversed.toList();
    return Container(
      child: orderChatState.orderChatModel.data!.replies!.isEmpty
          ? Column(
              children: [
                FirstMessageBox(
                  orderChatModel: orderChatState.orderChatModel,
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
                        orderChatModel: orderChatState.orderChatModel,
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
                                ? getColorBasedOnTheme(context,
                                    Colors.grey.shade200, kDarkCardBgColor)
                                : kPrimaryColor.withOpacity(0.1)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: message.customer == null
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              message.attachments!.isEmpty
                                  ? const SizedBox()
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImageViewerPage(
                                              imageUrl: API.appUrl +
                                                  "/image/" +
                                                  message.attachments![0]
                                                      ["path"],
                                              title: message.customer == null
                                                  ? orderChatState
                                                          .orderChatModel
                                                          .data!
                                                          .shop!
                                                          .name ??
                                                      ""
                                                  : message.customer!.name ??
                                                      "",
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 120,
                                        padding: const EdgeInsets.all(2),
                                        margin:
                                            const EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: API.appUrl +
                                                "/image/" +
                                                message.attachments![0]["path"],
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (context, url, error) =>
                                                    const SizedBox(),
                                            placeholder: (context, url) =>
                                                const SizedBox(
                                              height: 50,
                                              width: 50,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
  final OrderChatModel orderChatModel;
  const FirstMessageBox({
    Key? key,
    required this.orderChatModel,
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
            visible: orderChatModel.data!.subject != null,
            child: Text(
              orderChatModel.data!.subject ?? "Hello",
              style: context.textTheme.caption!
                  .copyWith(color: kPrimaryLightTextColor),
            ).paddingBottom(5),
          ),
          HtmlWidget(
            orderChatModel.data!.message!,
            onTapUrl: (url) {
              launchURL(url);
              return true;
            },
            textStyle: const TextStyle(color: kPrimaryLightTextColor),
          ).paddingBottom(5),
          Visibility(
            visible: orderChatModel.data!.attachments!.isNotEmpty,
            child: orderChatModel.data!.attachments!.isEmpty
                ? const SizedBox()
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageViewerPage(
                            imageUrl: API.appUrl +
                                "/image/" +
                                orderChatModel.data!.attachments![0]["path"],
                            title: orderChatModel.data!.subject ?? "Hello",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 120,
                      padding: const EdgeInsets.all(2),
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: API.appUrl +
                              "/image/" +
                              orderChatModel.data!.attachments![0]["path"],
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const SizedBox(),
                          placeholder: (context, url) => const SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

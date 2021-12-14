import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zcart/data/controller/chat/chat_controller.dart';
import 'package:zcart/data/controller/chat/chat_state.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/screens/tabs/account_tab/messages/vendor_chat_screen.dart';
import 'package:zcart/views/shared_widgets/loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:velocity_x/velocity_x.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, _) {
        final conversationState = watch(conversationProvider);
        return Scaffold(
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              title: Text(LocaleKeys.messages.tr()),
              centerTitle: true,
              elevation: 0,
            ),
            body: conversationState is ConversationLoadedState
                ? conversationState.conversationModel.data!.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline),
                            const SizedBox(height: 10),
                            Text(LocaleKeys.empty_inbox.tr())
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount:
                            conversationState.conversationModel.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                tileColor: Colors.transparent,
                                contentPadding: const EdgeInsets.all(8),
                                leading: CachedNetworkImage(
                                  imageUrl: conversationState.conversationModel
                                      .data![index].shop!.image!,
                                  errorWidget: (context, url, error) =>
                                      const SizedBox(),
                                  progressIndicatorBuilder:
                                      (context, url, progress) => Center(
                                    child: CircularProgressIndicator(
                                        value: progress.progress),
                                  ),
                                  width: context.screenWidth * 0.20,
                                  fit: BoxFit.cover,
                                ).p(5),
                                title: Text(
                                    conversationState.conversationModel
                                        .data![index].shop!.name!,
                                    style: context.textTheme.bodyText2!
                                        .copyWith(fontWeight: FontWeight.bold)),
                                trailing: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(CupertinoIcons.chevron_forward),
                                ),
                              ),
                            ).onInkTap(() async {
                              context.nextPage(VendorChatScreen(
                                  shopId: conversationState
                                      .conversationModel.data![index].shop!.id,
                                  shopImage: conversationState.conversationModel
                                      .data![index].shop!.image,
                                  shopName: conversationState.conversationModel
                                      .data![index].shop!.name,
                                  shopVerifiedText: conversationState
                                      .conversationModel
                                      .data![index]
                                      .shop!
                                      .verifiedText));
                              await context
                                  .read(productChatProvider.notifier)
                                  .productConversation(
                                    conversationState.conversationModel
                                        .data![index].shop!.id,
                                  );
                            }),
                          );
                        }).pOnly(top: 5)
                : const Center(child: LoadingWidget()));
      },
    );
  }
}

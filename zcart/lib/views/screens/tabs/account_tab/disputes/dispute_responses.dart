import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zcart/helper/get_color_based_on_theme.dart';
import 'package:zcart/helper/url_launcher_helper.dart';
import 'package:zcart/riverpod/providers/dispute_provider.dart';
import 'package:zcart/riverpod/state/dispute/dispute_details_state.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:zcart/Theme/styles/colors.dart';
import 'package:zcart/translations/locale_keys.g.dart';
import 'package:zcart/views/shared_widgets/shared_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class DisputeResponseScreen extends StatelessWidget {
  const DisputeResponseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    final Map<String, String> _statuses = {
      'NEW': '1',
      'OPEN': '2',
      'SOLVED': '5',
    };

    return Consumer(
      builder: (context, watch, _) {
        final disputeDetailsState = watch(disputeDetailsProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.dispute_responses.tr()),
            automaticallyImplyLeading: true,
            actions: [
              disputeDetailsState is DisputeDetailsLoadedState
                  ? IconButton(
                      onPressed: () async {
                        await context
                            .read(disputeDetailsProvider.notifier)
                            .getDisputeDetails(
                                disputeDetailsState.disputeDetails!.id);
                      },
                      icon: const Icon(Icons.refresh),
                    )
                  : Container()
            ],
          ),
          body: disputeDetailsState is DisputeDetailsLoadedState
              ? Column(
                  children: <Widget>[
                    Expanded(
                      child:
                          disputeDetailsState.disputeDetails!.replies!.isEmpty
                              ? Container()
                              : _chatBody(context, disputeDetailsState),
                    ),
                    _chatTextBody(context, messageController, _statuses,
                        disputeDetailsState),
                  ],
                )
              : const LoadingWidget(),
        );
      },
    );
  }

  Padding _chatTextBody(
      BuildContext context,
      TextEditingController messageController,
      Map<String, String> _statuses,
      DisputeDetailsLoadedState disputeDetailsState) {
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
                color: getColorBasedOnTheme(context, kLightColor, kDarkBgColor),
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
            onPressed: () async {
              //TODO: Status Need To be created
              print(_statuses[disputeDetailsState.disputeDetails!.status!]);
              if (messageController.text.isNotEmpty) {
                String message = messageController.text.trim();
                messageController.clear();
                await context
                    .read(disputeDetailsProvider.notifier)
                    .postDisputeRespose(
                  disputeDetailsState.disputeDetails!.id,
                  {
                    'reply': message,
                    'status': _statuses[
                            disputeDetailsState.disputeDetails!.status!] ??
                        "3",
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

  Widget _chatBody(
      BuildContext context, DisputeDetailsLoadedState disputeDetailsState) {
    List<dynamic> _messageList = disputeDetailsState.disputeDetails!.replies!;
    List<dynamic> _reversedMessageList = _messageList.reversed.toList();
    return ListView(
      reverse: true,
      children: _reversedMessageList.map((message) {
        return Container(
          color: getColorBasedOnTheme(context, kLightBgColor, kDarkBgColor),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
                child: Align(
                  alignment: (message['customer'] == null
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Container(
                    constraints:
                        BoxConstraints(maxWidth: context.screenWidth * 0.75),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: (message['customer'] == null
                          ? Colors.grey.shade200
                          : kPrimaryColor.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: message['customer'] == null
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        //TODO: Attachment Issue
                        if (!message["attachments"].isEmpty)
                          for (var i = 0;
                              i < message["attachments"].length;
                              i++)
                            SelectableText("${message["attachments"].first}"),
                        HtmlWidget(
                          message['reply'],
                          onTapUrl: (url) {
                            launchURL(url);
                            return true;
                          },
                        ),
                        const SizedBox(height: 5),
                        message['customer'] != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(message['updated_at'],
                                      style: const TextStyle(fontSize: 10)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    message['read'] == null
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
                                    message['read'] == null
                                        ? Icons.watch_later_outlined
                                        : Icons.check,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    message['updated_at'],
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
          ),
        );
      }).toList(),
    );
  }
}

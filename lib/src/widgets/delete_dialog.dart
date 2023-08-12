// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:overlay_support/overlay_support.dart';

Dialog deleteConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String userId,
  required Function(String) action,
  required String actionText,
}) {
  Size screenSize = MediaQuery.of(context).size;
  bool boolVarLoading = false;
  ValueNotifier<bool> rebuildReasonBox = ValueNotifier(false);
  DeleteReason? reasonForDeletion;
  bool isCm = UserLocalPreference.instance.fetchMemberState();
  User user = UserLocalPreference.instance.fetchUserData();

  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6.0),
    ),
    elevation: 5,
    child: Container(
      width: screenSize.width * 0.7,
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          kVerticalPaddingLarge,
          Text(content),
          user.userUniqueId == userId
              ? const SizedBox.shrink()
              : isCm
                  ? kVerticalPaddingLarge
                  : const SizedBox.shrink(),
          user.userUniqueId == userId
              ? const SizedBox.shrink()
              : isCm
                  ? Builder(builder: (context) {
                      return ValueListenableBuilder(
                          valueListenable: rebuildReasonBox,
                          builder: (context, _, __) {
                            return GestureDetector(
                              onTap: boolVarLoading
                                  ? () {}
                                  : () async {
                                      boolVarLoading = true;
                                      rebuildReasonBox.value =
                                          !rebuildReasonBox.value;
                                      GetDeleteReasonResponse response =
                                          await locator<LikeMindsService>()
                                              .getReportTags(
                                                  ((GetDeleteReasonRequestBuilder()
                                                        ..type(0))
                                                      .build()));
                                      if (response.success) {
                                        List<DeleteReason> reportTags =
                                            response.reportTags!;

                                        await showModalBottomSheet(
                                            context: context,
                                            elevation: 5,
                                            enableDrag: true,
                                            clipBehavior: Clip.hardEdge,
                                            backgroundColor: kWhiteColor,
                                            useSafeArea: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16.0),
                                                topRight: Radius.circular(16.0),
                                              ),
                                            ),
                                            builder: (context) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 30.0),
                                                width: screenSize.width,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0),
                                                      child: Text(
                                                        'Reason for deletion',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: kFontMedium,
                                                        ),
                                                      ),
                                                    ),
                                                    kVerticalPaddingXLarge,
                                                    Expanded(
                                                      child: ListView.separated(
                                                          separatorBuilder:
                                                              (context,
                                                                      index) =>
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            50),
                                                                    child:
                                                                        const Divider(
                                                                      thickness:
                                                                          0.5,
                                                                      color:
                                                                          kGrey3Color,
                                                                    ),
                                                                  ),
                                                          itemBuilder:
                                                              (context, index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                reasonForDeletion =
                                                                    reportTags[
                                                                        index];
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 35,
                                                                    child: Radio(
                                                                        value: reportTags[index]
                                                                            .id,
                                                                        groupValue: reasonForDeletion ==
                                                                                null
                                                                            ? -1
                                                                            : reasonForDeletion!
                                                                                .id,
                                                                        onChanged:
                                                                            (value) {}),
                                                                  ),
                                                                  kHorizontalPaddingLarge,
                                                                  Text(
                                                                    reportTags[
                                                                            index]
                                                                        .name,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          itemCount: reportTags
                                                              .length),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                        rebuildReasonBox.value =
                                            !rebuildReasonBox.value;
                                      } else {
                                        toast(response.errorMessage ??
                                            'An error occured');
                                      }
                                      boolVarLoading = false;
                                      rebuildReasonBox.value =
                                          !rebuildReasonBox.value;
                                    },
                              child: Container(
                                  padding: const EdgeInsets.all(14.0),
                                  decoration: BoxDecoration(
                                      color: kWhiteColor,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4,
                                          spreadRadius: 0,
                                          offset: Offset(0, 2),
                                          color: Colors.black12,
                                        )
                                      ]),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        reasonForDeletion == null
                                            ? 'Reason for deletion'
                                            : reasonForDeletion!.name,
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      )
                                    ],
                                  )),
                            );
                          });
                    })
                  : const SizedBox.shrink(),
          kVerticalPaddingSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.zero,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: kGrey3Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (user.userUniqueId != userId && isCm) {
                    if (reasonForDeletion == null) {
                      toast('Please select a reason for deletion');
                      return;
                    }
                  }
                  action(
                      reasonForDeletion == null ? '' : reasonForDeletion!.name);
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.zero,
                  ),
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    color: kLinkColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}

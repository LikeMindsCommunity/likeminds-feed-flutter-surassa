import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_fl/src/services/likeminds_service.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ss_fl/src/utils/local_preference/user_local_preference.dart';
import 'package:likeminds_feed_ss_fl/src/views/post/new_post_screen.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class PostSomething extends StatelessWidget {
  final bool enabled;
  const PostSomething({Key? key, required this.enabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = UserLocalPreference.instance.fetchUserData();
    Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: enabled
          ? () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const NewPostScreen()));
            }
          : () => toast("You do not have permission to create a post"),
      child: Container(
        width: screenSize.width,
        height: 92,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 4,
          ),
          height: 80,
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(50.0),
            border: Border.all(
              width: 1,
              color: onSurface,
            ),
          ),
          child: Row(
            children: <Widget>[
              LMProfilePicture(
                fallbackText: user.name,
                imageUrl: user.imageUrl,
                onTap: () {
                  if (user.sdkClientInfo != null) {
                    locator<LikeMindsService>()
                        .routeToProfile(user.sdkClientInfo!.userUniqueId);
                  }
                },
                size: 42,
              ),
              kHorizontalPaddingMedium,
              const LMTextView(text: "Post something...")
            ],
          ),
        ),
      ),
    );
  }
}

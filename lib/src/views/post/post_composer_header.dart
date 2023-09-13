import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class PostComposerHeader extends StatelessWidget {
  final String title;
  final Function onTap;
  final Function? onPressedBack;

  const PostComposerHeader(
      {Key? key, required this.title, this.onPressedBack, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Container(
        decoration: const BoxDecoration(
          color: kWhiteColor,
          border: Border(
            bottom: BorderSide(
              width: 0.1,
              color: kGrey1Color,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 4.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LMTextButton(
              text: LMTextView(
                text: "Cancel",
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onTap: onPressedBack == null
                  ? () {
                      Navigator.pop(context);
                    }
                  : () => onPressedBack!(),
            ),
            const Spacer(),
            LMTextView(
              text: title,
              textStyle: const TextStyle(fontSize: 18, color: kGrey1Color),
            ),
            const Spacer(),
            LMTextButton(
              text: LMTextView(
                text: "Post",
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              width: 48,
              borderRadius: 6,
              backgroundColor: Theme.of(context).primaryColor,
              onTap: () => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

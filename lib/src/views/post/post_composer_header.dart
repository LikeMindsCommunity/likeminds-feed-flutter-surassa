import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class PostComposerHeader extends StatelessWidget {
  final LMTextView title;
  final Function onTap;
  final Function? onPressedBack;

  const PostComposerHeader(
      {Key? key, required this.title, this.onPressedBack, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = LMThemeData.suraasaTheme;
    return SizedBox(
      height: 56,
      child: Container(
        decoration: const BoxDecoration(
          color: LMThemeData.kWhiteColor,
          border: Border(
            bottom: BorderSide(
              width: 0.1,
              color: LMThemeData.kGrey1Color,
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
                textStyle: TextStyle(color: theme.colorScheme.primary),
              ),
              onTap: onPressedBack == null
                  ? () {
                      Navigator.pop(context);
                    }
                  : () => onPressedBack!(),
            ),
            const Spacer(),
            title,
            const Spacer(),
            LMTextButton(
              text: LMTextView(
                text: "Post",
                textStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              width: 48,
              borderRadius: 6,
              backgroundColor: theme.colorScheme.primary,
              onTap: () => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}

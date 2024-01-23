import 'dart:io';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

PreferredSizeWidget suraasaPostDetailScreenAppBarBuilder(
    BuildContext context, LMFeedAppBar appBar) {
  return appBar.copyWith(
    title: const LMFeedText(
      text: "Comments",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    style: appBar.style?.copyWith(
      centerTitle: Platform.isAndroid ? false : true,
      height: 50,
    ),
  );
}

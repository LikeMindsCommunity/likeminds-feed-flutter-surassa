import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/src/utils/constants/ui_constants.dart';
import 'package:shimmer/shimmer.dart';

Widget getLikesTileShimmer() {
  return Padding(
    padding: const EdgeInsets.only(
      left: 16.0,
      right: 16.0,
      bottom: 16.0,
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.black26,
      highlightColor: Colors.black12,
      child: Row(
        children: [
          const SizedBox(
            height: 50,
            width: 50,
            child: CircleAvatar(
              backgroundColor: kWhiteColor,
            ),
          ),
          kHorizontalPaddingXLarge,
          Container(
            height: 12,
            width: 150,
            color: kWhiteColor,
          )
        ],
      ),
    ),
  );
}

import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

class SSCustomMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int month) => '1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int months) => '1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

// Returns file size in double in MBs
double getFileSizeInDouble(int bytes) {
  return (bytes / pow(1024, 2));
}

String? getPostType(int postType) {
  String? postTypeString;
  switch (postType) {
    case 1: // Image
      postTypeString = "image";
      break;
    case 2: // Video
      postTypeString = "video";
      break;
    case 3: // Document
      postTypeString = "document";
      break;
    case 4: // Link
      postTypeString = "link";
      break;
  }
  return postTypeString;
}

Future<Map<String, int>> getImageFileDimensions(File image) async {
  Map<String, int> dimensions = {};
  final decodedImage = await decodeImageFromList(image.readAsBytesSync());
  dimensions.addAll({"width": decodedImage.width});
  dimensions.addAll({"height": decodedImage.height});
  return dimensions;
}

Future<Map<String, int>> getNetworkImageDimensions(String image) async {
  Map<String, int> dimensions = {};
  final response = await http.get(Uri.parse(image));
  final bytes = response.bodyBytes;
  final decodedImage = await decodeImageFromList(bytes);
  dimensions.addAll({"width": decodedImage.width});
  dimensions.addAll({"height": decodedImage.height});
  return dimensions;
}

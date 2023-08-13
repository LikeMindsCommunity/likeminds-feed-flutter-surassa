import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();

  void initialise() async {
    ConnectivityResult result = await networkConnectivity.checkConnectivity();
    if (result != ConnectivityResult.mobile &&
        result != ConnectivityResult.wifi) {
      // TODO: show snackbaro  or toast to update the user of network connectivity
    }
    networkConnectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.mobile &&
          result != ConnectivityResult.wifi) {
        // TODO: show snackbaro  or toast to update the user of network connectivity
      }
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        rootScaffoldMessengerKey.currentState?.clearSnackBars();
      }
    });
  }

  void disposeStream() => _controller.close();
}

SnackBar confirmationToast(
    {required String content, required Color backgroundColor}) {
  return SnackBar(
    showCloseIcon: true,
    duration: const Duration(days: 1),
    backgroundColor: backgroundColor,
    elevation: 5,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    content: Align(
      alignment: Alignment.center,
      child: Text(
        content,
        textAlign: TextAlign.left,
      ),
    ),
  );
}

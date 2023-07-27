import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_sample/cred_screen.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();

  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    if (result != ConnectivityResult.mobile &&
        result != ConnectivityResult.wifi) {
      // rootScaffoldMessengerKey.currentState?.showSnackBar(
      //   confirmationToast(
      //     content: "No internet\nCheck your connection and try again",
      //     backgroundColor: Colors.grey,
      //   ),
      // );
    }
    _networkConnectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.mobile &&
          result != ConnectivityResult.wifi) {
        // rootScaffoldMessengerKey.currentState?.showSnackBar(
        //   confirmationToast(
        //     content: "No internet\nCheck your connection and try again",
        //     backgroundColor: Colors.grey,
        //   ),
        // );
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

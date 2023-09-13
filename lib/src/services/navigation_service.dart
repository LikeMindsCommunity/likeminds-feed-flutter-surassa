import 'package:flutter/material.dart';

class NavigationService {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool checkNullState() {
    if (navigatorKey.currentState == null) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> navigateTo(Route route, {Object? arguments}) {
    print(navigatorKey.currentState!.toString());
    return navigatorKey.currentState!.push(route);
  }

  void goBack({Map<String, dynamic>? result}) {
    return navigatorKey.currentState!.pop(result ?? {});
  }
}

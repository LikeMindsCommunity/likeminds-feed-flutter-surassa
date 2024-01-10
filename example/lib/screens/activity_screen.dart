import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({
    super.key,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late String userId;
  @override
  void initState() {
    userId = UserLocalPreference.instance
        .fetchUserData()
        .sdkClientInfo!
        .userUniqueId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: ColorTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Activity'),
        // backgroundColor: ColorTheme.backgroundColor,
      ),
      body: SSActivityWidget(uuid: userId),
    );
  }
}

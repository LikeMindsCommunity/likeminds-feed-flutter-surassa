import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';
import 'package:likeminds_feed_ss_sample/credentials/credentials.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.uuid});
  final String uuid;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late String userId;
  @override
  void initState() {
    const isProd = prodFlag;
    userId = widget.uuid.isEmpty
        ? isProd
            ? CredsProd.botId
            : CredsDev.botId
        : widget.uuid;
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

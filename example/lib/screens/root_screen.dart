import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_fl/likeminds_feed_ss_fl.dart';

class TabApp extends StatefulWidget {
  final Widget feedWidget;
  final Widget activityWidget;

  const TabApp({
    super.key,
    required this.feedWidget,
    required this.activityWidget,
  });

  @override
  State<TabApp> createState() => _TabAppState();
}

class _TabAppState extends State<TabApp> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData lmFeedThemeData = LMFeedTheme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: lmFeedThemeData.container,
        selectedIndex: tabController.index,
        onDestinationSelected: (index) {
          tabController.animateTo(index);
          setState(() {});
        },
        elevation: 10,
        indicatorColor: lmFeedThemeData.primaryColor,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home,
              color: lmFeedThemeData.onContainer,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: lmFeedThemeData.onPrimary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_2_sharp,
              color: lmFeedThemeData.onContainer,
            ),
            selectedIcon: Icon(
              Icons.person_2_sharp,
              color: lmFeedThemeData.onPrimary,
            ),
            label: 'Activity',
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          HomeScreen(
            childWidget: widget.feedWidget,
          ), // First tab content
          HomeScreen(
            childWidget: widget.activityWidget,
          )
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Widget childWidget;

  const HomeScreen({
    super.key,
    required this.childWidget,
  });

  @override
  Widget build(BuildContext context) {
    return childWidget;
  }
}

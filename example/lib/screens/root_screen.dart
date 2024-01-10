import 'package:flutter/material.dart';
import 'package:likeminds_feed_ss_sample/screens/activity_screen.dart';

class TabApp extends StatefulWidget {
  final Widget feedWidget;
  final String uuid;
  const TabApp({
    super.key,
    required this.feedWidget,
    required this.uuid,
  });

  @override
  State<TabApp> createState() => _TabAppState();
}

class _TabAppState extends State<TabApp> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: tabController.index,
          onDestinationSelected: (index) {
            tabController.animateTo(index);
            setState(() {});
          },
          elevation: 10,
          indicatorColor: Color(0xFF3B82F6),
          backgroundColor: Color(0xFF3B82F6).withOpacity(0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home,
              ),
              selectedIcon: Icon(
                Icons.home,
                color: Colors.white,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_2_sharp,
              ),
              selectedIcon: Icon(
                Icons.person_2_sharp,
                color: Colors.white,
              ),
              label: 'Activity',
            ),
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            HomeScreen(
              feedWidget: widget.feedWidget,
            ), // First tab content
             ActivityScreen(
              uuid: widget.uuid,
            ), // Second tab content
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Widget feedWidget;

  const HomeScreen({
    super.key,
    required this.feedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return feedWidget;
  }
}

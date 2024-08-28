import 'package:flutter/material.dart';
import 'package:khatabookclone/bottamnavigator/more.dart';
import 'package:khatabookclone/bottamnavigator/parties.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List bottompages = [
    UserList(),
    MorePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bottompages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              LucideIcons.home,
            ),
            label: "Parties",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LucideIcons.user,
            ),
            label: "More",
          ),
        ],
      ),
    );
  }
}

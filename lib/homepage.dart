import 'package:flutter/material.dart';
import 'package:khatabookclone/bottamnavigator/billpage.dart';
import 'package:khatabookclone/bottamnavigator/parties.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  List bottompages = const [BillPage(), PartiesPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "khataBook",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
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
              LucideIcons.bell,
            ),
            label: "Bills",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              LucideIcons.shoppingBag,
            ),
            label: "Item",
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

import 'package:flutter/material.dart';
import 'package:khatabookclone/Auth/login.dart';
import 'package:khatabookclone/addcustomer.dart';
import 'package:khatabookclone/homepage.dart';
import 'package:khatabookclone/utils/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khatabook Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => const LoginPage(),
        Screen.addCustomerPage: (context) => const Addcustomer()
      },
    );
  }
}

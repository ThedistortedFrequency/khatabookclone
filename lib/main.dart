import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:khatabookclone/bottamnavigator/customerpage.dart';
import 'package:khatabookclone/firebase_options.dart';
import 'package:khatabookclone/homepage.dart';
import 'package:khatabookclone/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        "/": (context) => const HomePage(),
        Screen.addCustomerPage: (context) => const CustomerPage()
      },
    );
  }
}

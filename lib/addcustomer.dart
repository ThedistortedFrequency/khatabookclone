import 'package:flutter/material.dart';

class Addcustomer extends StatelessWidget {
  const Addcustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Center(
            child: Text("add customer"),
          )
        ],
      ),
    );
  }
}

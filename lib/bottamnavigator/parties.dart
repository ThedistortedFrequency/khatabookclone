import 'package:flutter/material.dart';

class PartiesPage extends StatelessWidget {
  const PartiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text("HI FLUTTER")),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(40.0), // Adjust the radius as needed
        ),
        onPressed: () {},
        label: const Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.add),
            ),
            Text("ADD CUTOMER"),
          ],
        ),
      ),
    );
  }
}

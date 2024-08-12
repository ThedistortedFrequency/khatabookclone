import 'dart:js_interop';

import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final Text text;
  final Color color;

  const CustomFAB({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      elevation: 8,
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      onPressed: () {},
      label: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
          Text(
            text.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

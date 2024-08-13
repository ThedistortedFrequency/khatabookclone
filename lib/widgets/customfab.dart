import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final String text;
  final Color color;
  final void Function()? onpressed;

  const CustomFAB(
      {super.key,
      required this.text,
      required this.color,
      required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      elevation: 8,
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      onPressed: onpressed,
      label: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
          Text(
            text.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

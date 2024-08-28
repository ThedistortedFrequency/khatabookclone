import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final Color color;
  final void Function()? onpressed;

  const CustomFAB({super.key, required this.color, required this.onpressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      elevation: 8,
      backgroundColor: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      onPressed: onpressed,
      label: const Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.person_add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

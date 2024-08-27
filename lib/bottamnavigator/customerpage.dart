import 'package:flutter/material.dart';
import 'package:khatabookclone/widgets/customfab.dart';

import '../addcustomer.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: const BoxDecoration(color: Colors.indigo),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(12.0),
                    // Rounded corners
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹0',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Text(
                            "You will give",
                            style:
                                TextStyle(color: Colors.black38, fontSize: 12),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: VerticalDivider(),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹0',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          Text(
                            "You will get",
                            style:
                                TextStyle(color: Colors.black38, fontSize: 12),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: VerticalDivider(),
                      ),
                      TextButton(
                          onPressed: () {}, child: const Text("View Report"))
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: CustomFAB(
        onpressed: () {
          showCustomBottomSheet(context);
        },
        color: Colors.red,
        text: "ADD CUSTOMER",
      ),
    );
  }
}

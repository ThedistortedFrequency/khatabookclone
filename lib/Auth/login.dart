import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 15,right: 15),
              child: IntlPhoneField(
                decoration: InputDecoration(
                  labelText: "Phone number",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                    )
                  )
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
            padding: EdgeInsets.only(left: 15,right: 15),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  
                ),
                helperText: "Send on your number",
                labelText: "OTP",
                hintText: "Enter 6 digit OTP",
              ),
            ),
          ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 50),
                            backgroundColor: Colors.indigo),
                            child: const Text("Get OTP",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
                      ),
          ],
          ),
      ),
    );
  }
}
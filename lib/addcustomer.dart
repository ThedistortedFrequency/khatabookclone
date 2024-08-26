import 'package:flutter/material.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  String partyType = "Customer";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Party'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: const InputDecoration(
                labelText: 'Party name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Container(
                  width: 80,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/indian_flag.png', // Path to your flag image
                          width: MediaQuery.of(context).size.height * 0.015,
                          height: MediaQuery.of(context).size.height * 0.015,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                const Expanded(
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text('Who are they?'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Customer'),
                    value: 'Customer',
                    groupValue: partyType,
                    onChanged: (value) {
                      setState(() {
                        partyType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Supplier'),
                    value: 'Supplier',
                    groupValue: partyType,
                    onChanged: (value) {
                      setState(() {
                        partyType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Handle "Add GSTIN & Address (Optional)" press
              },
              child: const Text('+ ADD GSTIN & ADDRESS (OPTIONAL)'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.060,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        partyType == "Supplier" ? Colors.red : Colors.indigo),
                onPressed: () {
                  // Handle "Add Customer" button press
                  if (partyType == "Customer") {
                  } else {}
                },
                child: Text(
                  partyType == "Customer" ? 'ADD CUSTOMER' : 'ADD SUPPLIER',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

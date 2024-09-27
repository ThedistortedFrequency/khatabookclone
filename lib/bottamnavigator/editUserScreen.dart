import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  const EditUserScreen({super.key, required this.userId});

  @override
  EditUserScreenState createState() => EditUserScreenState();
}

class EditUserScreenState extends State<EditUserScreen> {
  final _amountController = TextEditingController();
  final _interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    var userData = doc.data() as Map<String, dynamic>;

    _amountController.text = (userData['Amount'] ?? '0').toString();
    _interestController.text = (userData['Interest'] ?? '0').toString();
  }

  void _updateUser() async {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double interestRate = double.tryParse(_interestController.text) ?? 0.0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'Amount': amount,
      'Interest': interestRate,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _interestController,
                  decoration: const InputDecoration(labelText: 'Interest Rate (%)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateUser,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16),
                  shape:  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16), // Rounded corners
                  ),
                ),
                child: const Text('Update User', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

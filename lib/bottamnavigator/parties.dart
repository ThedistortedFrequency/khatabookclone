import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khatabookclone/addcustomer.dart';
import 'package:khatabookclone/utils/routes.dart';
import 'package:khatabookclone/widgets/customfab.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  double totalCredit = 0.0;
  double totalDebit = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Hisabkitab",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                LucideIcons.calendar,
                color: Colors.white,
              ))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 80,
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: Text('No data available')),
                );
              }

              var userDocs = snapshot.data!.docs;

              double newTotalCredit = 0.0;
              double newTotalDebit = 0.0;

              for (var doc in userDocs) {
                var user = doc.data() as Map<String, dynamic>;
                var transactionType = user['Transaction Type'] ?? 'Unknown';
                var amount =
                    double.tryParse(user['Amount']?.toString() ?? '0.0') ?? 0.0;
                var interestRate =
                    double.tryParse(user['Interest']?.toString() ?? '0.0') ??
                        0.0;

                int interestAmount = (amount * (interestRate / 100)).round();
                double totalAmount = amount + interestAmount;

                if (transactionType == 'Credit') {
                  newTotalCredit += totalAmount;
                } else if (transactionType == 'Debit') {
                  newTotalDebit += totalAmount;
                }
              }

              // Update totals
              totalCredit = newTotalCredit;
              totalDebit = newTotalDebit;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹$totalCredit',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          const Text(
                            "Credit",
                            style:
                                TextStyle(color: Colors.black38, fontSize: 12),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: VerticalDivider(),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹$totalDebit',
                            style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          const Text(
                            "Debit",
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
                          onPressed: () {
                            Navigator.pushNamed(context, Screen.viewreport);
                          },
                          child: const Text("View Report"))
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          var userDocs = snapshot.data!.docs;

          List<Widget> listItems = userDocs.map((doc) {
            var user = doc.data() as Map<String, dynamic>;
            var id = doc.id;
            var transactionType = user['Transaction Type'] ?? 'Unknown';
            var amount =
                double.tryParse(user['Amount']?.toString() ?? '0.0') ?? 0.0;
            var interestRate =
                double.tryParse(user['Interest']?.toString() ?? '0.0') ?? 0.0;
            var timestamp = user['timestamp']
                ?.toDate(); // Convert Firestore timestamp to DateTime

            // Calculate and round off interest amount
            int interestAmount = (amount * (interestRate / 100)).round();
            double totalAmount = amount + interestAmount;

            // Determine the color based on the transaction type
            Color backgroundColor = transactionType == 'Credit'
                ? Colors.lightGreen[50]!
                : Colors.red[50]!;
            Color numberColor =
                transactionType == 'Credit' ? Colors.green : Colors.red;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                color: backgroundColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text(user['Name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Date: ${timestamp != null ? DateFormat('dd MMM yyyy').format(timestamp) : 'No Date'}'),
                      Text(
                          'Interest Rate: ${interestRate.toStringAsFixed(2)}%'),
                      const SizedBox(height: 8.0),
                      Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                      Text('Interest Amount: ₹$interestAmount'),
                      const SizedBox(height: 8.0),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Total Amount Including Interest: ₹',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: totalAmount.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: numberColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditUserScreen(userId: id),
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, id);
                        },
                      ),
                    ],
                  ),
                  leading: Icon(
                    transactionType == 'Credit'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: numberColor,
                  ),
                ),
              ),
            );
          }).toList();

          return ListView(
            children: listItems,
          );
        },
      ),
      floatingActionButton: CustomFAB(
        onpressed: () {
          showCustomBottomSheet(context);
        },
        color: Colors.red,
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Do you really want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(documentId)
                    .delete()
                    .then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $error')),
                  );
                });
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _interestController,
              decoration: const InputDecoration(labelText: 'Interest Rate (%)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUser,
              child: const Text('Update User'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:khatabookclone/bottamnavigator/editUserScreen.dart';
import 'package:pdf/pdf.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PersonDetailScreen extends StatefulWidget {
  final String userId;

  const PersonDetailScreen({super.key, required this.userId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTotalAmount();
  }

  Future<void> _fetchTotalAmount() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      setState(() {
        totalAmount = (userSnapshot['Amount'] ?? 0.0) + (userSnapshot['Interest'] ?? 0.0);
      });
    }
  }
  void showAddTransactionDialog(BuildContext context, String userId) {
    String transactionType = 'Credit';
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Transaction'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Credit',
                        groupValue: transactionType,
                        onChanged: (value) {
                          setState(() {
                            transactionType = value!;
                          });
                        },
                      ),
                      const Text('Credit'),
                      Radio<String>(
                        value: 'Debit',
                        groupValue: transactionType,
                        onChanged: (value) {
                          setState(() {
                            transactionType = value!;
                          });
                        },
                      ),
                      const Text('Debit'),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(

              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0) {
                  // Add transaction to Firestore
                  FirebaseFirestore.instance.collection('users')
                      .doc(userId)
                      .collection('transactions')
                      .add({
                    'Amount': amount,
                    'Transaction Type': transactionType,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Details'),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(userId: widget.userId),
                ),
              );
            },
          ),
          // Download button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              // Fetch user details to get the amount and transaction type
              DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
              var user = userSnapshot.data() as Map<String, dynamic>;
              double amount = user['Amount'] ?? 0.0;
              String transactionType = user['Transaction Type'] ?? 'Unknown';

              _generatePdf(amount, transactionType, context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User details section
          Column(
            children: [
              // User details section
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('No data available'));
                  }

                  var user = snapshot.data!.data() as Map<String, dynamic>;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .collection('transactions')
                        .snapshots(),
                    builder: (context, transactionSnapshot) {
                      if (transactionSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (transactionSnapshot.hasError) {
                        return Center(child: Text('Error: ${transactionSnapshot.error}'));
                      }

                      if (!transactionSnapshot.hasData || transactionSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Center(child: Text('No transactions available')));
                      }

                      var transactions = transactionSnapshot.data!.docs;
                      double totalAmount = transactions.fold(0, (double sum, doc) {
                        var transaction = doc.data() as Map<String, dynamic>;
                        double amount = transaction['Amount'] ?? 0.0;

                        if (transaction['Transaction Type'] == 'Credit') {
                          return sum + amount;
                        } else if (transaction['Transaction Type'] == 'Debit') {
                          return sum - amount;
                        } else {
                          return sum;
                        }
                      });

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0.0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name: ${user['Name']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16.0),
                                  // Total Amount with emphasis
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹${totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: totalAmount >= 0 ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text('Interest Rate: ${user['Interest'] ?? 0}%'),
                                  Text(
                                    'Transaction Type: ${totalAmount < 0 ? 'Debit' : 'Credit'}',

                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          // Transactions list section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('transactions')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var transactions = snapshot.data?.docs ?? [];

                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions available'));
                }

                // Calculate total amount from transactions
                double calculatedTotalAmount = transactions.fold(0, (double sum, doc) {
                  var transaction = doc.data() as Map<String, dynamic>;
                  double amount = transaction['Amount'] ?? 0.0;
                  String transactionType = transaction['Transaction Type'] ?? 'Unknown';

                  if (transactionType == 'Credit') {
                    return sum + amount;
                  } else if (transactionType == 'Debit') {
                    return sum - amount;
                  } else {
                    return sum;
                  }
                });

                if (calculatedTotalAmount != totalAmount) {
                  // Update the totalAmount in Firestore first
                  FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
                    'Amount': calculatedTotalAmount,
                  }).then((_) {
                    // After updating Firestore, update the state
                    setState(() {
                      totalAmount = calculatedTotalAmount;
                    });
                  });
                }

                return Column(
                  children: [

                    Expanded(
                      child: ListView(
                        children: transactions.map((doc) {
                          var transaction = doc.data() as Map<String, dynamic>;
                          var amount = transaction['Amount'] ?? 0.0;
                          var transactionType = transaction['Transaction Type'] ?? 'Unknown';
                          var timestamp = transaction['timestamp']?.toDate() ?? DateTime.now();

                          Color backgroundColor = transactionType == 'Credit' ? Colors.green[50]! : Colors.red[50]!;
                          Color numberColor = transactionType == 'Credit' ? Colors.green : Colors.red;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: transactionType == 'Credit' ? Colors.green[50] : Colors.red[50],
                                  child: Icon(
                                    transactionType == 'Credit' ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: numberColor,
                                  ),
                                ),
                                title: Text(
                                  DateFormat('d-MMM-yy').format(timestamp),
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                                ),
                                subtitle: Text(timeago.format(timestamp)),
                                trailing: Text(
                                  '₹${amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: numberColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTransactionDialog(context, widget.userId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }



  Future<void> _generatePdf(double amount, String transactionType, BuildContext context) async {
    try {
      // Show CircularProgressIndicator while generating the PDF
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Transaction Receipt', style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 20),
                  pw.Text('Amount: ₹${amount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 18)),
                  pw.Text('Transaction Type: $transactionType', style: const pw.TextStyle(fontSize: 18)),
                  pw.SizedBox(height: 20),
                  pw.Text('Thank you for your transaction!', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
            );
          },
        ),
      );

      // Generate the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          return pdf.save();
        },
      );

      // Close the progress indicator after generating the PDF
      Navigator.of(context).pop();
    } catch (e) {
      // Close the progress indicator in case of error
      Navigator.of(context).pop();

      // Show a Snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    }
  }
}


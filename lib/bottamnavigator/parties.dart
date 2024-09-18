import 'package:khatabookclone/addcustomer.dart';
import 'package:khatabookclone/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khatabookclone/widgets/customfab.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pdf/pdf.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


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
                          onPressed: (){
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
        stream: FirebaseFirestore.instance.collection('users').orderBy('timestamp', descending: true).snapshots(),
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
                ?.toDate();

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
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!, // Light grey color
                      width: 1.0, // Thickness of the border
                    ),
                  ),
                ),
                child: ListTile(
                   title:Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         user['Name'] ?? 'No Name',
                         style: const TextStyle(
                           fontWeight: FontWeight.w600,
                           color: Colors.black,
                         ),
                       ),

                       Text(
                         timeago.format(timestamp ?? DateTime.now()),
                         style: const TextStyle(
                           color: Colors.grey,
                           fontSize: 12,
                         ),
                       ),
                     ],
                   ),
                  trailing: Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: numberColor,
                      fontSize: 16,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: transactionType == 'Credit' ? Colors.green[50] : Colors.red[50],
                    child: Icon(
                      transactionType == 'Credit'
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: numberColor,
                    ),
                  ),
                  onTap: () {
                    // Navigate to a new page for that specific person
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PersonDetailScreen(userId: id),
                    ));
                  },
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

class PersonDetailScreen extends StatelessWidget {
  final String userId;

  PersonDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(userId: userId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _generatePdf(context as double, userId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User details section
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users')
                .doc(userId)
                .get(),
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

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${user['Name']}', style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16.0),
                    Text('Total Amount: ₹${user['Amount'] ?? 0}'),
                    Text('Interest Rate: ${user['Interest'] ?? 0}%'),
                    Text('Transaction Type: ${user['Transaction Type']}'),
                  ],
                ),
              );
            },
          ),
          // Transactions list section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection(
                  'transactions') // Assuming transactions are stored under user document
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

                return ListView(
                  children: transactions.map((doc) {
                    var transaction = doc.data() as Map<String, dynamic>;
                    var amount = transaction['Amount'] ?? 0.0;
                    var transactionType = transaction['Transaction Type'] ??
                        'Unknown';
                    var timestamp = transaction['timestamp']?.toDate() ??
                        DateTime.now();

                    Color backgroundColor = transactionType == 'Credit'
                        ? Colors.green[50]!
                        : Colors.red[50]!;
                    Color numberColor = transactionType == 'Credit' ? Colors
                        .green : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      child: Container(
                        color: backgroundColor,
                        child: ListTile(
                          title: Text(transactionType),
                          subtitle: Text(timeago.format(timestamp)),
                          trailing: Text(
                            '₹${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: numberColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context, userId);
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  void _showAddTransactionDialog(BuildContext context, String userId) {
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

                  // Generate PDF
                  _generatePdf(amount, transactionType);

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

  Future<void> _generatePdf(double amount, String transactionType) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                      'Transaction Receipt', style: pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 20),
                  pw.Text('Amount: ₹${amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.Text('Transaction Type: $transactionType',
                      style: pw.TextStyle(fontSize: 18)),
                  pw.SizedBox(height: 20),
                  pw.Text('Thank you for your transaction!',
                      style: pw.TextStyle(fontSize: 16)),
                ],
              ),
            );
          },
        ),
      );

      // Generate PDF and handle errors
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          print("Generating PDF...");
          return pdf.save();
        },
      );

      print("PDF generated successfully!");
    } catch (e) {
      print("Error generating PDF: $e");
      // Show a Snackbar or dialog with the error message
      // e.g., ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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

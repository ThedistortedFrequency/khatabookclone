import 'package:khatabookclone/addcustomer.dart';
import 'package:khatabookclone/bottamnavigator/personalDetails.dart';
import 'package:khatabookclone/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khatabookclone/widgets/customfab.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;



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


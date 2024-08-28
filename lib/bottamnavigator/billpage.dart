import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Transactions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }

          var userDocs = snapshot.data!.docs;

          // Calculate totals
          double totalAmount = 0.0;
          int totalInterest = 0;

          List<Widget> transactionWidgets = userDocs.map((doc) {
            var user = doc.data() as Map<String, dynamic>;
            var transactionType = user['Transaction Type'] ?? 'Unknown';
            var amount = double.tryParse(user['Amount'] ?? '0') ?? 0.0;
            var interestRate = double.tryParse(user['Interest'] ?? '0') ?? 0.0;
            var timestamp = user['timestamp']
                ?.toDate(); // Convert Firestore timestamp to DateTime

            // Calculate and round off interest amount
            int interestAmount = (amount * (interestRate / 100)).round();

            // Update totals
            totalAmount += amount;
            totalInterest += interestAmount;

            // Format date
            String formattedDate = timestamp != null
                ? DateFormat('dd MMM yyyy').format(timestamp)
                : 'No Date';

            // Determine the color based on the transaction type
            Color backgroundColor = transactionType == 'Credit'
                ? Colors.lightGreen[50]!
                : Colors.red[50]!;
            Color numberColor =
                transactionType == 'Credit' ? Colors.green : Colors.red;

            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: 16.0), // Padding between items
              child: Container(
                color: backgroundColor,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.all(16.0), // Padding inside the ListTile
                  title: Text(user['Name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${user['Phone Number']}'),
                      Text('Date: $formattedDate'),
                      Text(
                          'Interest Rate: $interestRate%'), // Display interest rate
                      SizedBox(height: 8.0), // Spacing between text elements
                      Text('Amount: ₹${amount.toStringAsFixed(2)}'),
                      Text(
                          'Interest Amount: ₹$interestAmount'), // Display rounded interest amount
                      SizedBox(height: 8.0), // Spacing before the total summary
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Total Amount Including Interest: ₹',
                              style: TextStyle(
                                color: Colors.black, // Default color for text
                              ),
                            ),
                            TextSpan(
                              text:
                                  (amount + interestAmount).toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: numberColor, // Color for the amount
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    transactionType == 'Credit'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: numberColor,
                  ),
                  leading: Icon(
                    Icons.account_circle,
                    color: numberColor,
                  ),
                ),
              ),
            );
          }).toList();

          return ListView(
            children: transactionWidgets,
          );
        },
      ),
    );
  }
}

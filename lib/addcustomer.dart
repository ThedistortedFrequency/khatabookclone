import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showCustomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        snap: true,
        initialChildSize: 0.7, // Adjust this as needed (0.0 to 1.0 scale)
        minChildSize: 0.3, // Minimum size when dragged
        maxChildSize: 1.0, // Maximum size when dragged
        builder: (BuildContext context, ScrollController scrollController) {
          return _ScrollableContent(scrollController: scrollController);
        },
      );
    },
  );
}

class _ScrollableContent extends StatefulWidget {
  final ScrollController scrollController;

  const _ScrollableContent({required this.scrollController});

  @override
  __ScrollableContentState createState() => __ScrollableContentState();
}

class __ScrollableContentState extends State<_ScrollableContent> {
  final FocusNode _interestFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _transactionTypeController =
      TextEditingController();

  String? _phoneNumberError;
  String? _selectedTransactionType;

  @override
  void initState() {
    super.initState();

    // Add a listener to the FocusNode to respond to focus changes
    _interestFocusNode.addListener(() {
      if (_interestFocusNode.hasFocus) {
        // Wait a moment for the keyboard to appear and then scroll
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToFocus();
        });
      }
    });

    _phoneController.addListener(() {
      setState(() {
        _phoneNumberError = _validatePhoneNumber(_phoneController.text);
      });
    });
  }

  @override
  void dispose() {
    _interestFocusNode.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _interestController.dispose();
    _transactionTypeController.dispose();
    super.dispose();
  }

  Future<void> addUserDetails(
    BuildContext context,
    String name,
    String phoneNo,
    double amount,
    double interest,
    String transactionType,
  ) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Add user details to Firestore
      await FirebaseFirestore.instance.collection("users").add({
        "timestamp": FieldValue.serverTimestamp(),
        "Name": name,
        "Phone Number": phoneNo,
        "Amount": amount,
        "Interest": interest,
        "Transaction Type": transactionType,
      });

      // Dismiss the loading dialog
      Navigator.of(context).pop(); // Close the loading dialog

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissal by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('User details added successfully'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the success dialog
                  Navigator.of(context)
                      .pop(); // Close the bottom sheet or previous page
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle errors
      print("Error adding user: $e"); // Debugging output
      // Dismiss the loading dialog
      Navigator.of(context).pop(); // Close the loading dialog

      await showDialog(
        context: context,
        barrierDismissible:
            true, // Allow dismissing by tapping outside the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text("Failed to add user details: $e"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the error dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _handleSubmit() {
    final name = _nameController.text;
    final phoneNo = _phoneController.text;
    final amountText = _amountController.text;
    final interestText = _interestController.text;
    final transactionType = _selectedTransactionType;

    // Validate all fields
    final phoneNumberError = _validatePhoneNumber(phoneNo);
    if (name.isEmpty ||
        phoneNo.isEmpty ||
        amountText.isEmpty ||
        interestText.isEmpty ||
        transactionType == null ||
        phoneNumberError != null) {
      // Show an error dialog if any field is empty, transactionType is null, or phone number is invalid
      showDialog(
        context: context,
        barrierDismissible:
            true, // Allow dismissing by tapping outside the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Validation Error'),
            content: Text(phoneNumberError ?? 'Please fill in all fields'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Convert amount and interest to double
    final double amount = double.tryParse(amountText) ?? 0.0;
    final double interest = double.tryParse(interestText) ?? 0.0;

    // Call addUserDetails with validated data
    addUserDetails(
      context,
      name,
      phoneNo,
      amount,
      interest,
      transactionType,
    );
  }

  String? _validatePhoneNumber(String value) {
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  void _scrollToFocus() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final scrollController = widget.scrollController;
        final context = _interestFocusNode.context;
        if (context != null) {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            final screenHeight = MediaQuery.of(context).size.height;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final targetOffset =
                position.dy - (screenHeight - keyboardHeight) * 0.3;

            scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(16)), // Rounded top corners
      ),
      child: ListView(
        controller: widget.scrollController,
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.manual,
        children: <Widget>[
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: const OutlineInputBorder(),
              errorText: _phoneNumberError,
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10, // Limit input to 10 characters
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTransactionType,
            decoration: const InputDecoration(
              labelText: 'Transaction Type',
              border: OutlineInputBorder(),
            ),
            items: <String>['Credit', 'Debit'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTransactionType = newValue;
                _transactionTypeController.text = newValue ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _interestController,
            focusNode: _interestFocusNode,
            decoration: const InputDecoration(
              labelText: 'Interest',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Vertical padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('ADD TRANSACTION'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal, // Text color
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Vertical padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Rounded corners
                    ),
                  ),
                  child: const Text('CLOSE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

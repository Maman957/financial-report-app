import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_report_app/pages/edit_transaction_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpanseTransectionWidget extends StatefulWidget {
  const ExpanseTransectionWidget({super.key});

  @override
  State<ExpanseTransectionWidget> createState() =>
      _ExpanseTransectionWidgetState();
}

class _ExpanseTransectionWidgetState extends State<ExpanseTransectionWidget> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final CollectionReference trasactionCollection =
      FirebaseFirestore.instance.collection('transactions');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _deletTransaction(String? transactionsId) async {
    try {
      if (transactionsId != null) {
        await trasactionCollection.doc(transactionsId).delete();
      }
    } catch (error) {
      print('Error delete transaction : $error');
    }

    var message = "Successfully delete transaction";

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firebaseFirestore
          .collection('transactions')
          .where('email', isEqualTo: _firebaseAuth.currentUser!.email)
          .where('type', isEqualTo: "Pengeluaran")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Transaction'));
        }

        return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;

          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (builder) => EditTransactionPage(
                    docId: data['docId'],
                  ),
                ),
              );
            },
            onLongPress: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.leftSlide,
                showCloseIcon: true,
                title: "Create Transaction",
                desc:
                    "Are you sure want to delete this transaction ${data['category']} ?",
                btnOkOnPress: () async {
                  _deletTransaction(data['docId']);
                },
                btnCancelOnPress: () {},
              ).show();
            },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: data['type'] == 'Pemasukan'
                      ? Image.asset('assets/icon_in.png')
                      : Image.asset('assets/icon_out.png'),
                ),
                title: Text(data['category']),
                subtitle: Text(data['detail']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rp. ${data['nominal'].toString()}",
                      style: TextStyle(
                          color: data['type'] == "Pemasukan"
                              ? Colors.green
                              : Colors.red),
                    ),
                    Text("${data['datetime']}")
                  ],
                ),
              ),
            ),
          );
        }).toList());
      },
    );
  }
}

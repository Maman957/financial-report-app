import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateTransactionPage extends StatefulWidget {
  final String userEmail;
  const CreateTransactionPage({super.key, required this.userEmail});

  @override
  State<CreateTransactionPage> createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  CollectionReference trasactionCollection =
      FirebaseFirestore.instance.collection('transactions');

  static const List<String> listCategory = [
    'Traveling',
    'Bulanan',
    'Transportasi',
    'Gaji',
    'Uang Masuk',
    'Uang Keluar',
  ];

  String category = listCategory.first;

  String type = "";
  String datetime = "";
  String detail = "";
  final currentDate = DateTime.now();

  Future<void> _createTransaction() async {
    int nominal = int.parse(_nominalController.text);
    detail = _detailController.text;

    try {
      DocumentReference documentReference = await trasactionCollection.add({
        "email": widget.userEmail,
        "type": type,
        "category": category,
        "detail": detail,
        "datetime": datetime,
        "nominal": nominal,
      });

      String docId = documentReference.id;

      await documentReference.update({
        'docId': docId,
      });
    } catch (error) {
      print("error creating transaction : $error");
    }

    var message = "Success add transaction $detail";

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Transaction"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _fromKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RadioListTile(
                          value: "Pemasukan",
                          groupValue: type,
                          title: const Text("Pemasukan"),
                          onChanged: (value) {
                            setState(() {
                              type = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          value: "Pengeluaran",
                          groupValue: type,
                          title: const Text("Pengeluaran"),
                          onChanged: (value) {
                            setState(() {
                              type = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text("Category"),
                      DropdownButton(
                        value: category,
                        items: listCategory.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            category = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    label: Text("Nominal"),
                    prefixIcon: Icon(Icons.money_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nominal cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    prefix: Icon(Icons.timeline),
                    label: Text("Waktu"),
                    hintText: 'dd/MM/yyyy',
                  ),
                  textInputAction: TextInputAction.next,
                  controller: _waktuController,
                  onTap: () async {
                    DateTime? selectDate = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(currentDate.year + 5),
                    );
                    setState(
                      () {
                        if (selectDate != null) {
                          _waktuController.text =
                              DateFormat('dd/MM/yyyy').format(selectDate);
                          datetime = _waktuController.text;
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  maxLength: 50,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    label: Text("Detail"),
                    prefixIcon: Icon(Icons.details_sharp),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Detail cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                  ),
                  onPressed: () {
                    if (_fromKey.currentState!.validate()) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.leftSlide,
                        showCloseIcon: true,
                        title: "Create Transaction",
                        desc: "Are you sure want to add this transaction ?",
                        btnOkOnPress: () async {
                          await _createTransaction();
                          Navigator.of(context).pop();
                        },
                        btnCancelOnPress: () {},
                      ).show();
                    }
                  },
                  child: const Text("Create Transaction"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

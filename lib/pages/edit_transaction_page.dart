import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTransactionPage extends StatefulWidget {
  final String docId;
  const EditTransactionPage({super.key, required this.docId});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
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

  void fetchDataTransaction() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('transactions')
              .doc(widget.docId)
              .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data()!;
        type = data['type'] ?? "";
        category = data['category'] ?? "";
        _detailController.text = data['detail'] ?? "";
        _waktuController.text = data['datetime'] ?? "";
        _nominalController.text = data['nominal'].toString();
      }
    } catch (error) {
      print("Error fetching data transaction : $error");
    }
  }

  void editTransaction() async {
    int nominal = int.parse(_nominalController.text);
    detail = _detailController.text;
    datetime = _waktuController.text;

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          FirebaseFirestore.instance
              .collection('transactions')
              .doc(widget.docId);

      await documentReference.update({
        'type': type,
        'category': category,
        'detail': detail,
        'datetime': datetime,
        'nominal': nominal,
      });

      print("Transaction update successfully");
    } catch (eror) {
      print("Error update transaction : $eror");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaction"),
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
                        title: "Edit Transaction",
                        desc: "Are you sure want to update this transaction ?",
                        btnOkOnPress: () async {
                          editTransaction();
                          Navigator.of(context).pop();
                        },
                        btnCancelOnPress: () {},
                      ).show();
                    }
                  },
                  child: const Text("Edit Transaction"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

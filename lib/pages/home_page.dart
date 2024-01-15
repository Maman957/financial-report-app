import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_report_app/pages/auth/login_page.dart';
import 'package:financial_report_app/services/database_service.dart';
import 'package:financial_report_app/widgets/top_5_transaction_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseServices databaseServices = DatabaseServices();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference trasactionCollection =
      FirebaseFirestore.instance.collection('transactions');
  final String incomeType = 'Pemasukan';
  final String expamseType = 'Pengeluaran';

  num totalBalance = 0;
  double percentage = 0.0;

  late RefreshController _refreshController;

  num totalIncome = 0;
  num totalExpanse = 0;

  Future<num> _getTotalAmount(String type) async {
    QuerySnapshot<Object?> querySnapshot = await trasactionCollection
        .where('type', isEqualTo: type)
        .where('email', isEqualTo: _firebaseAuth.currentUser!.email)
        .get();

    num totalAmount = 0;

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot
        .docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>) {
      totalAmount += document['nominal'] ?? 0;
    }

    return totalAmount;
  }

  Future<void> _loadData() async {
    totalIncome = await _getTotalAmount(incomeType);
    totalExpanse = await _getTotalAmount(expamseType);
    _refreshController.refreshCompleted;

    setState(() {
      totalBalance = totalIncome - totalExpanse;
      percentage = (totalBalance / totalIncome) * 100;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () async {
          await _loadData();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Welcome, ",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder(
                          future: databaseServices.getUserName(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Error ${snapshot.error}");
                            } else {
                              return Text(
                                "${snapshot.data}",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: IconButton(
                        onPressed: () {
                          databaseServices.signOut();

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Balance',
                                    style: GoogleFonts.acme(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rp. $totalBalance',
                                    style: GoogleFonts.acme(
                                      color: Colors.green,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Percentage',
                                  style: GoogleFonts.acme(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                percentage > 0.0
                                    ? CircularPercentIndicator(
                                        radius: 50,
                                        animation: true,
                                        animationDuration: 1200,
                                        lineWidth: 15,
                                        percent: percentage / 100,
                                        center: Text(
                                          '${percentage.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : const Text('Persen tidak boleh min')
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Total Income',
                              style: GoogleFonts.acme(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp. $totalIncome',
                              style: GoogleFonts.acme(
                                color: Colors.green,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Total Expanse',
                              style: GoogleFonts.acme(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp. $totalExpanse',
                              style: GoogleFonts.acme(
                                color: Colors.red,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Top 5 Transaction',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Top5TransactionWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

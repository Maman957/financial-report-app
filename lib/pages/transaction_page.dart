import 'package:financial_report_app/widgets/all_transaction_widget.dart';
import 'package:financial_report_app/widgets/expanse_transaction_widget.dart';
import 'package:financial_report_app/widgets/income_transaction_widget.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Transaction"),
          automaticallyImplyLeading: false,
          centerTitle: true,
          bottom: const TabBar(isScrollable: true, tabs: [
            Text("All Transaction"),
            Text("Income Transaction"),
            Text("Expanse Transaction"),
          ]),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: TabBarView(
            children: [
              AllTransactionWidget(),
              IncomeTransactionWidget(),
              ExpanseTransectionWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

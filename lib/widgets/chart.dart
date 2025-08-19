import '/widgets/chart_bar.dart';

import '../models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chart extends StatelessWidget {
  final List<Transaction> recentTransactions;
  Chart(this.recentTransactions);
  List<Map<String, Object>> get groupedTransactionValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      // exemple:
      // index = 0 → weekDay = 2025-08-16 10:30
      // index = 1 → weekDay = 2025-08-15 10:30
      // index = 2 → weekDay = 2025-08-14 10:30
      // index = 3 → weekDay = 2025-08-13 10:30
      // index = 4 → weekDay = 2025-08-12 10:30
      // index = 5 → weekDay = 2025-08-11 10:30
      // index = 6 → weekDay = 2025-08-10 10:30

      // this line is just calculating the exact date for each of the last 7 days.
      // Then later, the code checks: “Do I have any transactions on that day? If yes, sum them up.”

      var totalSum = 0.0;
      // How much money was spent on this specific day?
      for (var i = 0; i < recentTransactions.length; i++) {
        if (recentTransactions[i].date.day == weekDay.day &&
            recentTransactions[i].date.month == weekDay.month &&
            recentTransactions[i].date.year == weekDay.year) {
          totalSum += recentTransactions[i].amount;
        }
      }
      // 👆 every transaction for this day is added here

      // print(DateFormat.E().format(weekDay));
      // return {'day': DateFormat.E().format(weekDay).substring(0, 1),
      // 'amount': totalSum};

      return {
        'day': DateFormat.E().format(weekDay),
        'amount': totalSum,
      }; // 👈 total spending of this day
    }).reversed.toList();
  }

  double get totalSpending {
    return groupedTransactionValues.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(groupedTransactionValues);
    print('build () Chart');
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransactionValues.map((data) {
            // tight = "Stretch me to fill the available space."
            // loose = "Let me be my natural size, unless there's extra room."
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                data['day'] as String,
                data['amount'] as double,
                totalSpending == 0.0
                    ? 0.0
                    : (data['amount'] as double) / totalSpending,
              )
            );
          }).toList(),
        ),
      ),
    );
  }
}

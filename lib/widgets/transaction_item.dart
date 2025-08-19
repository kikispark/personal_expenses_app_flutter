import '../models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    required this.deleteTransaction,
  });
  //key:
  // This widget represents a single transaction row.
  // It’s used inside a ListView.builder, which creates multiple TransactionItem
  // A repeated child in a ListView → needs keys so Flutter can track items across rebuilds.
  //   Without keys: Flutter might think Item B is a new widget (and rebuild it).
  // ➡️ With keys: Flutter sees oh, that’s still Item B (same key) → reuses it, no rebuild needed
  // Flutter automatically passes the key to super.key (the parent StatelessWidget).
  // The key is used internally by Flutter to track this widget in the Element tree and decide whether to rebuild or reuse it.
  final Transaction transaction;
  final Function(String id) deleteTransaction;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          // FittedBox takes a child widget and scales it up or down so it fits inside the FittedBox’s own constraints.so items shrink a bit
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(child: Text('\$${transaction.amount}')),
          ),
        ),
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
        trailing: MediaQuery.of(context).size.width > 460
            ? TextButton.icon(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onPressed: () {},
              )
            : IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(
                  context,
                ).colorScheme.error, // <-- use colorScheme.error
                onPressed: () {
                  deleteTransaction(transaction.id);
                },
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewTransaction extends StatefulWidget {
  final Function addTx;

  NewTransaction(this.addTx);

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

// your State already has access to context
class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return; // If the  amount field is empty, do nothing
    }
    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);
    if (enteredTitle.isEmpty || enteredAmount <= 0 || _selectedDate == null) {
      return;
    }
    // MyHomePage passes _addNewTransaction into NewTransaction.
    // NewTransaction stores it in widget.addTx.
    // When the user submits, widget.addTx(enteredTitle, enteredAmount) runs → which is really _addNewTransaction(enteredTitle, enteredAmount)
    // The widget that receives it decides when and with what values to actually call it.
    widget.addTx(enteredTitle, enteredAmount, _selectedDate!);
    Navigator.of(context).pop();
  }

  // context :
  // In Flutter, context is a BuildContext object.
  // You can think of it as a reference to where your widget is inside the widget tree.
  // So whenever Flutter builds a widget, it gives you a BuildContext to know “where in the tree am I?”
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }
  //the Future Dart’s way of saying: “I’ll give you the result later, when the user finishes.like Promise in JS
  // Future<T> = a value of type T that you’ll get later.

  // showDatePicker returns a Future<DateTime?> because the user interaction takes time.

  // You use .then(...) or await to get the actual value once it’s ready.

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                10, // <== This moves your content above the keyboard and gives a little breathing room (10 pixels).
            // Without this, your content could be obstructed by the keyboard when it appears
            // So MediaQuery.of(context).viewInsets.bottom dynamically gives you how much space at the bottom is taken up by the keyboard.
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: _titleController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Amount'),
                controller: _amountController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _submitData,
              ),
              Container(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No Date Chosen!'
                            : 'Picked Date : ${DateFormat.yMd().format(_selectedDate!)}',
                        // The ! tells Dart: “I’m sure _selectedDate is not null here” (safe because you already checked _selectedDate == null ?
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: _presentDatePicker,
                      child: Text(
                        'Choose Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: TextButton.styleFrom(
                  // Theme.of(context).textTheme.labelLarge can be null, because labelLarge is an optional property
                  foregroundColor: Theme.of(
                    context,
                  ).textTheme.labelLarge?.color,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: _submitData,
                child: Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

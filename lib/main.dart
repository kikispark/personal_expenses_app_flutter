import '/widgets/transaction_list.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '/widgets/new_transaction.dart';

import 'package:flutter/material.dart';
import './widgets/chart.dart';

// Widget Tree = the blueprints of a house (immutable, you redraw when changes are needed).and They are just blueprints/configurations that describe what the UI should look like.

// Element Tree = the construction manager, who applies updates without tearing down the whole house.and Elements are the bridge between Widgets and the Render objects.

// Unlike widgets, Elements are mutable (they stay alive as long as possible).

// They hold:

// A reference to the Widget (blueprint)

// A link to the RenderObject (that actually paints pixels)

// Elements handle the lifecycle: update, rebuild, attach/detach.

// Render Tree = the actual house (bricks, walls, windows → pixels on screen).
//============>Widget Tree → describes the UI (immutable blueprints).

// Element Tree → keeps widgets alive, manages updates & connects them to the render objects.

// Together, they let Flutter rebuild parts of the UI efficiently, instead of redrawing everything from scratch

// The Render Tree is made of RenderObjects.

// A RenderObject is the thing that does the heavy work:

// Layout → figures out size & position of widgets.

// Painting → draws them on the screen using the Skia graphics engine.

// Hit testing → detects taps/gestures on widgets.

// 📌 Think of the Render Tree as the actual bricks and paint of the house — the physical thing you see and interact with on screen.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  //=====>This **locks the device orientation** of your app.
  runApp(MyApp());
}

// Lift state up:
// You move the shared state to the closest common parent:
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        fontFamily: 'Quicksand',
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          errorColor: Colors.red,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];

  bool _showChart = false;

  @override
  void didChangeAppLifeCycleState(AppLifecycleState state) {}

  //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  // ===>_recentTransactions contains only the transactions from the last 7 days.

  void _addNewTransaction(
    String txTitle,
    double txAmount,
    DateTime chosenDate,
  ) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    ); // <== named parameter

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewTransaction(_addNewTransaction);
      },
    );
  }
  //here" NewTransaction(_addNewTransaction);"" you are not calling _addNewTransaction.
  // Instead, you are passing a reference to the function into the NewTransaction widget.

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((trans) => trans.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Show Chart '),
          Switch(
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height:
                  (mediaQuery.size.height - //<===total screen height
                      appBar.preferredSize.height - //<===height of the app bar
                      mediaQuery.padding.top) *
                  0.7, //<===top padding (usually the status bar height).
              // this gives you a height = 30% of the free space on the screen (after removing the AppBar + top system bar).
              child: Chart(_recentTransactions),
            )
          : txListWidget,
    ];
  }

  List<Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
        height:
            (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget,
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('build () MyHomePageState');
    // print('recent: $_recentTransactions');
    final isLandscape =
        MediaQuery.of(context).orientation ==
        Orientation.landscape; //<===check the orientation of the device
    //we use final because it calculated for every build run when flutter rebuilds UI

    final mediaQuery = MediaQuery.of(context);

    final appBar = AppBar(
      title: Text('Personal Expenses'),

      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _startAddNewTransaction(context);
          },
        ),
      ],
    );

    final txListWidget = Container(
      height:
          (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandscapeContent(
                mediaQuery,
                appBar,
                txListWidget,
              ), //  <==== if(isLandscape) its future from dart it check if true show in the list if no element added
            if (!isLandscape)
              ..._buildPortraitContent(mediaQuery, appBar, txListWidget),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // <== platform.isIOS u can check
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.add),
        onPressed: () {
          _startAddNewTransaction(context);
        },
      ),
    );
  }
}

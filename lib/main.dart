import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final loanAmountCtrl = TextEditingController();
  final netIncomeController = TextEditingController();
  final rateController = TextEditingController();
  final yearController = TextEditingController();
  final downPaymentController = TextEditingController();

//To set focus to the first TextField
  final _myFocusNode = FocusNode();

//To format output with the currency symbol of Malaysia
  final myCurrency = intl.NumberFormat('#,##0.00', 'ms_MY');

//To set a form key for the Form widget, which acts as a container for form fields
//and manages the overall form state.
  final _formKey = GlobalKey<FormState>();
  double _repayment = 0.0;
  String _repaymentText = '';
  late double _loanAmount = 0.0;
  late double _interestRate = 0.0;
  int _loanPeriod = 1;
  int _made = 1;
  final years = [1, 2, 3, 4, 5, 6, 7];
  var _hasGuarantor = false;

//To show a dialog if the user is not eligible for a car loan
  late AlertDialog eligibilityAlertDialog;

  void myAlertDialog() {
    eligibilityAlertDialog = AlertDialog(
      title: const Text('Eligibility'),
      content: const Text(
          'You are not eligible for this loan. Get a guarantor to proceed.'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK')),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return eligibilityAlertDialog;
        });
  }

  void _calculateRepayment() {
    _loanAmount = double.parse(loanAmountCtrl.text);
    _interestRate = double.parse(rateController.text);
    var interest = _loanAmount * _loanPeriod * (_interestRate / 100);
    _repayment = (_loanAmount + interest) / (_loanPeriod * 12);
    bool eligible = double.parse(netIncomeController.text) * 0.3 >= _repayment;
    if (!eligible && !_hasGuarantor) {
      myAlertDialog();
      setState(() {
        _repaymentText =
        'Repayment Amount : $myCurrency '
            '$_repayment \n '
            'Eligibility : ${eligible ? 'Eligible' : 'Not Eligible'}';
      });
    } else {
      myAlertDialog();
    }
  }

  @override
  void dispose() {
    loanAmountCtrl.dispose();
    rateController.dispose();
    yearController.dispose();
    downPaymentController.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text(widget.title),
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'Loan Amount',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: loanAmountCtrl,
                  focusNode: _myFocusNode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter loan amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'Net income',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: netIncomeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter net income';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  value: _loanPeriod,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: years.map((int item){
                    return DropdownMenuItem(
                      value: item,
                      child: Text('$item'),
                    );
                  }).toList(),
                  onChanged: (int? item) {
                    setState(() {
                      _loanPeriod = item!;
                    });
                  },
                  validator: (value) {
                    if (value == 0) {
                      return 'Please select an option';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Select loan period (year)',
                  ),
                ),

                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate (%)'
                  ),
                  controller: rateController,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return 'Please enter interest rate';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                    value: _hasGuarantor,
                    title: const Text('I have a guarantor'),
                    onChanged: (value) {
                      setState(() {
                        _hasGuarantor = value!;
                      });
                    }),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Car Type', textDirection: TextDirection.ltr,)
                ),
                RadioListTile(
                  value: 1,
                  groupValue: _made,
                  onChanged: (value) {
                    setState(() {
                      _made = value!;
                    });
                  }),
                RadioListTile(
                  value: 2,
                  groupValue: _made,
                  onChanged: (value) {
                    setState(() {
                      _made = value!;
                    });
                  }),
                Text(
                  'Repayment Amount: $_repaymentText',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const Expanded(child: SizedBox()),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _calculateRepayment();
                      }
                    },
                    child: const Text('Calculate')),
              ],
            ),
          ),
        ),
      );
    }
}

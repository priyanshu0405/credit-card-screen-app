import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:creditCard_screen/model.dart';
import 'package:creditCard_screen/input.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Strings.appName,
      theme: Theme.of(context).copyWith(
        primaryColor: Colors.black,
      ),
      home: new MyHomePage(title: Strings.appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = new GlobalKey<FormState>();
  var numberController = new TextEditingController();
  var _paymentCard = PaymentCard();
  var _autoValidate = false;

  var _card = new PaymentCard();

  @override
  void initState() {
    super.initState();
    _paymentCard.type = CardType.Others;
    numberController.addListener(_getCardTypeFrmNumber);
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Payment Successful"),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Center(
            child: new Text(
              widget.title,
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Color(0xffFEDBD0),
        ),
        body: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: new Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: new ListView(
                children: <Widget>[
                  new SizedBox(
                    height: 50.0,
                  ),
                  new TextFormField(
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      focusColor: Colors.black,
                      filled: true,
                      icon: const Icon(
                        Icons.person,
                        size: 40.0,
                      ),
                      hintText: 'Name on card',
                      labelText: 'Card Name',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    onSaved: (String value) {
                      _card.name = value;
                    },
                    keyboardType: TextInputType.text,
                    validator: (String value) =>
                        value.isEmpty ? Strings.fieldReq : null,
                  ),
                  new SizedBox(
                    height: 30.0,
                  ),
                  new TextFormField(
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(16),
                      new CardNumberInputFormatter()
                    ],
                    controller: numberController,
                    decoration: new InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      focusColor: Colors.black,
                      filled: true,
                      icon: const Icon(
                        Icons.credit_card,
                        size: 40.0,
                      ),
                      hintText: 'Card number',
                      labelText: 'Number',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    onSaved: (String value) {
                      print('onSaved = $value');
                      print('Num controller has = ${numberController.text}');
                      _paymentCard.number = CardUtils.getCleanedNumber(value);
                    },
                    validator: CardUtils.validateCardNum,
                  ),
                  new SizedBox(
                    height: 30.0,
                  ),
                  new TextFormField(
                    cursorColor: Colors.black,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(
                          _paymentCard.type == CardType.AmericanExpress
                              ? 4
                              : 3),
                    ],
                    decoration: new InputDecoration(
                      border: OutlineInputBorder(),
                      focusColor: Colors.black,
                      focusedBorder: OutlineInputBorder(),
                      filled: true,
                      icon: new Image.asset(
                        'images/cvv.png',
                        width: 40.0,
                      ),
                      hintText: 'Number behind the card',
                      labelText: 'CVV',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: CardUtils.validateCVV,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _paymentCard.cvv = int.parse(value);
                    },
                  ),
                  new SizedBox(
                    height: 30.0,
                  ),
                  new TextFormField(
                    cursorColor: Colors.black,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      new LengthLimitingTextInputFormatter(4),
                      new CardMonthInputFormatter()
                    ],
                    decoration: new InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      focusColor: Colors.black,
                      filled: true,
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 40.0,
                      ),
                      hintText: 'MM/YY',
                      labelText: 'Expiry Date',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    validator: CardUtils.validateDate,
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      List<int> expiryDate = CardUtils.getExpiryDate(value);
                      _paymentCard.month = expiryDate[0];
                      _paymentCard.year = expiryDate[1];
                    },
                  ),
                  new SizedBox(
                    height: 50.0,
                  ),
                  new Container(
                    alignment: Alignment.center,
                    child: _getPayButton(),
                  )
                ],
              )),
        ));
  }

  @override
  void dispose() {
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardType cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      this._paymentCard.type = cardType;
    });
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() {
        _autoValidate = true;
      });
    } else {
      form.save();
      showAlertDialog(context);
    }
  }

  Widget _getPayButton() {
    return new RaisedButton(
      onPressed: _validateInputs,
      color: Color(0xffFEEAE6),
      splashColor: Color(0xffFEDBD0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(100.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
      textColor: Colors.black,
      child: new Text(
        Strings.pay.toUpperCase(),
        style: const TextStyle(fontSize: 17.0),
      ),
    );
  }
}

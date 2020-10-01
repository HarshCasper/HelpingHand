import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sosDialog {

  TextEditingController _controller1 = new TextEditingController();
  TextEditingController _controller2 = new TextEditingController();
  TextEditingController _controller3 = new TextEditingController();
  TextEditingController _controller4 = new TextEditingController();

  Future<void> sosDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Enter phone numbers you would like to contact"),
              content: new SingleChildScrollView(
                  child: new ListBody(children: <Widget>[
                TextFormField(
                  controller: _controller4,
                  decoration: InputDecoration(
                    labelText: 'Enter your name:',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller1,
                  decoration: InputDecoration(
                    labelText: 'Enter phone number 1:',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller2,
                  decoration: InputDecoration(
                    labelText: 'Enter phone number 2:',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller3,
                  decoration: InputDecoration(
                    labelText: 'Enter phone number 3:',
                  ),
                ),
                new SizedBox(height: 10),
                new RaisedButton(
                  onPressed: () {
                    setNumbers((_controller1.text), (_controller2.text),
                        (_controller3.text), _controller4.text);
                  },
                  color: Hexcolor('eaac8b'),
                  child: Text(
                    "Save Information",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(16.0)),
                )
              ])));
        });
  }

  setNumbers(String n1, String n2, String n3, String n) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(n1);
    print(n2);
    print(n3);
    await prefs.setString('n1', n1);
    await prefs.setString('n2', n2);
    await prefs.setString('n3', n3);
    await prefs.setString('name', n);
  }
}

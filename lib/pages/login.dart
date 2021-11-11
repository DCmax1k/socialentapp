import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map data = {};

  String username = '';
  String password = '';

  bool hidePassword = true;
  String submitText = 'Submit';

  Future<void> loginData() async {
    try {
      setState(() {
        submitText = 'Loading...';
      });
      String postURL = 'https://www.socialentapp.com/login/fromapp';
      Response response = await post(Uri.parse(postURL), body: {
        'username': username,
        'password': password,
      });
      Map resJSON = jsonDecode(response.body);
      if (resJSON['response'] == 'logged in') {
        String authToken = resJSON['auth_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authToken);
        setState(() {
          submitText = 'Welcome!';
        });
        // Remove index route here
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false, arguments: {
          'auth_token': authToken,
          'user': resJSON['user'],
        });

        // Navigator.pushReplacementNamed(context, '/home', arguments: {
        //   'username': data['username'],
        //   'auth_token': authToken,
        // });
      } else {
        setState(() {
          submitText = 'Submit';
        });
        String errMessage = resJSON['response'].toUpperCase();
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Try again'),
            content: Text('$errMessage'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Ok');
                },
                child: Text('Ok'),
              )
            ],
          ),
        );
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments == null
            ? {}
            : ModalRoute.of(context)!.settings.arguments as Map;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage('assets/loginBackground.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Container(
              height: 550,
              padding: EdgeInsets.all(30),
              width: MediaQuery.of(context).size.width,
              // Color Dark
              color: Color.fromRGBO(15, 76, 117, 0.7),
              child: Column(
                children: [
                  Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Patrick',
                      color: Color.fromRGBO(187, 225, 250, 1),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  // Username column here
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Patrick',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ]),
                        child: TextFormField(
                          initialValue: data.isNotEmpty ? data['username'] : '',
                          onChanged: (string) {
                            setState(() {
                              username = string;
                            });
                          },
                          style: TextStyle(
                            color: Colors.grey[850],
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Password Column here
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Patrick',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.5),
                                spreadRadius: 0,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ]),
                        child: Stack(
                          children: [
                            // Password input
                            TextField(
                              onChanged: (string) {
                                setState(() {
                                  password = string;
                                });
                              },
                              style: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                              obscureText: hidePassword,
                            ),
                            // Hide/show password
                            Container(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    hidePassword = hidePassword ? false : true;
                                  });
                                },
                                child: hidePassword
                                    ? Icon(Icons.visibility)
                                    : Icon(Icons.visibility_off),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  // Submit Btn
                  TextButton(
                    onPressed: () {
                      if (username.isNotEmpty && password.isNotEmpty) {
                        loginData();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('Oops,'),
                            content: Text('Please fill out both fields!'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, 'Ok');
                                },
                                child: Text('Ok'),
                              )
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      submitText,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Patrick',
                        letterSpacing: 1,
                      ),
                    ),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(20),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )),
                      fixedSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width, 40),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(187, 225, 250, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Dont have account redirect
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/signup');
                    },
                    child: Text(
                      'Don\'t have an account? Sign up!',
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

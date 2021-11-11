import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Form variables
  String username = '';
  String password = '';
  String name = '';
  String email = '';

  // View variables
  bool hidePassword = true;
  String submitText = 'Submit';

  Future<void> signupData() async {
    try {
      setState(() {
        submitText = 'Loading...';
      });
      String postURL = 'https://www.socialentapp.com/signup';
      Response response = await post(Uri.parse(postURL), body: {
        'username': username,
        'password': password,
        'name': name,
        'email': email,
      });
      Map resJSON = jsonDecode(response.body);
      if (resJSON['response'] == 'account created') {
        setState(() {
          submitText = 'Redirecting...';
        });
        String authToken = resJSON['auth_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', authToken);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false, arguments: {
          'auth_token': authToken,
          'user': resJSON['user'],
        });
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
            Container(
              height: 600,
              padding: EdgeInsets.all(30),
              width: MediaQuery.of(context).size.width,
              // Color Dark
              color: Color.fromRGBO(15, 76, 117, 0.7),
              child: Column(
                children: [
                  Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Patrick',
                      color: Color.fromRGBO(187, 225, 250, 1),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Email column here
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Patrick',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
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
                        child: TextField(
                          onChanged: (string) {
                            setState(() {
                              email = string;
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
                  SizedBox(height: 10),
                  // Name Column here
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Patrick',
                            letterSpacing: 1,
                          ),
                        ),
                      ),
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
                        child: TextField(
                          onChanged: (string) {
                            setState(() {
                              name = string;
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
                  SizedBox(height: 10),
                  // Username Column here
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
                        child: TextField(
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
                  SizedBox(height: 10),
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
                            // Password Input
                            TextField(
                              obscureText: hidePassword,
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
                            ),
                            // Hide show password
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
                  SizedBox(height: 30),
                  // Submit Btn
                  TextButton(
                    onPressed: () {
                      if (username.isNotEmpty &&
                          password.isNotEmpty &&
                          email.isNotEmpty &&
                          name.isNotEmpty) {
                        signupData();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('Oops,'),
                            content: Text('Please fill out all of the fields!'),
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
                  SizedBox(height: 10),
                  // Dont have account redirect
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Already have an account? Log in',
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

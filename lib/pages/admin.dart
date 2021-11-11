import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Map user = {};
  Map data = {};
  List allUsers = [];

  @override
  void initState() {
    void getAdminData() async {
      String postURL = 'https://www.socialentapp.com/admin/getfromapp';
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token') ?? 'NoToken';
      Response response = await post(Uri.parse(postURL), body: {
        'auth_token': authToken,
      });
      if (response.body != 'Unauthorized') {
        Map resJSON = jsonDecode(response.body);
        setState(() {
          user = resJSON['user'];
          allUsers = resJSON['allUsers'];
          allUsers.sort((a, b) => a['dateJoined'] - b['dateJoined']);
        });
      } else {
        prefs.remove('auth_token');
        Navigator.pushReplacementNamed(context, '/index');
      }
    }

    getAdminData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments != null
            ? ModalRoute.of(context)!.settings.arguments as Map
            : {};
    user = data.isNotEmpty ? data['user'] : user;
    return Container(
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          elevation: 1,
          title: Text(
            'ADMIN',
            style: TextStyle(
              letterSpacing: 10,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey[850],
        ),
        body: ListView(
            children: allUsers.map((subUser) {
          // Users container
          return Container(
            color: Colors.grey[850],
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Stack(
              children: [
                // Side with name
                Center(
                  child: Row(
                    children: [
                      // IMG
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        height: 50,
                        width: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10000),
                          child: subUser['profileImg'] == 'none'
                              ? Image.asset('assets/profilePlaceholder.png')
                              : subUser['profileImg'].contains('http')
                                  ? Image.network(subUser['profileImg'])
                                  : Image.memory(base64.decode(
                                      subUser['profileImg'].split(',').last)),
                        ),
                      ),
                      // Names here
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.fromLTRB(0, 2.0, 0, 0)),
                              ),
                              onPressed: () {
                                // Go to users account here from pushNamed.
                              },
                              child: Row(
                                children: [
                                  if (subUser['prefix']['title'].isNotEmpty)
                                    Text(
                                      '[${subUser['prefix']['title']}]',
                                    ),
                                  if (subUser['prefix']['title'].isNotEmpty)
                                    SizedBox(width: 5),
                                  Text(
                                    subUser['username'],
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  subUser['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Side with controls
                Row(
                  children: [],
                ),
              ],
            ),
          );
        }).toList()),
      ),
    );
  }
}

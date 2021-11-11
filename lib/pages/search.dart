import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchContainer extends StatefulWidget {
  const SearchContainer({Key? key}) : super(key: key);

  @override
  _SearchContainerState createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  final keySearchResults = GlobalKey<_SearchResultsState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[200],
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: ListView(
              children: [
                SizedBox(height: 20),
                // Search bar
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(150, 150, 150, 1),
                    ),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    width: MediaQuery.of(context).size.width - 25,
                    child: TextField(
                      onChanged: (value) {
                        keySearchResults.currentState!.search(value.trim());
                      },
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'Patrick',
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                // Search Results
                SearchResults(
                  key: keySearchResults,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchResults extends StatefulWidget {
  SearchResults({Key? key}) : super(key: key);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List results = [];
  search(value) async {
    if (value.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      http.Response response = await http
          .post(Uri.parse('https://www.socialentapp.com/search'), body: {
        'auth_token': authToken,
        'value': value,
      });
      Map resJSON = jsonDecode(response.body);
      if (resJSON['searchedAccounts'].length != results.length) {
        setState(() {
          results = resJSON['searchedAccounts'];
        });
      }
    } else {
      setState(() {
        results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: results.reversed.map((searchedUser) {
          // Result
          return GestureDetector(
            onTap: () {
              print('Redirecting to ${searchedUser['username']}');
            },
            child: Container(
              clipBehavior: Clip.hardEdge,
              margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
              height: 100,
              width: MediaQuery.of(context).size.width - 25,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(100, 100, 100, 1),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(5, 5)),
                  ]),
              child: Row(
                children: [
                  // Profile image
                  Container(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        child: searchedUser['profileImg'] == 'none'
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10000),
                                child: Image.asset(
                                    'assets/profilePlaceholder.png'))
                            : searchedUser['profileImg'].contains('http')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10000),
                                    child: Image.network(
                                        searchedUser['profileImg']),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10000),
                                    child: Image.memory(base64.decode(
                                        searchedUser['profileImg']
                                            .split(',')
                                            .last)),
                                  ),
                      ),
                    ),
                  ),
                  // Username, name
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username
                        Container(
                          child: RichText(
                            text: TextSpan(
                                text: searchedUser['prefix']['title'].isNotEmpty
                                    ? '[${searchedUser['prefix']['title']}] '
                                    : '',
                                style: TextStyle(
                                  color: searchedUser['rank'] == 'owner'
                                      ? Colors.red
                                      : searchedUser['rank'] == 'admin'
                                          ? Colors.blue
                                          : Colors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: searchedUser['username'],
                                    style: TextStyle(
                                      color: Colors.grey[200],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ]),
                          ),
                          // Text(
                          //   searchedUser['username'],
                          //   style: TextStyle(
                          //     color: Colors.grey[200],
                          //     fontSize: 20,
                          //   ),
                          // ),
                        ),
                        // Name
                        Container(
                          child: Text(
                            searchedUser['name'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

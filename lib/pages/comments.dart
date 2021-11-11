import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Comments extends StatefulWidget {
  Comments({Key? key}) : super(key: key);

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  List comments = [];
  Map data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)!.settings.arguments != null
            ? ModalRoute.of(context)!.settings.arguments as Map
            : {};
    comments = comments.isNotEmpty ? comments : data['comments'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Container(
        child: SafeArea(
          child: ListView(
              children: comments.reversed.map((comment) {
            return Container(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 1),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color.fromRGBO(80, 80, 80, 1))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: RichText(
                      text: TextSpan(
                        text: comment['username'] + ' ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: comment['value'],
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Text(comment['date']),
                  ),
                ],
              ),
            );
          }).toList()),
        ),
      ),
    );
  }
}

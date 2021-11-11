import 'package:flutter/material.dart';

class MessagesContainer extends StatefulWidget {
  const MessagesContainer(this.user, {Key? key}) : super(key: key);
  final Map user;
  @override
  _MessagesContainerState createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  Map user = {};
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Text(
          'MESSAGES PAGE',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

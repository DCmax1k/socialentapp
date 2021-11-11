import 'package:flutter/material.dart';

class CreateContainer extends StatefulWidget {
  const CreateContainer({Key? key}) : super(key: key);

  @override
  _CreateContainerState createState() => _CreateContainerState();
}

class _CreateContainerState extends State<CreateContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: Text(
          'CREATE PAGE',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

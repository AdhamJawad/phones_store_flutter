import 'package:flutter/material.dart';

class RouteStubPage extends StatelessWidget {
  const RouteStubPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$title module placeholder'),
      ),
    );
  }
}

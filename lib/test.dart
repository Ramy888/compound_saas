import 'package:flutter/material.dart';

class Parentwidget extends StatelessWidget {
  final Childwidget childWidget = Childwidget();

  @override
  Widget build(BuildContext context) {
    print('ParentWidget build');

    return Scaffold(
      appBar: AppBar(title: Text('Lifecycle Example')),

      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnotherScreen()),
              );
            },
            child: Text('Go to Another Screen'),
          ),
          childWidget,
        ],
      ),
    );
  }
}

class Childwidget extends StatelessWidget {
  Childwidget() {
    print("ChildWidget constructor");
  }

  @override
  Widget build(BuildContext context) {
    print("ChileWidget build");

    return Text("Child widget");
  }
}

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Another Screen")));
  }
}

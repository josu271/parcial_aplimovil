import 'package:flutter/material.dart';

class UbicacionesScreen extends StatelessWidget {
  const UbicacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ubicaciones")), // ❌ sin const
      body: Center(
        child: Text(
          'Hello Ubicaciones!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

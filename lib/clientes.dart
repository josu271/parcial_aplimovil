import 'package:flutter/material.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clientes")), // ❌ quita el const
      body: Center(
        child: Text(
          'Hello Clientes!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _cargoCtrl = TextEditingController();
  final TextEditingController _fechaCtrl = TextEditingController();

  String _area = "cocina";
  String _estado = "activo";

  /// Crear empleado
  Future<void> crearEmpleado() async {
    try {
      await FirebaseFirestore.instance
          .collection('empleados')
          .doc(_dniCtrl.text) // usamos DNI como ID
          .set({
        'nombre': _nombreCtrl.text,
        'area': _area,
        'cargo': _cargoCtrl.text,
        'fecha_ingreso': Timestamp.fromDate(DateTime.parse(_fechaCtrl.text)),
        'estado': _estado,
      });

      limpiarCampos();
    } catch (e) {
      print("Error al crear empleado: $e");
    }
  }

  /// Actualizar empleado
  Future<void> actualizarEmpleado(String dni) async {
    try {
      await FirebaseFirestore.instance.collection('empleados').doc(dni).update({
        'nombre': _nombreCtrl.text,
        'area': _area,
        'cargo': _cargoCtrl.text,
        'fecha_ingreso': Timestamp.fromDate(DateTime.parse(_fechaCtrl.text)),
        'estado': _estado,
      });

      limpiarCampos();
    } catch (e) {
      print("Error al actualizar empleado: $e");
    }
  }

  /// Eliminar empleado
  Future<void> borrarEmpleado(String dni) async {
    try {
      await FirebaseFirestore.instance.collection('empleados').doc(dni).delete();
    } catch (e) {
      print("Error al borrar empleado: $e");
    }
  }

  void limpiarCampos() {
    _nombreCtrl.clear();
    _dniCtrl.clear();
    _cargoCtrl.clear();
    _fechaCtrl.clear();
    _area = "cocina";
    _estado = "activo";
  }

  /// Mostrar formulario en un diálogo (crear/editar)
  void mostrarFormulario({String? dni, Map<String, dynamic>? data}) {
    if (data != null) {
      _nombreCtrl.text = data['nombre'];
      _dniCtrl.text = dni!;
      _cargoCtrl.text = data['cargo'];
      _fechaCtrl.text =
          (data['fecha_ingreso'] as Timestamp).toDate().toIso8601String().split("T").first;
      _area = data['area'];
      _estado = data['estado'];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(dni == null ? "Agregar Empleado" : "Editar Empleado"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _dniCtrl,
                decoration: const InputDecoration(labelText: "DNI"),
                enabled: dni == null, // no editar DNI en update
              ),
              TextField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre completo"),
              ),
              DropdownButtonFormField<String>(
                value: _area,
                items: const [
                  DropdownMenuItem(value: "cocina", child: Text("Cocina")),
                  DropdownMenuItem(value: "atención", child: Text("Atención")),
                  DropdownMenuItem(value: "delivery", child: Text("Delivery")),
                  DropdownMenuItem(value: "administración", child: Text("Administración")),
                ],
                onChanged: (val) => setState(() => _area = val!),
                decoration: const InputDecoration(labelText: "Área"),
              ),
              TextField(
                controller: _cargoCtrl,
                decoration: const InputDecoration(labelText: "Cargo"),
              ),
              TextField(
                controller: _fechaCtrl,
                decoration: const InputDecoration(
                    labelText: "Fecha ingreso (YYYY-MM-DD)"),
              ),
              DropdownButtonFormField<String>(
                value: _estado,
                items: const [
                  DropdownMenuItem(value: "activo", child: Text("Activo")),
                  DropdownMenuItem(value: "inactivo", child: Text("Inactivo")),
                ],
                onChanged: (val) => setState(() => _estado = val!),
                decoration: const InputDecoration(labelText: "Estado"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              limpiarCampos();
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (dni == null) {
                crearEmpleado();
              } else {
                actualizarEmpleado(dni);
              }
              Navigator.pop(context);
            },
            child: Text(dni == null ? "Guardar" : "Actualizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Empleados")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('empleados').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar empleados"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay empleados registrados"));
          }

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nombre']),
                subtitle: Text(
                    "Área: ${data['area']} | Cargo: ${data['cargo']} | Estado: ${data['estado']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => mostrarFormulario(dni: doc.id, data: data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => borrarEmpleado(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

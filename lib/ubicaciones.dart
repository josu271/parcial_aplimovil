import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UbicacionesScreen extends StatefulWidget {
  const UbicacionesScreen({super.key});

  @override
  State<UbicacionesScreen> createState() => _UbicacionesScreenState();
}

class _UbicacionesScreenState extends State<UbicacionesScreen> {
  final TextEditingController _rucCtrl = TextEditingController();
  final TextEditingController _razonCtrl = TextEditingController();
  final TextEditingController _direccionCtrl = TextEditingController();
  final TextEditingController _contactoCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  String _categoria = "carnes";

  /// Crear proveedor
  Future<void> crearProveedor() async {
    try {
      await FirebaseFirestore.instance
          .collection('proveedores') // ✅ nombre correcto
          .doc(_rucCtrl.text) // usamos el RUC como ID
          .set({
        'razon_social': _razonCtrl.text,
        'direccion': _direccionCtrl.text,
        'contacto': _contactoCtrl.text,
        'email': _emailCtrl.text,
        'categoria': _categoria,
      });
      limpiarCampos();
    } catch (e) {
      print("Error al crear proveedor: $e");
    }
  }

  /// Actualizar proveedor
  Future<void> actualizarProveedor(String ruc) async {
    try {
      await FirebaseFirestore.instance
          .collection('proveedores') // ✅ nombre correcto
          .doc(ruc)
          .update({
        'razon_social': _razonCtrl.text,
        'direccion': _direccionCtrl.text,
        'contacto': _contactoCtrl.text,
        'email': _emailCtrl.text,
        'categoria': _categoria,
      });
      limpiarCampos();
    } catch (e) {
      print("Error al actualizar proveedor: $e");
    }
  }

  /// Eliminar proveedor
  Future<void> borrarProveedor(String ruc) async {
    try {
      await FirebaseFirestore.instance
          .collection('proveedores') // ✅ nombre correcto
          .doc(ruc)
          .delete();
    } catch (e) {
      print("Error al borrar proveedor: $e");
    }
  }

  void limpiarCampos() {
    _rucCtrl.clear();
    _razonCtrl.clear();
    _direccionCtrl.clear();
    _contactoCtrl.clear();
    _emailCtrl.clear();
    _categoria = "carnes";
  }

  /// Mostrar formulario
  void mostrarFormulario({String? ruc, Map<String, dynamic>? data}) {
    if (data != null) {
      _rucCtrl.text = ruc!;
      _razonCtrl.text = data['razon_social'];
      _direccionCtrl.text = data['direccion'];
      _contactoCtrl.text = data['contacto'];
      _emailCtrl.text = data['email'];
      _categoria = data['categoria'];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ruc == null ? "Agregar Proveedor" : "Editar Proveedor"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _rucCtrl,
                decoration: const InputDecoration(labelText: "RUC"),
                enabled: ruc == null,
              ),
              TextField(
                controller: _razonCtrl,
                decoration: const InputDecoration(labelText: "Razón Social"),
              ),
              TextField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(labelText: "Dirección"),
              ),
              TextField(
                controller: _contactoCtrl,
                decoration: const InputDecoration(labelText: "Contacto"),
              ),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              DropdownButtonFormField<String>(
                value: _categoria,
                items: const [
                  DropdownMenuItem(value: "carnes", child: Text("Carnes")),
                  DropdownMenuItem(value: "verduras", child: Text("Verduras")),
                  DropdownMenuItem(value: "bebidas", child: Text("Bebidas")),
                  DropdownMenuItem(value: "insumos", child: Text("Insumos")),
                ],
                onChanged: (val) => setState(() => _categoria = val!),
                decoration: const InputDecoration(labelText: "Categoría"),
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
              if (ruc == null) {
                crearProveedor();
              } else {
                actualizarProveedor(ruc);
              }
              Navigator.pop(context);
            },
            child: Text(ruc == null ? "Guardar" : "Actualizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gestión de Proveedores")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('proveedores').snapshots(), // ✅ nombre correcto
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar proveedores"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay proveedores registrados"));
          }

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['razon_social']),
                subtitle: Text(
                    "RUC: ${doc.id} | Categoría: ${data['categoria']} | Contacto: ${data['contacto']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          mostrarFormulario(ruc: doc.id, data: data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => borrarProveedor(doc.id),
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

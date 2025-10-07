import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProveedoresScreen());
}

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _razonSocial = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _contacto = TextEditingController();
  final TextEditingController _email = TextEditingController();

  String? _categoriaSeleccionada;
  final List<String> _categorias = ['Carnes', 'Verduras', 'Bebidas', 'Insumos'];

  String? _idSeleccionado;

  Future<void> createProveedor() async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'razon_social': _razonSocial.text,
      'ruc': _ruc.text,
      'direccion': _direccion.text,
      'contacto': _contacto.text,
      'email': _email.text,
      'categoria': _categoriaSeleccionada,
    };

    try {
      await FirebaseFirestore.instance.collection('Proveedores').add(datos);
      limpiarFormulario();
    } catch (e) {
      print('Error al crear proveedor: $e');
    }
  }

  Future<void> updateProveedor(String id) async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'razon_social': _razonSocial.text,
      'ruc': _ruc.text,
      'direccion': _direccion.text,
      'contacto': _contacto.text,
      'email': _email.text,
      'categoria': _categoriaSeleccionada,
    };

    try {
      await FirebaseFirestore.instance.collection('Proveedores').doc(id).update(datos);
      limpiarFormulario();
    } catch (e) {
      print('Error al actualizar proveedor: $e');
    }
  }

  Future<void> deleteProveedor(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Proveedores').doc(id).delete();
      limpiarFormulario();
    } catch (e) {
      print('Error al eliminar proveedor: $e');
    }
  }

  void limpiarFormulario() {
    setState(() {
      _razonSocial.clear();
      _ruc.clear();
      _direccion.clear();
      _contacto.clear();
      _email.clear();
      _categoriaSeleccionada = null;
      _idSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Proveedores'),
          backgroundColor: const Color.fromARGB(122, 152, 120, 102),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _razonSocial,
                  decoration: const InputDecoration(
                    labelText: 'Razón Social',
                    icon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese la razón social';
                    if (value.length < 3) return 'Debe tener al menos 3 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ruc,
                  decoration: const InputDecoration(labelText: 'RUC'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el RUC';
                    if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'El RUC debe tener 11 dígitos numéricos';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _direccion,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    icon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese la dirección';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _contacto,
                  decoration: const InputDecoration(labelText: 'Contacto (teléfono)'),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese un número de contacto';
                    if (!RegExp(r'^\d{9}$').hasMatch(value)) return 'Debe tener 9 dígitos numéricos';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese un correo electrónico';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Formato de correo no válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  items: _categorias.map((categoria) {
                    return DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSeleccionada = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    icon: Icon(Icons.category),
                  ),
                  validator: (value) => value == null ? 'Seleccione una categoría' : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_idSeleccionado == null) {
                      createProveedor();
                    } else {
                      updateProveedor(_idSeleccionado!);
                    }
                  },
                  icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
                  label: Text(_idSeleccionado == null
                      ? 'Agregar Proveedor'
                      : 'Actualizar Proveedor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _idSeleccionado == null ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'Lista de Proveedores',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Proveedores')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay proveedores registrados.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final proveedor = docs[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(proveedor['razon_social']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RUC: ${proveedor['ruc']}'),
                                Text('Dirección: ${proveedor['direccion']}'),
                                Text('Contacto: ${proveedor['contacto']}'),
                                Text('Email: ${proveedor['email']}'),
                                Text('Categoría: ${proveedor['categoria']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      _idSeleccionado = proveedor.id;
                                      _razonSocial.text = proveedor['razon_social'];
                                      _ruc.text = proveedor['ruc'];
                                      _direccion.text = proveedor['direccion'];
                                      _contacto.text = proveedor['contacto'];
                                      _email.text = proveedor['email'];
                                      _categoriaSeleccionada = proveedor['categoria'];
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteProveedor(proveedor.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

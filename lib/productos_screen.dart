import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: ProductosScreen()));
}

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _porcion = TextEditingController();

  String? _categoriaSeleccionada;
  bool _disponible = true;
  String? _idSeleccionado;

  final List<String> _categorias = [
    'Pollo a la brasa',
    'Parrillas',
    'Bebidas',
    'Guarniciones',
    'Postres'
  ];

  Future<void> createProductos() async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre': _nombre.text.trim(),
      'precio': double.tryParse(_precio.text.trim()) ?? 0.0,
      'porcion': _porcion.text.trim(),
      'categoria': _categoriaSeleccionada,
      'disponible': _disponible,
    };

    try {
      await FirebaseFirestore.instance.collection('Productos').add(datos);
      limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado correctamente')),
      );
    } catch (e) {
      print('Error al crear producto: $e');
    }
  }

  Future<void> updateProductos(String id) async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre': _nombre.text.trim(),
      'precio': double.tryParse(_precio.text.trim()) ?? 0.0,
      'porcion': _porcion.text.trim(),
      'categoria': _categoriaSeleccionada,
      'disponible': _disponible,
    };

    try {
      await FirebaseFirestore.instance.collection('Productos').doc(id).update(datos);
      limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado')),
      );
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProductos(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Productos').doc(id).delete();
      limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }

  void limpiarFormulario() {
    setState(() {
      _nombre.clear();
      _precio.clear();
      _porcion.clear();
      _categoriaSeleccionada = null;
      _disponible = true;
      _idSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
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
                controller: _nombre,
                decoration: const InputDecoration(
                  labelText: 'Nombre del plato',
                  icon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre del plato';
                  }
                  if (value.length < 3) {
                    return 'Debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                items: _categorias
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _categoriaSeleccionada = val;
                }),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  icon: Icon(Icons.category),
                ),
                validator: (value) =>
                    value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precio,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  icon: Icon(Icons.attach_money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un precio';
                  }
                  final num? precio = num.tryParse(value);
                  if (precio == null || precio <= 0) {
                    return 'Debe ser un número positivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _porcion,
                decoration: const InputDecoration(
                  labelText: 'Porción / Tamaño',
                  icon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la porción o tamaño';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('¿Disponible?'),
                value: _disponible,
                onChanged: (value) {
                  setState(() {
                    _disponible = value;
                  });
                },
                secondary: Icon(
                  _disponible ? Icons.check_circle : Icons.cancel,
                  color: _disponible ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (_idSeleccionado == null) {
                    createProductos();
                  } else {
                    updateProductos(_idSeleccionado!);
                  }
                },
                icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
                label: Text(
                  _idSeleccionado == null
                      ? 'Agregar Producto'
                      : 'Actualizar Producto',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _idSeleccionado == null ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text(
                'Lista de Productos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Productos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay productos registrados.'),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final producto = docs[index];
                      return Card(
                        elevation: 2,
                        margin:
                            const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_basket),
                          title: Text(producto['nombre']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio: S/.${producto['precio']}'),
                              Text('Porción: ${producto['porcion']}'),
                              Text('Categoría: ${producto['categoria']}'),
                              Text(
                                  'Estado: ${producto['disponible'] ? 'Disponible' : 'No disponible'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  setState(() {
                                    _idSeleccionado = producto.id;
                                    _nombre.text = producto['nombre'];
                                    _precio.text =
                                        producto['precio'].toString();
                                    _porcion.text = producto['porcion'];
                                    _categoriaSeleccionada =
                                        producto['categoria'];
                                    _disponible = producto['disponible'];
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    deleteProductos(producto.id),
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
    );
  }
}

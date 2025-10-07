import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: TechStore()));
}

class TechStore extends StatefulWidget {
  const TechStore({super.key});

  @override
  State<TechStore> createState() => _TechStore();
}

class _TechStore extends State<TechStore> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _marca = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _stock = TextEditingController();

  String? _tipoSeleccionado;
  bool _activo = true;
  String? _idSeleccionado;

  final List<String> _tipos = [
    'Accesorio',
    'Dispositivo',
    'Componente',
  ];

  Future<void> createProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre': _nombre.text.trim(),
      'marca': _marca.text.trim(),
      'precio': double.tryParse(_precio.text.trim()) ?? 0.0,
      'stock': int.tryParse(_stock.text.trim()) ?? 0,
      'tipo': _tipoSeleccionado,
      'activo': _activo,
    };

    try {
      await FirebaseFirestore.instance.collection('ProductosTecnologicos').add(datos);
      limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado correctamente')),
      );
    } catch (e) {
      print('Error al crear producto: $e');
    }
  }

  Future<void> updateProducto(String id) async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre': _nombre.text.trim(),
      'marca': _marca.text.trim(),
      'precio': double.tryParse(_precio.text.trim()) ?? 0.0,
      'stock': int.tryParse(_stock.text.trim()) ?? 0,
      'tipo': _tipoSeleccionado,
      'activo': _activo,
    };

    try {
      await FirebaseFirestore.instance.collection('ProductosTecnologicos').doc(id).update(datos);
      limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado correctamente')),
      );
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  Future<void> deleteProducto(String id) async {
    try {
      await FirebaseFirestore.instance.collection('ProductosTecnologicos').doc(id).delete();
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
      _marca.clear();
      _precio.clear();
      _stock.clear();
      _tipoSeleccionado = null;
      _activo = true;
      _idSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos Tecnológicos'),
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
                  labelText: 'Nombre del producto',
                  icon: Icon(Icons.devices),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese el nombre del producto';
                  if (value.length < 3) return 'Debe tener al menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _marca,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  icon: Icon(Icons.branding_watermark),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingrese la marca';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precio,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  icon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el precio';
                  final num? precio = num.tryParse(value);
                  if (precio == null || precio <= 0) return 'Debe ser un número positivo';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stock,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  icon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el stock';
                  final int? stock = int.tryParse(value);
                  if (stock == null || stock <= 0) return 'El stock debe ser mayor que 0';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                items: _tipos
                    .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                    .toList(),
                onChanged: (val) => setState(() {
                  _tipoSeleccionado = val;
                }),
                decoration: const InputDecoration(
                  labelText: 'Tipo de producto',
                  icon: Icon(Icons.category),
                ),
                validator: (value) => value == null ? 'Seleccione un tipo de producto' : null,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('¿Activo?'),
                value: _activo,
                onChanged: (value) {
                  setState(() {
                    _activo = value;
                  });
                },
                secondary: Icon(
                  _activo ? Icons.check_circle : Icons.cancel,
                  color: _activo ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (_idSeleccionado == null) {
                    createProducto();
                  } else {
                    updateProducto(_idSeleccionado!);
                  }
                },
                icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
                label: Text(_idSeleccionado == null
                    ? 'Agregar Producto'
                    : 'Actualizar Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _idSeleccionado == null ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 10),
              const Text(
                'Lista de Productos Tecnológicos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('ProductosTecnologicos')
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
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: ListTile(
                          leading: const Icon(Icons.computer),
                          title: Text(producto['nombre']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Marca: ${producto['marca']}'),
                              Text('Precio: S/.${producto['precio']}'),
                              Text('Stock: ${producto['stock']} unidades'),
                              Text('Tipo: ${producto['tipo']}'),
                              Text('Estado: ${producto['activo'] ? 'Activo' : 'Inactivo'}'),
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
                                    _marca.text = producto['marca'];
                                    _precio.text = producto['precio'].toString();
                                    _stock.text = producto['stock'].toString();
                                    _tipoSeleccionado = producto['tipo'];
                                    _activo = producto['activo'];
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteProducto(producto.id),
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

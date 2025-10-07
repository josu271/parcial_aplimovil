import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GreenMarket());
}

class GreenMarket extends StatelessWidget {
  const GreenMarket({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductosOrganicosScreen(),
    );
  }
}

class ProductosOrganicosScreen extends StatefulWidget {
  const ProductosOrganicosScreen({super.key});

  @override
  State<ProductosOrganicosScreen> createState() =>
      _ProductosOrganicosScreenState();
}

class _ProductosOrganicosScreenState extends State<ProductosOrganicosScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();

  String? _categoriaSeleccionada;
  bool _activo = true;
  String? _idSeleccionado;

  final List<String> _categorias = ['Fruta', 'Verdura', 'Bebida'];

  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _precioController.clear();
      _ciudadController.clear();
      _categoriaSeleccionada = null;
      _activo = true;
      _idSeleccionado = null;
    });
  }

  Future<void> _crearProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre': _nombreController.text.trim(),
      'categoria': _categoriaSeleccionada,
      'precio': double.parse(_precioController.text.trim()),
      'ciudadOrigen': _ciudadController.text.trim(),
      'activo': _activo,
    };

    try {
      await FirebaseFirestore.instance.collection('ProductosOrganicos').add(datos);
      _limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado correctamente')),
      );
    } catch (e) {
      print('Error al crear producto: $e');
    }
  }

  Future<void> _actualizarProducto(String id) async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre': _nombreController.text.trim(),
      'categoria': _categoriaSeleccionada,
      'precio': double.parse(_precioController.text.trim()),
      'ciudadOrigen': _ciudadController.text.trim(),
      'activo': _activo,
    };

    try {
      await FirebaseFirestore.instance
          .collection('ProductosOrganicos')
          .doc(id)
          .update(datos);
      _limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado correctamente')),
      );
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  Future<void> _eliminarProducto(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('ProductosOrganicos')
          .doc(id)
          .delete();
      _limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos Orgánicos'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(122, 152, 120, 102),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  icon: Icon(Icons.shopping_basket),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese el nombre del producto';
                  }
                  if (value.trim().length < 3) {
                    return 'Debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  icon: Icon(Icons.category),
                ),
                items: _categorias
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio (S/)',
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
                    return 'El precio debe ser mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ciudadController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad de origen',
                  icon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese la ciudad de origen';
                  }
                  return null;
                },
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
                icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
                label: Text(_idSeleccionado == null
                    ? 'Agregar Producto'
                    : 'Actualizar Producto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _idSeleccionado == null ? Colors.green : Colors.blue,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_idSeleccionado == null) {
                      _crearProducto();
                    } else {
                      _actualizarProducto(_idSeleccionado!);
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const Text(
                'Lista de Productos Orgánicos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ProductosOrganicos')
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
                      final data = producto.data() as Map<String, dynamic>;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.local_florist),
                          title: Text(data['nombre'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Categoría: ${data['categoria'] ?? ''}'),
                              Text('Precio: S/.${data['precio'] ?? ''}'),
                              Text('Origen: ${data['ciudadOrigen'] ?? ''}'),
                              Text('Estado: ${data['activo'] == true ? 'Activo' : 'Inactivo'}'),
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
                                    _nombreController.text = data['nombre'] ?? '';
                                    _categoriaSeleccionada = data['categoria'];
                                    _precioController.text =
                                        data['precio'].toString();
                                    _ciudadController.text =
                                        data['ciudadOrigen'] ?? '';
                                    _activo = data['activo'] ?? true;
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _eliminarProducto(producto.id),
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

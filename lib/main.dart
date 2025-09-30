import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Asegura que la inicialización de Firebase ocurra antes de correr la app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MyApp()); // Lanza la aplicación
}

// Widget principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta de debug
      home: ProductosScreen(), // Pantalla principal que muestra los productos
    );
  }
}

// Pantalla que lista los documentos de la colección 'productos'
class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();

  List<Map<String, dynamic>> productos = []; // Lista para guardar los productos

  @override
  void initState() {
    super.initState();
    obtenerProductos(); // Carga los productos al iniciar la pantalla
  }

  // Función para obtener los documentos de la colección 'productos'
  Future<void> obtenerProductos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('productos').get();

      setState(() {
        productos = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error al obtener productos: $e');
    }
  }

  // Crear producto (sin parámetros)
  Future<void> crearProductos() async {
    try {
      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': _nombre.text,
        'precio': _precio.text,
      });

      _nombre.clear();
      _precio.clear();

      obtenerProductos(); // recarga la lista
    } catch (e) {
      print('Error al crear producto: $e');
    }
  }

  // Actualizar producto
  Future<void> actualizarProductos(
      String id, String nombre, String precio) async {
    try {
      await FirebaseFirestore.instance.collection('productos').doc(id).update({
        'nombre': nombre,
        'precio': precio,
      });

      obtenerProductos();
    } catch (e) {
      print('Error al actualizar producto: $e');
    }
  }

  // Borrar producto
  Future<void> borrarProductos(String id) async {
    try {
      await FirebaseFirestore.instance.collection('productos').doc(id).delete();

      obtenerProductos();
    } catch (e) {
      print('Error al borrar producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Productos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _precio,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Precio"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: crearProductos,
              child: const Text("Agregar"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: productos.isEmpty
                  ? const Center(child: Text("No hay productos"))
                  : ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return ListTile(
                          title: Text(producto['nombre'] ?? 'Sin nombre'),
                          subtitle:
                              Text('Precio: S/ ${producto['precio'] ?? '0.00'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                borrarProductos(producto['id']), // borrar
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importar las demás pantallas
import 'clientes.dart';
import 'ubicaciones.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lista de pantallas (productos es la que ya tenías)
    final List<Widget> pages = [
      const ProductosScreen(),   // Productos con Firebase
      const ClientesScreen(),    // Clientes
      const UbicacionesScreen(), // Ubicaciones
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Productos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Clientes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Ubicaciones",
          ),
        ],
      ),
    );
  }
}

/// ============================
/// Pantalla de Productos
/// ============================
class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();

  List<Map<String, dynamic>> productos = [];

  @override
  void initState() {
    super.initState();
    obtenerProductos();
  }

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

  Future<void> crearProductos() async {
    try {
      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': _nombre.text,
        'precio': _precio.text,
      });

      _nombre.clear();
      _precio.clear();

      obtenerProductos();
    } catch (e) {
      print('Error al crear producto: $e');
    }
  }

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
                                borrarProductos(producto['id']),
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

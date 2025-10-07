import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
void main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp(const ProductosScreen());
}
class ProductosScreen extends StatefulWidget {
const ProductosScreen({super.key});
@override
State<ProductosScreen> createState() =>
_ProductosScreenState();
}
class _ProductosScreenState extends State<ProductosScreen>
{
final TextEditingController _nombre =
TextEditingController();
final TextEditingController _precio =
TextEditingController();
final TextEditingController _porcion =
TextEditingController();
String? _categoriaSeleccionada;
bool _disponible = true;
final List<String> _categorias = [
'Pollo a la brasa',
'Parrillas',
'Bebidas',
'Guarniciones',
'Postres',
];
String? _idSeleccionado;
List<Map<String, dynamic>> productos = [];
@override
void initState() {
super.initState();
readProductos();
}
Future<void> createProductos() async {
if (!_validarCampos()) return;
final datos = {
'nombre': _nombre.text,
'precio': double.tryParse(_precio.text) ?? 0.0,
'porcion': _porcion.text,
'categoria': _categoriaSeleccionada,
'disponible': _disponible,
};
try {
await
FirebaseFirestore.instance.collection('Productos').add(datos);
limpiarFormulario();
} catch (e) {
print('Error al crear plato: $e');
}
}
Future<void> readProductos() async {
try {
final snapshot = await
FirebaseFirestore.instance.collection('Productos').get();
setState(() {
productos = snapshot.docs
.map((doc) => {
'id': doc.id,
...doc.data(),
}).toList();
});
} catch (e) {
print('Error al leer productos: $e');
}
}
Future<void> updateProductos(String id) async {
if (!_validarCampos()) return;
final datos = {
'nombre': _nombre.text,
'precio': double.tryParse(_precio.text) ?? 0.0,
'porcion': _porcion.text,
'categoria': _categoriaSeleccionada,
'disponible': _disponible,
};
try{
await
FirebaseFirestore.instance.collection('Productos').doc(id).
update(datos);
limpiarFormulario();
}catch (e){
print('Error al actualizar productos: $e');
}
}
Future<void> deleteProductos(String id) async {
try{
await
FirebaseFirestore.instance.collection('Productos').doc(id).
delete();
await readProductos();
limpiarFormulario();
}catch (e){
print('Error al eliminar productos: $e');
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
bool _validarCampos() {
if (_nombre.text.isEmpty ||
_precio.text.isEmpty ||
_porcion.text.isEmpty ||
_categoriaSeleccionada == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Por favor completa todos los campos')),
);
return false;
}
return true;
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Gestión de Productos'),
backgroundColor: const Color.fromARGB(122, 152,
120, 102),
centerTitle: true,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
children: [
TextField(
controller: _nombre,
decoration: const InputDecoration(
labelText: "Nombre del producto",
icon: Icon(Icons.label),
),
),
const SizedBox(height: 10),
TextField(
controller: _precio,
keyboardType:
TextInputType.numberWithOptions(decimal: true),
decoration: const InputDecoration(
labelText: "Precio",
icon: Icon(Icons.attach_money),
),
),
const SizedBox(height: 10),
TextField(
controller: _porcion,
decoration: const InputDecoration(
labelText: "Porción / Tamaño",
icon: Icon(Icons.restaurant),
),
),
const SizedBox(height: 10),
DropdownButtonFormField<String>(
value: _categoriaSeleccionada,
items: _categorias.map((categoria) {
return DropdownMenuItem(value: categoria,
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
_disponible ? Icons.check_circle :
Icons.cancel,
color: _disponible ? Colors.green :
Colors.red,
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
icon: Icon(_idSeleccionado == null ?
Icons.add : Icons.save),
label: Text(_idSeleccionado == null ?
'Agregar Producto' : 'Actualizar Producto'),
style: ElevatedButton.styleFrom(
backgroundColor: _idSeleccionado == null ?
Colors.green : Colors.blue,
),),
const SizedBox(height: 20),
const Divider(thickness: 1),
const SizedBox(height: 10),
const Text(
'Lista de Productos',
style: TextStyle(fontSize: 18, fontWeight:
FontWeight.bold),
),
const SizedBox(height: 10),
StreamBuilder(
stream:
FirebaseFirestore.instance.collection('Productos').snapshots(),
builder: (context, snapshot) {
if (!snapshot.hasData) {
return const Center(child:
CircularProgressIndicator());
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
physics: const
NeverScrollableScrollPhysics(),
itemCount: docs.length,
itemBuilder: (context, index) {
final producto = docs[index];
return Card(
elevation: 2,
margin: const
EdgeInsets.symmetric(vertical: 6),
child: ListTile(
leading: const
Icon(Icons.shopping_basket),
title: Text(producto['nombre']),
subtitle: Column(crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text('Precio: S/.${producto['precio']}'),
Text('Porción:${producto['porcion']}'),
Text('Categoría:${producto['categoria']}'),
Text('Estado: ${producto['disponible'] ? 'Disponible' : 'No disponible'}'),
],
),

trailing: Row(

mainAxisSize: MainAxisSize.min,
children: [
IconButton(
icon: const Icon(Icons.edit,
color: Colors.blue),
onPressed: () {
setState(() {
_idSeleccionado =
producto.id;
_nombre.text =
producto['nombre'];
_precio.text =
producto['precio'].toString();
_porcion.text =
producto['porcion'];
_categoriaSeleccionada =
producto['categoria'];
_disponible =
producto['disponible'];
});
},
),

IconButton(
icon: const
Icon(Icons.delete, color: Colors.red),
onPressed: () =>
deleteProductos(producto.id),
),
],
),
),
);},
);
},
),
],
),
),
);
}
}
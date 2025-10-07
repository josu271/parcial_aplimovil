import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FinanPlusApp());
}

class FinanPlusApp extends StatefulWidget {
  const FinanPlusApp({super.key});

  @override
  State<FinanPlusApp> createState() => _FinanPlusAppState();
}

class _FinanPlusAppState extends State<FinanPlusApp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreCliente = TextEditingController();
  final TextEditingController _monto = TextEditingController();
  final TextEditingController _cuotas = TextEditingController();

  String? _estadoSeleccionado;
  final List<String> _estados = ['Activo', 'Cancelado'];

  String? _idSeleccionado;

  Future<void> createPrestamo() async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre_cliente': _nombreCliente.text,
      'monto': double.parse(_monto.text),
      'cuotas': int.parse(_cuotas.text),
      'estado': _estadoSeleccionado,
    };

    try {
      await FirebaseFirestore.instance.collection('Prestamos').add(datos);
      limpiarFormulario();
    } catch (e) {
      print('Error al crear préstamo: $e');
    }
  }

  Future<void> updatePrestamo(String id) async {
    if (!_formKey.currentState!.validate()) return;

    final datos = {
      'nombre_cliente': _nombreCliente.text,
      'monto': double.parse(_monto.text),
      'cuotas': int.parse(_cuotas.text),
      'estado': _estadoSeleccionado,
    };

    try {
      await FirebaseFirestore.instance.collection('Prestamos').doc(id).update(datos);
      limpiarFormulario();
    } catch (e) {
      print('Error al actualizar préstamo: $e');
    }
  }

  Future<void> deletePrestamo(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Prestamos').doc(id).delete();
      limpiarFormulario();
    } catch (e) {
      print('Error al eliminar préstamo: $e');
    }
  }

  void limpiarFormulario() {
    setState(() {
      _nombreCliente.clear();
      _monto.clear();
      _cuotas.clear();
      _estadoSeleccionado = null;
      _idSeleccionado = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FinanPlus - Gestión de Préstamos'),
          backgroundColor: const Color.fromARGB(255, 87, 137, 123),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreCliente,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del cliente',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre del cliente';
                    }
                    if (value.length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _monto,
                  decoration: const InputDecoration(
                    labelText: 'Monto del préstamo',
                    icon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el monto';
                    final num? monto = num.tryParse(value);
                    if (monto == null || monto <= 0) {
                      return 'El monto debe ser mayor que 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cuotas,
                  decoration: const InputDecoration(
                    labelText: 'Número de cuotas',
                    icon: Icon(Icons.format_list_numbered),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el número de cuotas';
                    final num? cuotas = num.tryParse(value);
                    if (cuotas == null || cuotas < 1) {
                      return 'Debe tener al menos 1 cuota';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  items: _estados.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estadoSeleccionado = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Estado del préstamo',
                    icon: Icon(Icons.assignment_turned_in),
                  ),
                  validator: (value) => value == null ? 'Seleccione un estado' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_idSeleccionado == null) {
                      createPrestamo();
                    } else {
                      updatePrestamo(_idSeleccionado!);
                    }
                  },
                  icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
                  label: Text(_idSeleccionado == null
                      ? 'Agregar Préstamo'
                      : 'Actualizar Préstamo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _idSeleccionado == null ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'Lista de Préstamos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Prestamos')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay préstamos registrados.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final prestamo = docs[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.account_balance_wallet),
                            title: Text(prestamo['nombre_cliente']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Monto: S/. ${prestamo['monto']}'),
                                Text('Cuotas: ${prestamo['cuotas']}'),
                                Text('Estado: ${prestamo['estado']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      _idSeleccionado = prestamo.id;
                                      _nombreCliente.text = prestamo['nombre_cliente'];
                                      _monto.text = prestamo['monto'].toString();
                                      _cuotas.text = prestamo['cuotas'].toString();
                                      _estadoSeleccionado = prestamo['estado'];
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deletePrestamo(prestamo.id),
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

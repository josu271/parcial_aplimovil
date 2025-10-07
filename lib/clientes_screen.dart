import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ClientesScreen());
}

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();

  String? _areaSeleccionada;
  DateTime? _fechaIngreso;
  bool _activo = true;
  String? _idSeleccionado;

  final List<String> _areas = ['Cocina', 'Atención', 'Delivery', 'Administración'];

  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _dniController.clear();
      _cargoController.clear();
      _areaSeleccionada = null;
      _fechaIngreso = null;
      _activo = true;
      _idSeleccionado = null;
    });
  }

  Future<void> _createEmpleado() async {
    final datos = {
      'nombreCompleto': _nombreController.text.trim(),
      'dni': _dniController.text.trim(),
      'area': _areaSeleccionada,
      'cargo': _cargoController.text.trim(),
      'fechaIngreso': Timestamp.fromDate(_fechaIngreso!),
      'activo': _activo,
    };

    try {
      await FirebaseFirestore.instance.collection('Empleados').add(datos);
      _limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado agregado correctamente')),
      );
    } catch (e) {
      print('Error al crear empleado: $e');
    }
  }

  Future<void> _updateEmpleado(String id) async {
    final datos = {
      'nombreCompleto': _nombreController.text.trim(),
      'dni': _dniController.text.trim(),
      'area': _areaSeleccionada,
      'cargo': _cargoController.text.trim(),
      'fechaIngreso': Timestamp.fromDate(_fechaIngreso!),
      'activo': _activo,
    };

    try {
      await FirebaseFirestore.instance.collection('Empleados').doc(id).update(datos);
      _limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado actualizado correctamente')),
      );
    } catch (e) {
      print('Error al actualizar empleado: $e');
    }
  }

  Future<void> _deleteEmpleado(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Empleados').doc(id).delete();
      if (_idSeleccionado == id) _limpiarFormulario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado eliminado')),
      );
    } catch (e) {
      print('Error al eliminar empleado: $e');
    }
  }

  Future<void> _seleccionarFechaIngreso(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaIngreso = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Empleados',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Empleados'),
          backgroundColor: const Color.fromARGB(122, 152, 120, 102),
          centerTitle: true,
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
                    labelText: 'Nombre completo',
                    icon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingrese el nombre completo';
                    }
                    if (value.trim().length < 3) {
                      return 'Debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _dniController,
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    icon: Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el DNI';
                    if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                      return 'El DNI debe tener 8 dígitos numéricos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _areaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Área',
                    icon: Icon(Icons.work),
                  ),
                  items: _areas
                      .map((area) => DropdownMenuItem(
                            value: area,
                            child: Text(area),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _areaSeleccionada = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Seleccione un área' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cargoController,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    icon: Icon(Icons.assignment_ind),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el cargo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(_fechaIngreso == null
                      ? 'Selecciona fecha de ingreso'
                      : 'Ingreso: ${_fechaIngreso!.day}/${_fechaIngreso!.month}/${_fechaIngreso!.year}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _seleccionarFechaIngreso(context),
                  ),
                ),
                if (_fechaIngreso == null)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, top: 4),
                      child: Text(
                        'Seleccione una fecha de ingreso',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
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
                      ? 'Agregar Empleado'
                      : 'Actualizar Empleado'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _idSeleccionado == null ? Colors.green : Colors.blue,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _fechaIngreso != null) {
                      if (_idSeleccionado == null) {
                        _createEmpleado();
                      } else {
                        _updateEmpleado(_idSeleccionado!);
                      }
                    } else if (_fechaIngreso == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Seleccione la fecha de ingreso')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'Lista de Empleados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Empleados')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay empleados registrados.'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final empleado = docs[index];
                        final data = empleado.data() as Map<String, dynamic>;
                        final fechaIngreso =
                            (data['fechaIngreso'] as Timestamp).toDate();

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(data['nombreCompleto'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DNI: ${data['dni'] ?? ''}'),
                                Text('Área: ${data['area'] ?? ''}'),
                                Text('Cargo: ${data['cargo'] ?? ''}'),
                                Text(
                                    'Ingreso: ${fechaIngreso.day}/${fechaIngreso.month}/${fechaIngreso.year}'),
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
                                      _idSeleccionado = empleado.id;
                                      _nombreController.text = data['nombreCompleto'] ?? '';
                                      _dniController.text = data['dni'] ?? '';
                                      _areaSeleccionada = data['area'];
                                      _cargoController.text = data['cargo'] ?? '';
                                      _fechaIngreso = fechaIngreso;
                                      _activo = data['activo'] ?? true;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEmpleado(empleado.id),
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

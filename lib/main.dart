import 'package:flutter/material.dart';
import 'clientes_screen.dart';
import 'productos_screen.dart';
import 'proveedores_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async{
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp();
runApp(const MainApp());
}
class MainApp extends StatelessWidget {
const MainApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Bottom Nav Demo',
theme: ThemeData(primarySwatch: Colors.indigo),
home: const BottomNav(),
);
}
}
class BottomNav extends StatefulWidget {
const BottomNav({super.key});
@override
State<BottomNav> createState() => _BottomNavState();
}
class _BottomNavState extends State<BottomNav> {
int _selectedIndex = 0;
final List<Widget> _screens = const [
TechStore(),
GreenMarket(),
FinanPlusApp(),
];
void _onItemTapped(int index) {
setState(() {
_selectedIndex = index;
});
}
@override
Widget build(BuildContext context) {
return Scaffold(
body: _screens[_selectedIndex],
bottomNavigationBar: BottomNavigationBar(
currentIndex: _selectedIndex,
onTap: _onItemTapped,
selectedItemColor: Colors.indigo,
unselectedItemColor: Colors.grey,
items: const [
BottomNavigationBarItem(
icon: Icon(Icons.shopping_cart),
label: "TechStore",
),
BottomNavigationBarItem(
icon: Icon(Icons.people),
label: "GreenMarket",
),
BottomNavigationBarItem(
icon: Icon(Icons.local_shipping),
label: "FinanPlus",
),
],
),
);
}
}
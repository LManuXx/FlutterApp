import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/add_fountain_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  void _toggleTheme(bool isDark) => setState(() => _darkMode = isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mad Lions',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFE8F5E9), // fondo verde clarito (green 50)
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Si no hay usuario autenticado, mostramos la pantalla de login
          if (!snapshot.hasData) {
            return AuthScreen();
          }
          // Si el usuario está autenticado, mostramos el MainScreen
          return MainScreen(onThemeChanged: _toggleTheme);
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  const MainScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  void _goToTab(int tab) {
    // Si no hay usuario autenticado, no permite navegar a otras pantallas
    final user = FirebaseAuth.instance.currentUser;
    if (user == null && tab != 0) {  // Solo permitir acceso al HomeScreen si no está logueado
      return;
    }
    setState(() => _index = tab);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: _goToTab),  // HomePage siempre accesible
      const MapScreen(),                 // Solo accesible si el usuario está logueado
      const AddFountainScreen(),         // Solo accesible si el usuario está logueado
      SettingsScreen(onThemeChanged: widget.onThemeChanged),  // Solo accesible si el usuario está logueado
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _goToTab,
        backgroundColor: const Color(0xFFE8F5E9), // mismo fondo verde clarito
        selectedItemColor: const Color.fromARGB(255, 52, 221, 0),
        unselectedItemColor: const Color.fromARGB(255, 46, 55, 46),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.add_location), label: 'Añadir'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

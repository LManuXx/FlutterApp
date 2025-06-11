import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFountainScreen extends StatefulWidget {
  final void Function(int) onNavigate;

  const AddFountainScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  _AddFountainScreenState createState() => _AddFountainScreenState();
}

class _AddFountainScreenState extends State<AddFountainScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  LatLng? _location;
  bool _isLoading = false;
  bool _isLocationFetched = false;

  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: const BorderSide(color: Colors.grey, width: 1.5),
  );

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _isLocationFetched = false;
    });

    try {
      LocationPermission permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied || permiso == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado para acceder a la ubicación.')),
        );
        return;
      }

      Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = LatLng(posicion.latitude, posicion.longitude);
        _isLocationFetched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLocationFetched = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener la ubicación.')),
      );
      print("Error al obtener la ubicación: $e");
    }
  }

  // Función para guardar la fuente
  Future<void> _saveLocation() async {
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, espera a que se cargue la ubicación.')),
      );
      return;
    }
    if (_nameController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos.')),
      );
      return;
    }

    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no autenticado. Por favor, inicia sesión.')),
        );
        return;
      }

      final db = FirebaseFirestore.instance;
      final datosFuente = {
        'description': _descController.text,
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
        'name': _nameController.text,
        'userId': usuario.uid,
      };

      await db.collection('locations').add(datosFuente);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fuente añadida correctamente!')),
      );

      widget.onNavigate(2);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la fuente.')),
      );
      print("Error al guardar la fuente: $e");

      widget.onNavigate(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text(
            'Añadir Fuente',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre',
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _inputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: 'Descripción',
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _inputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_isLocationFetched && _location != null)
            Text(
              'Ubicación: ${_location!.latitude}, ${_location!.longitude}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            )
          else
            const Text(
              'Ubicación no disponible.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              elevation: 6,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

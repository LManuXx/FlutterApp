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
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to access location.')),
        );
        return;
      }

      // Obtener la ubicación actual
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = LatLng(position.latitude, position.longitude);
        _isLocationFetched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLocationFetched = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while fetching location.')),
      );
      print("Error while fetching location: $e");
    }
  }

  // Función para guardar la fuente
  Future<void> _saveLocation() async {
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location to load.')),
      );
      return;
    }
    if (_nameController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated. Please log in.')),
        );
        return;
      }

      final db = FirebaseFirestore.instance;
      final locationData = {
        'description': _descController.text,
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
        'name': _nameController.text,
        'userId': user.uid,
      };

      // Guardar la ubicación en Firestore
      await db.collection('locations').add(locationData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location successfully added!')),
      );

      // Redirigir a la pantalla del mapa
      widget.onNavigate(2); // Llamar a la función de navegación y pasar el índice de la pantalla

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while saving location.')),
      );
      print("Error while saving location: $e");

      // En caso de error, redirigir a la pantalla del mapa
      widget.onNavigate(2); // También puedes redirigir en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fountain'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              'Add Fountain',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 24),
            // Input para el nombre
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Input para la descripción
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: _inputBorder,
                enabledBorder: _inputBorder,
                focusedBorder: _inputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            // Mostrar el estado de la ubicación
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_isLocationFetched && _location != null)
              Text(
                'Location: ${_location!.latitude}, ${_location!.longitude}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              )
            else
              const Text(
                'Location not available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            const SizedBox(height: 16),
            // Botón para guardar la fuente
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
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

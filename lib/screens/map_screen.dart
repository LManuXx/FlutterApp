import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // Función para cargar las ubicaciones desde Firestore
  Future<void> _loadLocations() async {
    try {
      QuerySnapshot snapshot = await _db.collection('locations').get();
      List<Marker> markers = [];
      snapshot.docs.forEach((doc) {
        double lat = doc['latitude'];
        double lon = doc['longitude'];
        String name = doc['name'] ?? 'Sin nombre';
        String description = doc['description'] ?? 'Sin descripción';

        // Crear el marcador
        Marker marker = Marker(
          point: LatLng(lat, lon),
          width: 80.0,
          height: 80.0,
          child: Container(
            child: Icon(
              Icons.location_pin,
              color: Colors.red,
            ),
          ),
        );

        markers.add(marker);
      });

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print("Error al cargar ubicaciones: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Mapa de Madrid',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(40.4168, -3.7038), // Centro inicial en Madrid
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Añadir los marcadores al mapa
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

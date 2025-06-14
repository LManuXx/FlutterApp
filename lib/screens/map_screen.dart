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
  List<Polyline> _polylines = [];
  bool _isLoading = true; // Indicador de carga
  MapController _mapController = MapController(); // Controlador del mapa

  @override
  void initState() {
    super.initState();
    _loadLocations(); // Cargar ubicaciones cuando se inicia la pantalla
  }

  // Función para cargar las ubicaciones desde Firestore de forma segura
  Future<void> _loadLocations() async {
    try {
      // Obtener los datos de la colección 'locations'
      QuerySnapshot snapshot = await _db.collection('locations').get();

      // Si no hay documentos, mostramos un mensaje en consola
      if (snapshot.docs.isEmpty) {
        print("No hay ubicaciones disponibles en Firestore.");
        setState(() {
          _isLoading = false; // Detener indicador de carga
        });
        return;
      }

      List<Marker> markers = [];
      List<LatLng> locationPoints = [];

      // Iteramos sobre los documentos de Firestore
      for (var doc in snapshot.docs) {
        // Usamos `doc.data()` para obtener un mapa seguro de los datos
        var data = doc.data() as Map<String, dynamic>;

        // Aseguramos que los campos necesarios existen y tienen valores válidos
        double? lat = data['latitude'];
        double? lon = data['longitude'];
        String name = data['name'] ?? 'Sin nombre';
        String description = data['description'] ?? 'Sin descripción';

        // Verificamos que latitud y longitud no sean nulos
        if (lat != null && lon != null) {
          // Crear el marcador
          Marker marker = Marker(
            point: LatLng(lat, lon),
            width: 80.0,
            height: 80.0,
            child: GestureDetector(
              onTap: () => _showLocationDetails(context, name, description, lat, lon),
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
              ),
            ),
          );
          markers.add(marker);
          locationPoints.add(LatLng(lat, lon)); // Añadir el punto de la fuente
        }
      }

      // Crear líneas entre fuentes cercanas (menos de 100 km)
      _createPolylines(locationPoints);

      setState(() {
        _markers = markers;
        _isLoading = false; // Detener indicador de carga
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Detener indicador de carga si hay error
      });
      print("Error al cargar ubicaciones: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar ubicaciones.')),
      );
    }
  }

  // Función para mostrar los detalles de la ubicación en un Dialog
  void _showLocationDetails(BuildContext context, String name, String description, double lat, double lon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descripción: $description'),
              Text('Latitud: $lat'),
              Text('Longitud: $lon'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Función para crear líneas entre las ubicaciones cercanas (menos de 100 km)
  void _createPolylines(List<LatLng> locations) {
    List<Polyline> polylines = [];

    for (int i = 0; i < locations.length; i++) {
      for (int j = i + 1; j < locations.length; j++) {
        double distance = _calculateDistance(locations[i], locations[j]);

        // Si la distancia es menor de 100 km, añadimos una línea
        if (distance < 100.0) {
          polylines.add(Polyline(
            points: [locations[i], locations[j]],
            strokeWidth: 4.0,
            color: Colors.blue,
          ));
        }
      }
    }

    setState(() {
      _polylines = polylines; // Actualizamos las líneas en el estado
    });
  }

  // Función para calcular la distancia entre dos puntos (en km)
  double _calculateDistance(LatLng start, LatLng end) {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end); // Distancia en kilómetros
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga mientras se cargan los datos
                : FlutterMap(
                    mapController: _mapController,
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
                      // Añadir las polilíneas entre las fuentes cercanas
                      PolylineLayer(
                        polylines: _polylines,
                      ),
                    ],
                  ),
          ),
          // Botones de zoom
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

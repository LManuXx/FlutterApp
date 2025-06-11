import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AddFountainScreen extends StatefulWidget {
  const AddFountainScreen({Key? key}) : super(key: key);

  @override
  State<AddFountainScreen> createState() => _AddFountainScreenState();
}

class _AddFountainScreenState extends State<AddFountainScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  LatLng? _loc;

  Future<void> _getLoc() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() => _loc = LatLng(pos.latitude, pos.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Añadir Fuente',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _getLoc,
            child: const Text('Usar mi ubicación'),
          ),
          if (_loc != null)
            Text('Ubicación: ${_loc!.latitude}, ${_loc!.longitude}'),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

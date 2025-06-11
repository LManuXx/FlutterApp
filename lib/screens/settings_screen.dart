import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  const SettingsScreen({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _gps = false;
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _gps = p.getBool('locationPermission') ?? false;
      _dark = p.getBool('darkMode') ?? false;
    });
  }

  Future<void> _setGps(bool val) async {
    if (val) {
      var perm = await Geolocator.requestPermission();
      if (perm != LocationPermission.always && perm != LocationPermission.whileInUse) return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setBool('locationPermission', val);
    setState(() => _gps = val);
  }

  Future<void> _setDark(bool val) async {
    widget.onThemeChanged(val);
    final p = await SharedPreferences.getInstance();
    await p.setBool('darkMode', val);
    setState(() => _dark = val);
  }

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Ajustes', style: Theme.of(ctx).textTheme.titleLarge),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Permiso de ubicación'),
            value: _gps,
            onChanged: _setGps,
          ),
          SwitchListTile(
            title: const Text('Modo oscuro'),
            value: _dark,
            onChanged: _setDark,
          ),
        ],
      ),
    );
  }
}

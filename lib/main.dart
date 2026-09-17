import 'dart:math'; // 👈 Necesario para la constante 'pi'
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapaVehiculoScreen extends StatefulWidget {
  const MapaVehiculoScreen({super.key});

  @override
  State<MapaVehiculoScreen> createState() => _MapaVehiculoScreenState();
}

class _MapaVehiculoScreenState extends State<MapaVehiculoScreen> {
  final MapController _mapController = MapController();
  
  LatLng _posicionVehiculo = const LatLng(-14.0678, -75.7286);
  double _rumbo = 0.0; // Ángulo de rotación en grados (0° a 360°)

  @override
  void initState() {
    super.initState();
    _escucharPosicionYRumbo();
  }

  void _escucharPosicionYRumbo() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2, // Actualizar cada 2 metros para mayor fluidez
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      setState(() {
        _posicionVehiculo = LatLng(position.latitude, position.longitude);

        // 💡 Actualizamos el rumbo si el GPS entrega un valor válido (> 0)
        if (position.heading >= 0) {
          _rumbo = position.heading;
        }
      });

      _mapController.move(_posicionVehiculo, _mapController.camera.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _posicionVehiculo,
          initialZoom: 17.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.vialuca.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _posicionVehiculo,
                width: 50,
                height: 50,
                child: Transform.rotate(
                  // 💡 Convertimos los grados de heading a radianes
                  angle: _rumbo * (pi / 180),
                  child: const Icon(
                    Icons.navigation, // Puedes usar una imagen PNG de tu taxi
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

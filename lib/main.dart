import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const ViaLucaApp());
}

class ViaLucaApp extends StatelessWidget {
  const ViaLucaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VIA LUCA',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const Mapa3DScreen(),
    );
  }
}

class Mapa3DScreen extends StatefulWidget {
  const Mapa3DScreen({super.key});

  @override
  State<Mapa3DScreen> createState() => _Mapa3DScreenState();
}

class _Mapa3DScreenState extends State<Mapa3DScreen> {
  MapLibreMapController? _controller;
  StreamSubscription<Position>? _positionStream;
  LatLng _posicionActual = const LatLng(-14.0678, -75.7286);
  bool _gpsActivo = false;

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _verificarYActivarGPS();
  }

  Future<void> _verificarYActivarGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, activa el GPS en tu teléfono.')),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Los permisos de GPS están denegados en los ajustes.')),
        );
      }
      return;
    }

    setState(() {
      _gpsActivo = true;
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 2,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position pos) {
      LatLng nuevaUbicacion = LatLng(pos.latitude, pos.longitude);
      _posicionActual = nuevaUbicacion;

      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: nuevaUbicacion,
            zoom: 17.5,
            tilt: 50.0,
            bearing: pos.heading >= 0 ? pos.heading : 0.0,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIA LUCA - GPS'),
        actions: [
          IconButton(
            icon: Icon(
              _gpsActivo ? Icons.location_on : Icons.location_off,
              color: _gpsActivo ? Colors.green : Colors.red,
            ),
            onPressed: _verificarYActivarGPS,
          ),
        ],
      ),
      body: MapLibreMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _posicionActual,
          zoom: 16.0,
          tilt: 50.0,
        ),
        styleString: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
        myLocationEnabled: true,
        myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
        myLocationRenderMode: MyLocationRenderMode.GPS,
      ),
    );
  }
}

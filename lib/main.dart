import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

final Map<String, Map<String, String>> _baseDeDatosUsuarios = {};

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
      theme: ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: Colors.amber,
        useMaterial3: true,
      ),
      home: const LoginRegistroScreen(),
    );
  }
}

class LoginRegistroScreen extends StatefulWidget {
  const LoginRegistroScreen({super.key});

  @override
  State<LoginRegistroScreen> createState() => _LoginRegistroScreenState();
}

class _LoginRegistroScreenState extends State<LoginRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _esRegistro = true;

  void _procesarFormulario() {
    if (!_formKey.currentState!.validate()) return;

    final dni = _dniController.text.trim();
    final nombre = _nombreController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (_esRegistro) {
      if (_baseDeDatosUsuarios.containsKey(dni)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: Este DNI ya se encuentra registrado.'),
          ),
        );
        return;
      }

      _baseDeDatosUsuarios[dni] = {
        'nombre': nombre,
        'telefono': telefono,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('¡Registro exitoso! Bienvenido a VIA LUCA.'),
        ),
      );
    } else {
      if (!_baseDeDatosUsuarios.containsKey(dni)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('DNI no encontrado. Regístrate primero.'),
          ),
        );
        return;
      }
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Mapa3DScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_taxi, size: 60, color: Colors.amber),
                    const SizedBox(height: 10),
                    Text(
                      'VIA LUCA',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _esRegistro ? 'Registro de Pasajero' : 'Iniciar Sesión',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _dniController,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        labelText: 'Documento Nacional de Identidad (DNI)',
                        prefixIcon: Icon(Icons.badge, color: Colors.amber),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length != 8 || int.tryParse(value.trim()) == null) {
                          return 'El DNI debe tener exactamente 8 números';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    if (_esRegistro) ...[
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre Completo',
                          prefixIcon: Icon(Icons.person, color: Colors.amber),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        decoration: const InputDecoration(
                          labelText: 'Número de Celular',
                          prefixIcon: Icon(Icons.phone, color: Colors.amber),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 9) {
                            return 'Ingresa un celular válido de 9 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _procesarFormulario,
                        child: Text(
                          _esRegistro ? 'REGISTRARME' : 'INGRESAR',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          _esRegistro = !_esRegistro;
                        });
                      },
                      child: Text(
                        _esRegistro
                            ? '¿Ya tienes cuenta? Inicia sesión'
                            : '¿No tienes cuenta? Regístrate con tu DNI',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
  LatLng _posicionOrigen = const LatLng(-14.0678, -75.7286);
  LatLng? _posicionDestino;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _resultadosBusqueda = [];
  bool _buscando = false;
  String _nombreDestino = '';

  int _vehiculoSeleccionado = 0; // 0: Económico, 1: Confort, 2: Mototaxi
  String _metodoPago = 'Efectivo';

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _verificarYActivarGPS();
  }

  Future<void> _verificarYActivarGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position pos) {
      LatLng nuevaUbicacion = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _posicionOrigen = nuevaUbicacion;
      });

      if (_posicionDestino == null) {
        _controller?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: nuevaUbicacion,
              zoom: 16.5,
              tilt: 45.0,
            ),
          ),
        );
      }
    });
  }

  double _calcularDistanciaEnKm(LatLng p1, LatLng p2) {
    const double p = 0.017453292519943295;
    final a = 0.5 -
        cos((p2.latitude - p1.latitude) * p) / 2 +
        cos(p1.latitude * p) *
            cos(p2.latitude * p) *
            (1 - cos((p2.longitude - p1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  double _calcularTarifa(double distanciaKm, int tipoVehiculo) {
    double tarifaBase;
    double precioKm;

    switch (tipoVehiculo) {
      case 1: // Confort
        tarifaBase = 6.0;
        precioKm = 2.2;
        break;
      case 2: // Mototaxi
        tarifaBase = 3.0;
        precioKm = 1.0;
        break;
      case 0: // Económico
      default:
        tarifaBase = 4.0;
        precioKm = 1.5;
        break;
    }

    double total = tarifaBase + (distanciaKm * precioKm);
    return total < tarifaBase ? tarifaBase : double.parse(total.toStringAsFixed(1));
  }

  Future<void> _buscarDireccion(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _resultadosBusqueda = []);
      return;
    }

    setState(() => _buscando = true);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5&countrycodes=pe',
    );

    try {
      final response = await http.get(url, headers: {'User-Agent': 'ViaLucaApp'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _resultadosBusqueda = data;
          _buscando = false;
        });
      }
    } catch (e) {
      setState(() => _buscando = false);
    }
  }

  void _seleccionarDestino(double lat, double lon, String nombre) {
    final nuevoDestino = LatLng(lat, lon);
    setState(() {
      _posicionDestino = nuevoDestino;
      _nombreDestino = nombre;
      _resultadosBusqueda = [];
      _searchController.text = nombre;
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(nuevoDestino, 16.0),
    );
  }

  void _onMapClick(Point<double> point, LatLng coordinates) {
    _seleccionarDestino(
      coordinates.latitude,
      coordinates.longitude,
      'Punto seleccionado en el mapa',
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double distanciaKm = _posicionDestino != null
        ? _calcularDistanciaEnKm(_posicionOrigen, _posicionDestino!)
        : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onMapClick: _onMapClick,
            initialCameraPosition: CameraPosition(
              target: _posicionOrigen,
              zoom: 15.0,
              tilt: 45.0,
            ),
            styleString: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _buscarDireccion,
                        decoration: InputDecoration(
                          hintText: '¿A dónde vas?',
                          icon: const Icon(Icons.search, color: Colors.amber),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _posicionDestino = null;
                                      _resultadosBusqueda = [];
                                      _nombreDestino = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),

                  if (_buscando)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),

                  if (_resultadosBusqueda.isNotEmpty)
                    Card(
                      elevation: 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _resultadosBusqueda.length,
                        itemBuilder: (context, index) {
                          final item = _resultadosBusqueda[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.redAccent),
                            title: Text(
                              item['display_name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () {
                              final double lat = double.parse(item['lat']);
                              final double lon = double.parse(item['lon']);
                              _seleccionarDestino(lat, lon, item['display_name']);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Panel Inferior de Selección de Tarifas
          if (_posicionDestino != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distancia estimada: ${distanciaKm.toStringAsFixed(2)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    // Selector de Vehículo
                    Row(
                      children: [
                        _opcionVehiculo(0, 'Económico', Icons.directions_car, _calcularTarifa(distanciaKm, 0)),
                        const SizedBox(width: 8),
                        _opcionVehiculo(1, 'Confort', Icons.local_taxi, _calcularTarifa(distanciaKm, 1)),
                        const SizedBox(width: 8),
                        _opcionVehiculo(2, 'Moto', Icons.two_wheeler, _calcularTarifa(distanciaKm, 2)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Selector Método de Pago
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Método de pago:', style: TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _metodoPago,
                          items: <String>['Efectivo', 'Yape / Plin', 'Tarjeta']
                              .map((String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _metodoPago = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Botón Pedir Taxi
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Buscando conductor cercano ($_metodoPago)...'),
                            ),
                          );
                        },
                        child: Text(
                          'PEDIR VIA LUCA - S/ ${_calcularTarifa(distanciaKm, _vehiculoSeleccionado)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _opcionVehiculo(int index, String titulo, IconData icono, double precio) {
    bool seleccionado = _vehiculoSeleccionado == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _vehiculoSeleccionado = index),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: seleccionado ? Colors.amber[100] : Colors.grey[100],
            border: Border.all(color: seleccionado ? Colors.amber : Colors.grey[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icono, color: seleccionado ? Colors.amber[900] : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('S/ $precio', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}

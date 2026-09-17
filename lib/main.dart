import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// Base de datos local en memoria para verificar DNIs únicos
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
      // Validar si el DNI ya existe
      if (_baseDeDatosUsuarios.containsKey(dni)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: Este DNI ya se encuentra registrado.'),
          ),
        );
        return;
      }

      // Guardar nuevo usuario
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
      // Iniciar Sesión
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

    // Ir al Mapa
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

                    // Campo DNI
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
                      // Campo Nombre
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

                      // Campo Teléfono
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

          if (_posicionDestino != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pin_drop, color: Colors.red, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Destino Seleccionado',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                Text(
                                  _nombreDestino,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Siguiente paso: Seleccionar tipo de taxi y tarifa')),
                            );
                          },
                          child: const Text(
                            'Confirmar Destino',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

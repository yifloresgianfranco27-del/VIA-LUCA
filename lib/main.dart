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
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB703),
          primary: const Color(0xFFFFB703),
          surface: Colors.white,
        ),
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
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Text('Este DNI ya se encuentra registrado.'),
          ),
        );
        return;
      }

      _baseDeDatosUsuarios[dni] = {
        'nombre': nombre,
        'telefono': telefono,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('¡Registro exitoso! Bienvenido a VIA LUCA.'),
        ),
      );
    } else {
      if (!_baseDeDatosUsuarios.containsKey(dni)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Text('DNI no encontrado. Regístrate primero.'),
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
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB703),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB703).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_taxi_rounded, size: 50, color: Colors.black),
                ),
                const SizedBox(height: 16),
                const Text(
                  'VIA LUCA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _esRegistro ? 'Crea tu cuenta con tu DNI' : 'Bienvenido de vuelta',
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
                const SizedBox(height: 32),

                // Formulario
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _campoTexto(
                          controller: _dniController,
                          label: 'DNI',
                          hint: 'Ingresa tu DNI de 8 dígitos',
                          icon: Icons.badge_outlined,
                          isNumber: true,
                          maxLength: 8,
                          validator: (val) {
                            if (val == null || val.trim().length != 8 || int.tryParse(val.trim()) == null) {
                              return 'DNI inválido (8 números)';
                            }
                            return null;
                          },
                        ),
                        if (_esRegistro) ...[
                          const SizedBox(height: 16),
                          _campoTexto(
                            controller: _nombreController,
                            label: 'Nombre completo',
                            hint: 'Tu nombre y apellidos',
                            icon: Icons.person_outline,
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 16),
                          _campoTexto(
                            controller: _telefonoController,
                            label: 'Celular',
                            hint: 'Número de 9 dígitos',
                            icon: Icons.phone_android_outlined,
                            isNumber: true,
                            maxLength: 9,
                            validator: (val) => (val == null || val.trim().length != 9) ? 'Celular inválido' : null,
                          ),
                        ],
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB703),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _procesarFormulario,
                            child: Text(
                              _esRegistro ? 'REGISTRARSE' : 'INICIAR SESIÓN',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => setState(() => _esRegistro = !_esRegistro),
                  child: Text(
                    _esRegistro ? '¿Ya tienes una cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFFFFB703), size: 20),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFFB703), width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
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

  int _vehiculoSeleccionado = 0;
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
            CameraPosition(target: nuevaUbicacion, zoom: 16.5, tilt: 45.0),
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
    double tarifaBase = tipoVehiculo == 1 ? 6.0 : (tipoVehiculo == 2 ? 3.0 : 4.0);
    double precioKm = tipoVehiculo == 1 ? 2.2 : (tipoVehiculo == 2 ? 1.0 : 1.5);
    double total = tarifaBase + (distanciaKm * precioKm);
    return total < tarifaBase ? tarifaBase : double.parse(total.toStringAsFixed(1));
  }

  Future<void> _buscarDireccion(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _resultadosBusqueda = []);
      return;
    }

    setState(() => _buscando = true);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5&countrycodes=pe');

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

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(nuevoDestino, 16.0));
  }

  void _onMapClick(Point<double> point, LatLng coordinates) {
    _seleccionarDestino(coordinates.latitude, coordinates.longitude, 'Punto seleccionado en mapa');
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double distanciaKm = _posicionDestino != null ? _calcularDistanciaEnKm(_posicionOrigen, _posicionDestino!) : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onMapClick: _onMapClick,
            initialCameraPosition: CameraPosition(target: _posicionOrigen, zoom: 15.0, tilt: 45.0),
            styleString: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
          ),

          // Buscador Flotante Moderno
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _buscarDireccion,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: '¿A dónde quieres ir?',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFFB703), size: 24),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  if (_buscando)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(color: Color(0xFFFFB703)),
                    ),

                  if (_resultadosBusqueda.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _resultadosBusqueda.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (context, index) {
                          final item = _resultadosBusqueda[index];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: Color(0xFFFFB703), size: 20),
                            ),
                            title: Text(
                              item['display_name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

          // Bottom Sheet de Selección de Vehículo
          if (_posicionDestino != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Elige tu viaje',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${distanciaKm.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Opciones de Vehículos
                    _cardVehiculo(0, 'Económico', 'Rápido y accesible', Icons.directions_car_rounded, _calcularTarifa(distanciaKm, 0)),
                    const SizedBox(height: 10),
                    _cardVehiculo(1, 'Confort', 'Autos más amplios', Icons.local_taxi_rounded, _calcularTarifa(distanciaKm, 1)),
                    const SizedBox(height: 10),
                    _cardVehiculo(2, 'Moto', 'Para viajes cortos', Icons.two_wheeler_rounded, _calcularTarifa(distanciaKm, 2)),

                    const SizedBox(height: 16),

                    // Método de Pago
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        const Text('Pago:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const Spacer(),
                        DropdownButton<String>(
                          value: _metodoPago,
                          underline: const SizedBox(),
                          items: ['Efectivo', 'Yape / Plin', 'Tarjeta']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _metodoPago = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Botón Pedir
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB703),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: Text('Buscando conductor cercano ($_metodoPago)...'),
                            ),
                          );
                        },
                        child: Text(
                          'CONFIRMAR VIA LUCA - S/ ${_calcularTarifa(distanciaKm, _vehiculoSeleccionado)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
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

  Widget _cardVehiculo(int index, String titulo, String subtitulo, IconData icono, double precio) {
    bool seleccionado = _vehiculoSeleccionado == index;

    return GestureDetector(
      onTap: () => setState(() => _vehiculoSeleccionado = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFFFFF9E6) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado ? const Color(0xFFFFB703) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: seleccionado ? const Color(0xFFFFB703) : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: Colors.black87, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitulo, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Text(
              'S/ $precio',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

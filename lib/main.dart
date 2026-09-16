import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ViaLucaApp());
}

class ViaLucaApp extends StatelessWidget {
  const ViaLucaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIA LUCA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(-14.0678, -75.7286); // Ica/Parcona
  LatLng? _destinationPosition;
  String _destinationName = 'Ingresar destino';

  void _recenterMap() {
    _mapController.move(_currentPosition, 15.0);
  }

  void _openSearchScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationSearchScreen(
          userPosition: _currentPosition,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _destinationPosition = result['location'] as LatLng;
        _destinationName = result['name'] as String;
      });

      // Mover el mapa al destino seleccionado
      _mapController.move(_destinationPosition!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 2,
        title: const Text(
          'VIA LUCA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
              ),
              accountName: const Text(
                'Gianfranco',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text('Pasajero VIP'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF1E88E5)),
              title: const Text('Mis Viajes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Color(0xFF1E88E5)),
              title: const Text('Métodos de Pago'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Configuración'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Mapa Interactivo
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.via_luca',
              ),
              MarkerLayer(
                markers: [
                  // Marcador de Origen
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.my_location,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  // Marcador de Destino
                  if (_destinationPosition != null)
                    Marker(
                      point: _destinationPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 45,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Botón GPS
          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton.small(
              heroTag: 'recenter_btn',
              onPressed: _recenterMap,
              backgroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.gps_fixed, color: Color(0xFF1E88E5)),
            ),
          ),

          // Tarjeta inferior
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _openSearchScreen,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF1E88E5)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _destinationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _destinationPosition == null
                                      ? Colors.black54
                                      : Colors.black87,
                                  fontWeight: _destinationPosition == null
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openSearchScreen,
                            icon: const Icon(Icons.home,
                                size: 18, color: Color(0xFF1E88E5)),
                            label: const Text('Casa',
                                style: TextStyle(color: Colors.black87)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openSearchScreen,
                            icon: const Icon(Icons.work,
                                size: 18, color: Color(0xFF1E88E5)),
                            label: const Text('Trabajo',
                                style: TextStyle(color: Colors.black87)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
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

// Pantalla de Búsqueda de Destinos con Nominatim / OpenStreetMap
class DestinationSearchScreen extends StatefulWidget {
  final LatLng userPosition;
  const DestinationSearchScreen({super.key, required this.userPosition});

  @override
  State<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState extends State<DestinationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=6&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'VIA_LUCA_App',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir Destino'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                // Origen (Ubicación actual)
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ubicación actual (Parcona, Ica)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Campo de Búsqueda de Destino
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => _searchPlaces(value),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.location_on, color: Colors.redAccent),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchPlaces('');
                            },
                          )
                        : null,
                    hintText: '¿A dónde vas? (Ej: Plaza de Armas, Ica)',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: _searchResults.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                final displayName = item['display_name'] ?? '';
                final lat = double.parse(item['lat']);
                final lon = double.parse(item['lon']);

                return ListTile(
                  leading: const Icon(Icons.place_outlined,
                      color: Color(0xFF1E88E5)),
                  title: Text(
                    displayName.split(',').first,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context, {
                      'location': LatLng(lat, lon),
                      'name': displayName.split(',').first,
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

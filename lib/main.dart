import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

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
          seedColor: const Color(0xFF0F62FE),
          primary: const Color(0xFF0F62FE),
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  // Coordenadas iniciales (Centro de Ica)
  LatLng _currentPosition = const LatLng(-14.0678, -75.7286);
  LatLng? _destinationPosition;
  String _destinationName = '¿A dónde vamos en Ica?';
  bool _isLoadingGps = true;

  // Límites geográficos estrictos para la Región de Ica
  final LatLngBounds _icaBounds = LatLngBounds(
    const LatLng(-15.6000, -76.5000), // Suroeste de Ica
    const LatLng(-13.0000, -74.7000), // Noreste de Ica
  );

  @override
  void initState() {
    super.initState();
    _initGpsTracking();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  Future<void> _initGpsTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingGps = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingGps = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingGps = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng userLatLng = LatLng(position.latitude, position.longitude);

    // Verificar si el usuario está dentro de Ica
    if (_icaBounds.contains(userLatLng)) {
      setState(() {
        _currentPosition = userLatLng;
        _isLoadingGps = false;
      });
      _animatedMapMove(_currentPosition, 16.5);
    } else {
      setState(() => _isLoadingGps = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('VIA LUCA solo opera dentro de la Región de Ica.'),
          ),
        );
      }
    }
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

      _animatedMapMove(_destinationPosition!, 15.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F62FE), Color(0xFF0043CE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: const Text(
                'Gianfranco',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text('Pasajero VIP - Ica'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F62FE),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF0F62FE)),
              title: const Text('Mis Viajes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Color(0xFF0F62FE)),
              title: const Text('Métodos de Pago'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.star_outline, color: Color(0xFF0F62FE)),
              title: const Text('Lugares Favoritos'),
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
          // Mapa OpenStreetMap Limpio (Sin marcas de agua) + Bloqueo regional en Ica
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 16.5,
              maxZoom: 18.0,
              minZoom: 10.0,
              cameraConstraint: CameraConstraint.contain(bounds: _icaBounds),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.via_luca',
              ),

              if (_destinationPosition != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_currentPosition, _destinationPosition!],
                      strokeWidth: 5.0,
                      color: const Color(0xFF0F62FE),
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F62FE).withOpacity(0.2),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F62FE),
                            border: Border.all(color: Colors.white, width: 3.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_destinationPosition != null)
                    Marker(
                      point: _destinationPosition!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.navigation_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          if (_isLoadingGps)
            Positioned(
              top: 100,
              left: MediaQuery.of(context).size.width / 2 - 75,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Ubicando GPS...',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Builder(
                builder: (context) => Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black87),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      const Expanded(
                        child: Center(
                          child: ViaLucaLogo(size: 28, showText: true),
                        ),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFF4F4F4),
                        child: Icon(Icons.person, color: Colors.black54, size: 20),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 210,
            child: FloatingActionButton(
              heroTag: 'gps_btn',
              onPressed: () => _animatedMapMove(_currentPosition, 16.5),
              backgroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.my_location, color: Color(0xFF0F62FE)),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _openSearchScreen,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF0F62FE), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _destinationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
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
                        child: _buildQuickButton(
                          icon: Icons.home_rounded,
                          label: 'Casa',
                          onTap: _openSearchScreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickButton(
                          icon: Icons.work_rounded,
                          label: 'Trabajo',
                          onTap: _openSearchScreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0F62FE)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de Búsqueda enfocada exclusivamente en Ica
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
      // Se limita la búsqueda con viewbox a la Región de Ica (&bounded=1)
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query, Ica, Peru&viewbox=-76.5,-13.0,-74.7,-15.6&bounded=1&limit=8&addressdetails=1',
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('¿A dónde vas en Ica?'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Color(0xFF0F62FE)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Mi ubicación actual (Ica)',
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
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (value) => _searchPlaces(value),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.location_on, color: Colors.black87),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchPlaces('');
                            },
                          )
                        : null,
                    hintText: 'Buscar lugar o calle en Ica...',
                    filled: true,
                    fillColor: const Color(0xFFF4F4F4),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                      color: Color(0xFF0F62FE)),
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

// Isotipo y Logo Vectorial
class ViaLucaLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color textColor;

  const ViaLucaLogo({
    super.key,
    this.size = 28.0,
    this.showText = true,
    this.textColor = const Color(0xFF001141),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ViaLucaIconPainter(),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: size * 0.65,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: textColor,
              ),
              children: const [
                TextSpan(text: 'VIA '),
                TextSpan(
                  text: 'LUCA',
                  style: TextStyle(
                    color: Color(0xFF0F62FE),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ViaLucaIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint mainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF00D2FF),
          Color(0xFF0F62FE),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final Path logoPath = Path();
    logoPath.moveTo(w * 0.5, h * 0.05);
    logoPath.cubicTo(w * 0.85, h * 0.05, w * 0.95, h * 0.45, w * 0.5, h * 0.95);
    logoPath.cubicTo(w * 0.05, h * 0.45, w * 0.15, h * 0.05, w * 0.5, h * 0.05);
    logoPath.close();

    canvas.drawPath(logoPath, mainPaint);

    final Paint innerCutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path innerCutPath = Path();
    innerCutPath.moveTo(w * 0.5, h * 0.28);
    innerCutPath.lineTo(w * 0.65, h * 0.48);
    innerCutPath.lineTo(w * 0.5, h * 0.68);
    innerCutPath.lineTo(w * 0.35, h * 0.48);
    innerCutPath.close();

    canvas.drawPath(innerCutPath, innerCutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class ConsignmentCreateScreen extends StatefulWidget {
  const ConsignmentCreateScreen({super.key});
  @override
  State<ConsignmentCreateScreen> createState() =>
      _ConsignmentCreateScreenState();
}

class _ConsignmentCreateScreenState extends State<ConsignmentCreateScreen> {
  // OSRM & Geofencing state variables
  List<List<LatLng>> _routes = [];
  List<double> _routeDistances = [];
  List<double> _routeDurations = [];
  int _selectedRouteIndex = 0;
  bool _isLoadingRoute = false;
  bool _geofenceEnabled = true;
  double _geofenceBufferKm = 1.0;
  int _step = 0;
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _cargoType = 'General Cargo';
  String _priority = 'Medium';
  LatLng? _source;
  LatLng? _dest;
  bool _selectingSource = true;
  int _truckCount = 1;
  final _truckCountCtrl = TextEditingController(text: '1');
  String _truckType = 'Container';
  // ignore: unused_field
  String? _assignedDriver; // kept for compat
  final Set<String> _assignedDrivers = {};
  int _assignMode = 0; // 0=system drivers, 1=excel upload

  final List<String> _cargoTypes = [
    'General Cargo',
    'Steel/Metal',
    'Chemical',
    'Cement',
    'FMCG',
    'Heavy Equipment',
    'Refrigerated'
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];
  final List<String> _truckTypes = [
    'Container',
    'Flatbed',
    'Tanker',
    'Tipper',
    'Refrigerated'
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _clientCtrl.dispose();
    _contactCtrl.dispose();
    _weightCtrl.dispose();
    _truckCountCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Consignment created successfully!',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'New Consignment',
        showBack: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Step ${_step + 1} of 3',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_step != 1) _buildStepper(),
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < _step;
          final active = i == _step;
          final color =
              done || active ? AppColors.brandBlue : AppColors.darkBorder;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.brandBlue
                        : active
                            ? AppColors.brandBlue.withValues(alpha: 0.15)
                            : AppColors.darkSurface,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : Text('${i + 1}',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? AppColors.brandBlue
                                    : AppColors.neutral500)),
                  ),
                ),
                if (i < 2)
                  Expanded(
                      child: Container(
                          height: 2,
                          color: done
                              ? AppColors.brandBlue
                              : AppColors.darkBorder)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Basic Details'),
          _field('Consignment Name', _nameCtrl, 'e.g. Vizag Port Export Batch'),
          _field('Client Name', _clientCtrl, 'e.g. Reliance Industries'),
          _field('Client Contact', _contactCtrl, '+91 XXXXX XXXXX',
              type: TextInputType.phone),
          _dropdownField('Cargo Type', _cargoTypes, _cargoType,
              (v) => setState(() => _cargoType = v!)),
          _field('Cargo Weight (Tons)', _weightCtrl, 'e.g. 450',
              type: TextInputType.number),
          _dropdownField('Priority Level', _priorities, _priority,
              (v) => setState(() => _priority = v!)),
        ],
      ),
    );
  }

  List<LatLng> _generateMockRoute(LatLng start, LatLng end, {required double offsetFactor}) {
    final List<LatLng> pts = [];
    final int numPoints = 30;
    for (int i = 0; i <= numPoints; i++) {
      final double t = i / numPoints;
      final double lat = start.latitude + (end.latitude - start.latitude) * t;
      final double lng = start.longitude + (end.longitude - start.longitude) * t;
      
      if (offsetFactor != 0.0 && i > 0 && i < numPoints) {
        final double dx = end.longitude - start.longitude;
        final double dy = end.latitude - start.latitude;
        final double px = -dy;
        final double py = dx;
        final double sineFactor = math.sin(t * math.pi);
        final double finalLat = lat + py * offsetFactor * sineFactor;
        final double finalLng = lng + px * offsetFactor * sineFactor;
        pts.add(LatLng(finalLat, finalLng));
      } else {
        pts.add(LatLng(lat, lng));
      }
    }
    return pts;
  }

  Future<void> _fetchOSRMRoute() async {
    if (_source == null || _dest == null) return;
    setState(() {
      _isLoadingRoute = true;
    });

    final String coords = '${_source!.longitude},${_source!.latitude};${_dest!.longitude},${_dest!.latitude}';
    final List<String> urls = [
      'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson&alternatives=true',
      'https://osrm.routing.dog/route/v1/driving/$coords?overview=full&geometries=geojson&alternatives=true'
    ];

    bool success = false;
    List<List<LatLng>> tempRoutes = [];
    List<double> tempDistances = [];
    List<double> tempDurations = [];

    for (final urlStr in urls) {
      try {
        final response = await http.get(Uri.parse(urlStr)).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'] is List) {
            final List jsonRoutes = data['routes'];
            final int maxRoutes = math.min(jsonRoutes.length, 3);
            for (int i = 0; i < maxRoutes; i++) {
              final r = jsonRoutes[i];
              final geometry = r['geometry'];
              final List coordsList = geometry['coordinates'];
              final List<LatLng> points = coordsList.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
              tempRoutes.add(points);
              tempDistances.add((r['distance'] as num).toDouble() / 1000.0);
              tempDurations.add((r['duration'] as num).toDouble() / 60.0);
            }
            success = true;
            break;
          }
        }
      } catch (e) {
        // Fallback to next mirror/mock
      }
    }

    if (!success) {
      final start = _source!;
      final end = _dest!;
      final double directDist = Distance().as(LengthUnit.Kilometer, start, end).toDouble();
      
      tempRoutes = [
        _generateMockRoute(start, end, offsetFactor: 0.0),
        _generateMockRoute(start, end, offsetFactor: 0.12),
        _generateMockRoute(start, end, offsetFactor: -0.16)
      ];
      tempDistances = [directDist * 1.04, directDist * 1.25, directDist * 1.18];
      tempDurations = [directDist * 1.4, directDist * 1.7, directDist * 1.55];
    }

    setState(() {
      _routes = tempRoutes;
      _routeDistances = tempDistances;
      _routeDurations = tempDurations;
      _selectedRouteIndex = 0;
      _isLoadingRoute = false;
    });
  }


  Widget _buildStep2() {
    final hasRoute = _source != null && _dest != null;
    return Stack(
      children: [
        // ── Full-screen map ──────────────────────────────────
        Positioned.fill(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(17.3617, 82.8),
              initialZoom: 8.0,
              onTap: (_, latlng) {
                setState(() {
                  if (_selectingSource) {
                    _source = latlng;
                    _selectingSource = false;
                  } else {
                    _dest = latlng;
                  }
                });
                if (_source != null && _dest != null) {
                  _fetchOSRMRoute();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eazecargo.eaze_my_cargo',
              ),
              
              if (hasRoute && _routes.isNotEmpty) ...[
                // ── GEOFENCE BUFFER VISUALIZATION CORRIDOR ──
                if (_geofenceEnabled && _selectedRouteIndex < _routes.length)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: _routes[_selectedRouteIndex],
                      strokeWidth: 20.0 + (_geofenceBufferKm * 18.0),
                      color: const Color(0x1810B981), // semi-transparent Emerald green
                      borderStrokeWidth: 1.5,
                      borderColor: const Color(0x3510B981),
                    ),
                  ]),

                // ── SELECTED & ALTERNATIVE OSRM ROUTES ──
                PolylineLayer(polylines: [
                  // Alternative routes (drawn below in slate grey)
                  for (int i = 0; i < _routes.length; i++)
                    if (i != _selectedRouteIndex)
                      Polyline(
                        points: _routes[i],
                        strokeWidth: 4.5,
                        color: const Color(0x8094A3B8),
                      ),
                  // Primary Selected route (drawn on top in bright Electric Blue)
                  if (_selectedRouteIndex < _routes.length)
                    Polyline(
                      points: _routes[_selectedRouteIndex],
                      strokeWidth: 6.0,
                      color: const Color(0xFF2563EB),
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                ]),
              ] else if (hasRoute) ...[
                // Fallback direct line while route is loading
                PolylineLayer(polylines: [
                  Polyline(
                    points: [_source!, _dest!],
                    strokeWidth: 5,
                    color: const Color(0xFF2563EB),
                    borderStrokeWidth: 2,
                    borderColor: Colors.white.withValues(alpha: 0.6),
                  ),
                ]),
              ],

              MarkerLayer(markers: [
                if (_source != null)
                  Marker(
                    point: _source!,
                    width: 46,
                    height: 56,
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF2563EB)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Icon(Icons.my_location_rounded,
                              color: Colors.white, size: 18),
                        ),
                        Container(
                            width: 3,
                            height: 10,
                            color: const Color(0xFF2563EB)),
                      ],
                    ),
                  ),
                if (_dest != null)
                  Marker(
                    point: _dest!,
                    width: 46,
                    height: 56,
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Icon(Icons.flag_rounded,
                              color: Colors.white, size: 18),
                        ),
                        Container(
                            width: 3,
                            height: 10,
                            color: const Color(0xFFEF4444)),
                      ],
                    ),
                  ),
              ]),
            ],
          ),
        ),

        // ── Floating top location cards ──────────────────────
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _selectingSource = true;
                  }),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _source != null
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.my_location_rounded,
                            size: 18,
                            color: _source != null
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PICKUP',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 1.0)),
                            Text(
                              _source != null
                                  ? '${_source!.latitude.toStringAsFixed(4)}, ${_source!.longitude.toStringAsFixed(4)}'
                                  : 'Tap map to set pickup',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _source != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _source != null
                            ? GestureDetector(
                                key: const ValueKey('remove-src'),
                                onTap: () => setState(() {
                                  _source = null;
                                  _selectingSource = true;
                                  _routes.clear();
                                  _routeDistances.clear();
                                  _routeDurations.clear();
                                  _selectedRouteIndex = 0;
                                }),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      size: 15, color: Color(0xFFEF4444)),
                                ),
                              )
                            : _selectingSource
                                ? Container(
                                    key: const ValueKey('active-src'),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Active',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2563EB))),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('none-src')),
                      ),
                    ],
                  ),
                ),
                // Divider with dots
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Row(
                    children: [
                      Column(
                        children: List.generate(
                            3,
                            (_) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 1.5),
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFCBD5E1),
                                      shape: BoxShape.circle),
                                )),
                      ),
                    ],
                  ),
                ),
                // Drop row
                GestureDetector(
                  onTap: () => setState(() {
                    _selectingSource = false;
                  }),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _dest != null
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flag_rounded,
                            size: 18,
                            color: _dest != null
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DROP-OFF',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 1.0)),
                            Text(
                              _dest != null
                                  ? '${_dest!.latitude.toStringAsFixed(4)}, ${_dest!.longitude.toStringAsFixed(4)}'
                                  : 'Tap map to set destination',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _dest != null
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _dest != null
                            ? GestureDetector(
                                key: const ValueKey('remove-dst'),
                                onTap: () => setState(() {
                                  _dest = null;
                                  _selectingSource = false;
                                  _routes.clear();
                                  _routeDistances.clear();
                                  _routeDurations.clear();
                                  _selectedRouteIndex = 0;
                                }),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      size: 15, color: Color(0xFFEF4444)),
                                ),
                              )
                            : !_selectingSource
                                ? Container(
                                    key: const ValueKey('active-dst'),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: const Text('Active',
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFEF4444))),
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('none-dst')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Floating Route Geofencing Control Panel ───────────
        if (hasRoute)
          Positioned(
            top: 136,
            right: 16,
            child: Container(
              width: 175,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        _geofenceEnabled ? Icons.shield_rounded : Icons.shield_outlined,
                        size: 18,
                        color: _geofenceEnabled ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Route Shield',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 20,
                        width: 32,
                        child: Switch(
                          value: _geofenceEnabled,
                          onChanged: (v) => setState(() => _geofenceEnabled = v),
                          activeThumbColor: const Color(0xFF10B981),
                          activeTrackColor: const Color(0xFFD1FAE5),
                          inactiveThumbColor: const Color(0xFF94A3B8),
                          inactiveTrackColor: const Color(0xFFF1F5F9),
                        ),
                      ),
                    ],
                  ),
                  if (_geofenceEnabled) ...[
                    const Divider(height: 14, color: Color(0xFFE2E8F0)),
                    Text(
                      'BUFFER: ${_geofenceBufferKm >= 1.0 ? "${_geofenceBufferKm.toStringAsFixed(1)} km" : "${(_geofenceBufferKm * 1000).toStringAsFixed(0)} m"}',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [0.5, 1.0, 2.5, 5.0].map((val) {
                        final isSel = _geofenceBufferKm == val;
                        return GestureDetector(
                          onTap: () => setState(() => _geofenceBufferKm = val),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFE6F4EA) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: isSel ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              val >= 1.0 ? '${val.toStringAsFixed(0)}k' : '500',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? const Color(0xFF137333) : const Color(0xFF64748B)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

        // ── Loading overlay when fetching GIS routes ───────────
        if (_isLoadingRoute)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10)
                        ],
                      ),
                      child: const Text(
                        'Fetching premium OSRM alternatives...',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Tap hint badge (shown only when route is NOT active yet) ──────
        if (!hasRoute)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectingSource
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: (_selectingSource
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFEF4444))
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        _selectingSource
                            ? Icons.my_location_rounded
                            : Icons.flag_rounded,
                        color: Colors.white,
                        size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _selectingSource
                          ? 'Tap map to pin PICKUP location'
                          : 'Tap map to pin DROP-OFF location',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Distance & OSRM Route selection overlay ──────────
        if (hasRoute && _routes.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SELECT OSRM ROUTE (MAX 3 ALTERNATIVES)',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.8),
                      ),
                      if (_geofenceEnabled)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, color: Color(0xFF065F46), size: 10),
                              SizedBox(width: 4),
                              Text(
                                'SHIELD ACTIVE',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF065F46)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(_routes.length, (idx) {
                      final isSel = _selectedRouteIndex == idx;
                      final dist = _routeDistances[idx];
                      final dur = _routeDurations[idx];
                      String name = 'Primary (Fastest)';
                      if (idx == 1) name = 'Alternative 1';
                      if (idx == 2) name = 'Alternative 2';

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRouteIndex = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              left: idx == 0 ? 0 : 4,
                              right: idx == _routes.length - 1 ? 0 : 4,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: isSel ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${dist.toStringAsFixed(0)} km',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${dur.toStringAsFixed(0)} mins',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStep3() {
    final availableDrivers = MockDataService.drivers
        .where((d) => d.status == DriverStatus.available)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Truck Configuration ─────────────────────────────
          _sectionTitle('Truck Configuration'),

          // Truck Type + Count side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _dropdownField('Truck Type', _truckTypes, _truckType,
                    (v) => setState(() => _truckType = v!)),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No. of Trucks',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _truckCountCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF2563EB), width: 2)),
                        suffixText: 'trucks',
                        suffixStyle: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n > 0) setState(() => _truckCount = n);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fleet scale badge
          if (_truckCount >= 10)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _truckCount >= 100
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _truckCount >= 100
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                        : const Color(0xFF2563EB).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _truckCount >= 100
                          ? Icons.local_shipping_rounded
                          : Icons.info_outline_rounded,
                      size: 15,
                      color: _truckCount >= 100
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF2563EB),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _truckCount >= 100
                          ? 'Massive fleet — $_truckCount trucks. Use Excel upload for drivers.'
                          : 'Fleet of $_truckCount trucks — select drivers below.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _truckCount >= 100
                            ? const Color(0xFFD97706)
                            : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Driver Assignment ────────────────────────────────
          _sectionTitle('Driver Assignment'),

          // Mode toggle
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _modeTab(0, Icons.people_outline_rounded, 'System Drivers'),
                _modeTab(1, Icons.upload_file_rounded, 'Upload Excel'),
              ],
            ),
          ),

          if (_assignMode == 0) ...[
            // ── System drivers list ──────────────────────────
            Row(
              children: [
                Text('${availableDrivers.length} drivers available',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_assignedDrivers.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _assignedDrivers.clear()),
                    child: const Text('Clear all',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ...availableDrivers.map((d) {
              final sel = _assignedDrivers.contains(d.id);
              return GestureDetector(
                onTap: () => setState(() {
                  if (sel) {
                    _assignedDrivers.remove(d.id);
                  } else {
                    _assignedDrivers.add(d.id);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      width: sel ? 1.5 : 1,
                    ),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: sel
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            child: Text(
                              d.name.substring(0, 1),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          if (sel)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2563EB),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    size: 10, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF0F172A),
                                )),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.route_rounded,
                                    size: 11, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 3),
                                Text('${d.totalTrips} trips',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8))),
                                const SizedBox(width: 8),
                                const Icon(Icons.star_rounded,
                                    size: 11, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                Text('${d.rating}',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sel ? 'Selected' : 'Assign',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ] else ...[
            // ── Excel upload placeholder ─────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.upload_file_rounded,
                        color: Color(0xFF2563EB), size: 30),
                  ),
                  const SizedBox(height: 14),
                  const Text('Upload Driver–Truck Assignment',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text(
                    'Upload your Excel file with truck IDs and\ndriver assignments for this consignment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  // Upload button (mock)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Excel upload — coming in full app',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600)),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Choose Excel / CSV File',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Format hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 15, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Format: Truck ID | Driver Name | License No | Contact',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Selection summary ────────────────────────────────
          if (_assignedDrivers.isNotEmpty || _truckCount > 0)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.brandBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assignment Summary',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          '$_truckCount ${_truckType}s · ${_assignedDrivers.length} drivers assigned',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeTab(int index, IconData icon, String label) {
    final active = _assignMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _assignMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: active
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF94A3B8),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.brandBlue,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.brandBlue.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_step == 2 ? 'Create Consignment' : 'Continue',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(width: 6),
                    Icon(
                        _step == 2
                            ? Icons.check_circle_outline_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(children: [
          Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white)),
        ]),
      );

  Widget _field(String label, TextEditingController ctrl, String hint,
      {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral300)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(
              fontFamily: 'Inter', color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontFamily: 'Inter', color: AppColors.neutral500, fontSize: 14),
            filled: true,
            fillColor: AppColors.darkSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.darkBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.darkBorder)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.brandBlue, width: 2)),
          ),
        ),
      ]),
    );
  }

  Widget _dropdownField(String label, List<String> items, String value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral300)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          dropdownColor: AppColors.darkCard,
          style: const TextStyle(
              fontFamily: 'Inter', color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.darkSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.darkBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.darkBorder)),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ]),
    );
  }

}

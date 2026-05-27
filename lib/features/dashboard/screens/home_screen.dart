import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _counterController;
  late MapController _mapController;
  Timer? _liveTimer;
  int _alertIndex = 0;

  // Live counters
  int _activeVehicles = 0;
  int _deliveriesToday = 0;
  int _onTimePercent = 0;
  String _distanceCovered = '0 km';

  final List<Map<String, dynamic>> _liveMarkers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _initMarkers();
    _startCounterAnimation();
    _startLiveSim();
  }

  void _initMarkers() {
    for (final truck in MockDataService.trucks) {
      _liveMarkers.add({
        'id': truck.id,
        'lat': truck.lat,
        'lng': truck.lng,
        'speed': truck.speed,
        'heading': truck.heading,
        'status': truck.status,
      });
    }
  }

  void _startCounterAnimation() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _counterController.forward();
    });

    final tgtV = AppConstants.mockVehicleCount;
    final tgtD = AppConstants.mockDeliveriesToday;
    final tgtP = AppConstants.mockOnTimePercent;

    Timer.periodic(const Duration(milliseconds: 20), (t) {
      if (!mounted) { t.cancel(); return; }
      final p = math.min(1.0, t.tick / 60.0);
      setState(() {
        _activeVehicles = (tgtV * p).round();
        _deliveriesToday = (tgtD * p).round();
        _onTimePercent = (tgtP * p).round();
        _distanceCovered = '${(12540 * p).round()} km';
      });
      if (p >= 1.0) t.cancel();
    });
  }

  void _startLiveSim() {
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _alertIndex = (_alertIndex + 1) % MockDataService.liveAlerts.length;
        // Slightly move truck markers
        for (final m in _liveMarkers) {
          if ((m['speed'] as double) > 0) {
            final heading = m['heading'] as double;
            m['lat'] = (m['lat'] as double) + math.cos(heading * math.pi / 180) * 0.0002;
            m['lng'] = (m['lng'] as double) + math.sin(heading * math.pi / 180) * 0.0002;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _counterController.dispose();
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ── Full-screen Map ────────────────────────
          Positioned.fill(child: _buildMap()),
          // ── Top Overlay ───────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(statusBarHeight),
          ),
          // ── Live Stats Strip ─────────────────────
          Positioned(
            top: statusBarHeight + 76,
            left: 16,
            right: 16,
            child: _buildStatsRow(),
          ),
          // ── Bottom Panel ──────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
          // ── Map Controls ──────────────────────────
          Positioned(
            right: 16,
            bottom: 375,
            child: _buildMapControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(17.3617, 82.8000),
        initialZoom: 8.5,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.eazecargo.eaze_my_cargo',
          tileBuilder: (context, widget, tile) {
            return ColorFiltered(
              // Slightly desaturated light map filter for elite custom look
              colorFilter: const ColorFilter.matrix([
                0.90, 0.00, 0.00, 0, 8,
                0.00, 0.90, 0.00, 0, 8,
                0.00, 0.00, 0.90, 0, 12,
                0,    0,    0,    1, 0,
              ]),
              child: widget,
            );
          },
        ),
        // Route polylines
        PolylineLayer(
          polylines: [
            Polyline(
              points: const [
                LatLng(17.6868, 83.2185),
                LatLng(17.3617, 82.5543),
                LatLng(16.9891, 82.2475),
              ],
              strokeWidth: 3.5,
              color: AppColors.brandBlue.withValues(alpha: 0.8),
            ),
            Polyline(
              points: const [
                LatLng(16.9891, 82.2475),
                LatLng(16.5061, 80.6480),
              ],
              strokeWidth: 2.5,
              color: AppColors.brandRed.withValues(alpha: 0.6),
            ),
          ],
        ),
        // Port / depot markers
        MarkerLayer(
          markers: [
            _buildPortMarker(17.6868, 83.2185, 'Vizag Port'),
            _buildPortMarker(16.9891, 82.2475, 'Kakinada Port'),
          ],
        ),
        // Live truck markers
        MarkerLayer(
          markers: _liveMarkers.map((m) {
            final status = m['status'] as TruckStatus;
            return _buildTruckMarker(
              m['lat'] as double,
              m['lng'] as double,
              m['heading'] as double,
              m['speed'] as double,
              status,
            );
          }).toList(),
        ),
      ],
    );
  }

  Marker _buildPortMarker(double lat, double lng, String name) {
    return Marker(
      point: LatLng(lat, lng),
      width: 120,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.anchor_rounded, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          Container(
            width: 2,
            height: 8,
            color: AppColors.brandBlue,
          ),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              width: 10 + _pulseController.value * 4,
              height: 10 + _pulseController.value * 4,
              decoration: BoxDecoration(
                color: AppColors.brandBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(
                        alpha: 0.5 - _pulseController.value * 0.4),
                    blurRadius: 16 * _pulseController.value,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildTruckMarker(
      double lat, double lng, double heading, double speed, TruckStatus status) {
    final color = status == TruckStatus.assigned
        ? AppColors.statusActive
        : status == TruckStatus.maintenance
            ? AppColors.warning
            : AppColors.neutral400;

    return Marker(
      point: LatLng(lat, lng),
      width: 40,
      height: 40,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            if (speed > 0)
              Container(
                width: 36 + _pulseController.value * 8,
                height: 36 + _pulseController.value * 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(
                      alpha: 0.15 - _pulseController.value * 0.12),
                ),
              ),
            Transform.rotate(
              angle: heading * math.pi / 180,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6),
                  ],
                ),
                child: const Icon(
                  Icons.navigation_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(double statusBarHeight) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, statusBarHeight + 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Premium asset logo at a perfectly proportioned height
          Image.asset(
            'assets/images/logo.png',
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const BrandLogo(fontSize: 18, withIcon: false),
          ),
          const SizedBox(width: 24),
          // Live status badge next to logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusActive.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.statusActive.withValues(alpha: 0.15),
                  width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) => Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.statusActive.withValues(
                          alpha: 0.4 + _pulseController.value * 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text('LIVE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.statusActive,
                      letterSpacing: 0.5,
                    )),
              ],
            ),
          ),
          const Spacer(),
          // Action controls cluster
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // High-contrast clean notification trigger
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppConstants.routeNotifications),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.brandRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Center(
                        child: Text('7',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Thin vertical divider line
              Container(
                width: 1.5,
                height: 24,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 12),
              // Ultra-premium Operators initial avatar badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.brandBlueLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brandBlue, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandBlue.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('OP',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandBlue,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _miniStat('Active Vehicles', '$_activeVehicles', Icons.local_shipping_rounded, AppColors.brandBlue),
          const SizedBox(width: 8),
          _miniStat('Deliveries Today', '$_deliveriesToday', Icons.inventory_2_rounded, AppColors.success),
          const SizedBox(width: 8),
          _miniStat('On Time', '$_onTimePercent%', Icons.access_time_rounded, AppColors.warning),
          const SizedBox(width: 8),
          _miniStat('Distance', _distanceCovered, Icons.route_rounded, AppColors.brandRed),
          const SizedBox(width: 8),
          _miniStat(
            'Alerts',
            '${MockDataService.liveAlerts.length}',
            Icons.warning_rounded,
            AppColors.brandRed,
            onTap: () => context.push(AppConstants.routeConsignmentMonitor),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.0,
                    )),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF64748B), // Slate-500
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        _mapControlButton(Icons.add_rounded, () {
          _mapController.move(
            _mapController.camera.center,
            _mapController.camera.zoom + 1,
          );
        }),
        const SizedBox(height: 8),
        _mapControlButton(Icons.remove_rounded, () {
          _mapController.move(
            _mapController.camera.center,
            _mapController.camera.zoom - 1,
          );
        }),
        const SizedBox(height: 8),
        _mapControlButton(Icons.my_location_rounded, () {
          _mapController.move(
            const LatLng(17.3617, 82.8000),
            8.5,
          );
        }),
        const SizedBox(height: 8),
        _mapControlButton(Icons.layers_rounded, () {}),
      ],
    );
  }

  Widget _mapControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF475569), size: 20),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                const Text('Live Operations',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A), // Slate-900
                      letterSpacing: -0.3,
                    )),
                const SizedBox(width: 8),
                const LiveIndicator(),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppConstants.routeConsignments),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.brandBlue,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View All',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandBlue,
                      )),
                ),
              ],
            ),
          ),
          // Quick nav row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _quickNavBtn(Icons.receipt_long_rounded, 'Shipments',
                    AppColors.brandBlue, AppConstants.routeConsignments),
                const SizedBox(width: 8),
                _quickNavBtn(Icons.local_shipping_rounded, 'Trucks',
                    AppColors.warning, AppConstants.routeTrucks),
                const SizedBox(width: 8),
                _quickNavBtn(Icons.people_rounded, 'Drivers',
                    AppColors.success, AppConstants.routeDrivers),
                const SizedBox(width: 8),
                _quickNavBtn(Icons.bar_chart_rounded, 'Analytics',
                    AppColors.brandRed, AppConstants.routeAnalytics),
              ],
            ),
          ),
          // Alerts feed
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live Alerts',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569), // Slate-600
                      letterSpacing: -0.1,
                    )),
                const SizedBox(height: 8),
                ...MockDataService.liveAlerts.take(3).map((alert) {
                  return AlertTile(
                    title: alert.title,
                    subtitle: alert.subtitle,
                    icon: _alertIcon(alert.type),
                    color: _alertColor(alert.severity),
                    time: alert.time,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _quickNavBtn(
      IconData icon, String label, Color color, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.routeDeviation: return Icons.alt_route_rounded;
      case AlertType.truckStopped: return Icons.pause_circle_rounded;
      case AlertType.delayedShipment: return Icons.schedule_rounded;
      case AlertType.geofenceViolation: return Icons.fence_rounded;
      case AlertType.etaWarning: return Icons.access_time_rounded;
      case AlertType.incident: return Icons.report_rounded;
    }
  }

  Color _alertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low: return AppColors.neutral400;
      case AlertSeverity.medium: return AppColors.warning;
      case AlertSeverity.high: return AppColors.brandRed;
      case AlertSeverity.critical: return AppColors.brandRed;
    }
  }
}

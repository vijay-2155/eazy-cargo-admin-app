import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});
  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  int _selectedZone = 0;

  final _zones = [
    {'name': 'Vizag Port Restricted', 'type': 'Restricted', 'status': 'Active', 'violations': 2, 'color': AppColors.brandRed, 'lat': 17.6868, 'lng': 83.2185},
    {'name': 'Kakinada Industrial', 'type': 'Corridor', 'status': 'Active', 'violations': 0, 'color': AppColors.brandBlue, 'lat': 16.9891, 'lng': 82.2475},
    {'name': 'NH16 Safety Zone', 'type': 'Safety', 'status': 'Active', 'violations': 1, 'color': AppColors.warning, 'lat': 17.3617, 'lng': 82.8000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(title: 'Geofence Monitor',
          actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.brandBlue), onPressed: () {})]),
      body: Column(children: [
        SizedBox(
          height: 260,
          child: FlutterMap(
            options: const MapOptions(initialCenter: LatLng(17.3617, 82.8), initialZoom: 8.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eazecargo.eaze_my_cargo',
                tileBuilder: (ctx, w, _) => ColorFiltered(
                  colorFilter: const ColorFilter.matrix([0.2,0.3,0.2,0,20, 0.2,0.3,0.2,0,20, 0.2,0.3,0.2,0,20, 0,0,0,1,0]),
                  child: w,
                ),
              ),
              CircleLayer(circles: _zones.map((z) => CircleMarker(
                point: LatLng(z['lat'] as double, z['lng'] as double),
                radius: 12000,
                color: (z['color'] as Color).withValues(alpha: 0.15),
                borderColor: (z['color'] as Color).withValues(alpha: 0.6),
                borderStrokeWidth: 2,
                useRadiusInMeter: true,
              )).toList()),
            ],
          ),
        ),
        Expanded(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Active Zones', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white)),
            const SizedBox(height: 10),
            ..._zones.asMap().entries.map((e) {
              final z = e.value;
              final color = z['color'] as Color;
              final violations = z['violations'] as int;
              return GestureDetector(
                onTap: () => setState(() => _selectedZone = e.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _selectedZone == e.key ? color : AppColors.darkBorder, width: _selectedZone == e.key ? 2 : 1),
                  ),
                  child: Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.fence_rounded, color: color, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(z['name'] as String, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
                      const SizedBox(height: 3),
                      Text(z['type'] as String, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.neutral400)),
                    ])),
                    if (violations > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.brandRed.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text('$violations alerts', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brandRed)),
                      )
                    else
                      const StatusBadge(label: 'Clear', color: AppColors.success),
                  ]),
                ),
              );
            }),
          ],
        )),
      ]),
    );
  }
}

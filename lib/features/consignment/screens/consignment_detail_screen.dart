import 'package:flutter/material.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class ConsignmentDetailScreen extends StatelessWidget {
  final String id;
  const ConsignmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final c = MockDataService.consignments.firstWhere(
      (e) => e.id == id,
      orElse: () => MockDataService.consignments.first,
    );

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: c.id,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.brandBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                StatusBadge(label: c.status.label, color: Colors.white, bgColor: Colors.white.withValues(alpha: 0.2)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(c.priority.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 12),
              Text(c.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text(c.clientName, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: c.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text('${(c.progress * 100).toStringAsFixed(0)}% complete', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white70)),
                const Spacer(),
                Text('ETA: ${c.eta}', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          // Route
          _infoCard('Route', [
            _routeRow(c.source, c.destination),
          ]),
          const SizedBox(height: 12),
          // Cargo details
          _infoCard('Cargo Details', [
            _detailRow('Cargo Type', c.cargoType),
            _detailRow('Weight', '${c.weightTons} Tons'),
            _detailRow('Trip Date', c.tripDate),
            _detailRow('Contact', c.clientContact),
          ]),
          const SizedBox(height: 12),
          // Trucks
          _infoCard('Assigned Trucks (${c.truckIds.length})', [
            ...c.truckIds.map((tid) {
              final truck = MockDataService.trucks.firstWhere((t) => t.id == tid, orElse: () => MockDataService.trucks.first);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.local_shipping_rounded, color: AppColors.brandBlue, size: 18),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(truck.regNumber, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
                    Text(truck.type.name, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.neutral400)),
                  ]),
                  const Spacer(),
                  Text('${truck.speed.toInt()} km/h', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                ]),
              );
            }),
          ]),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.darkBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.neutral400)),
        const Spacer(),
        Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
      ]),
    );
  }

  Widget _routeRow(String src, String dst) {
    return Row(children: [
      const Icon(Icons.circle_outlined, size: 12, color: AppColors.brandBlue),
      const SizedBox(width: 8),
      Expanded(child: Text(src, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.neutral300))),
      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.neutral500),
      Expanded(child: Text(dst, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.neutral300), textAlign: TextAlign.right)),
      const SizedBox(width: 8),
      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.brandRed),
    ]);
  }


}

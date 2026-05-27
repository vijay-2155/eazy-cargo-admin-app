import 'package:flutter/material.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _alertIcon(AlertType t) {
    switch (t) {
      case AlertType.routeDeviation: return Icons.alt_route_rounded;
      case AlertType.truckStopped: return Icons.pause_circle_rounded;
      case AlertType.delayedShipment: return Icons.schedule_rounded;
      case AlertType.geofenceViolation: return Icons.fence_rounded;
      case AlertType.etaWarning: return Icons.access_time_rounded;
      case AlertType.incident: return Icons.report_rounded;
    }
  }

  Color _severityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.low: return AppColors.neutral300;
      case AlertSeverity.medium: return AppColors.warning;
      case AlertSeverity.high: return AppColors.brandRed;
      case AlertSeverity.critical: return AppColors.brandRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'Notifications',
        showBack: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Clear All', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brandRed)),
          ),
        ],
      ),
      body: Column(children: [
        _buildSummaryBar(),
        Expanded(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Today', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neutral500, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            ...MockDataService.liveAlerts.map((a) {
              final color = _severityColor(a.severity);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withValues(alpha: 0.2))),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(_alertIcon(a.type), color: color, size: 22),
                  ),
                  title: Text(a.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(a.subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.neutral400)),
                  ),
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(a.time, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.neutral500)),
                    const SizedBox(height: 6),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.brandBlue, shape: BoxShape.circle)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Earlier', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.neutral500, letterSpacing: 0.8)),
            const SizedBox(height: 10),
            _systemNotif('System', 'Fleet sync completed — 8 trucks updated', '2h ago', Icons.sync_rounded),
            _systemNotif('Dispatch', 'CONS-005 marked as Delivered', '4h ago', Icons.check_circle_rounded),
            _systemNotif('System', 'GPS signal restored for TRK-006', '6h ago', Icons.gps_fixed_rounded),
          ],
        )),
      ]),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.notifications_active_rounded, color: AppColors.brandRed, size: 20),
        const SizedBox(width: 10),
        const Expanded(child: Text('5 unread alerts require attention', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.brandRed, borderRadius: BorderRadius.circular(10)),
          child: const Text('5', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
      ]),
    );
  }

  Widget _systemNotif(String from, String msg, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.darkBorder)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.neutral400, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(from, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral400)),
          Text(msg, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.neutral300), maxLines: 2),
        ])),
        const SizedBox(width: 8),
        Text(time, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.neutral500)),
      ]),
    );
  }
}

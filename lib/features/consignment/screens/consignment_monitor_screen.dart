import 'package:flutter/material.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class ConsignmentMonitorScreen extends StatefulWidget {
  const ConsignmentMonitorScreen({super.key});

  @override
  State<ConsignmentMonitorScreen> createState() => _ConsignmentMonitorScreenState();
}

class _ConsignmentMonitorScreenState extends State<ConsignmentMonitorScreen> {
  String _activeCategory = 'All';
  final Map<String, bool> _expandedConsignments = {
    'CONS-001': true,
    'CONS-002': true,
    'CONS-003': false,
  };

  // Mock list of active violations & events consignment-wise
  final List<ConsignmentEventsGroup> _groups = [
    ConsignmentEventsGroup(
      consignmentId: 'CONS-001',
      consignmentName: 'Vizag Port Export Batch #1',
      client: 'Reliance Industries Ltd.',
      activeTruck: 'TRK-003 (Mohammad Rafiq)',
      route: 'Visakhapatnam Port ➔ Kakinada',
      progress: 0.62,
      alerts: [
        MonitorAlert(
          id: 'EVT-101',
          type: AlertType.routeDeviation,
          title: 'Route Deviation Detected',
          description: 'Vehicle deviated 2.4km off NH-16 corridor near Anakapalli.',
          time: '2m ago',
          severity: AlertSeverity.high,
        ),
        MonitorAlert(
          id: 'EVT-102',
          type: AlertType.truckStopped,
          title: 'Transit Delay Potential',
          description: 'Stopped at local terminal checkpoint for over 25 minutes.',
          time: '15m ago',
          severity: AlertSeverity.medium,
        ),
      ],
      timeline: [
        TimelineEvent(time: '11:45 AM', label: 'Route Deviation Triggered', isAlert: true),
        TimelineEvent(time: '11:20 AM', label: 'Unplanned Halt near Anakapalli Toll', isAlert: false),
        TimelineEvent(time: '09:15 AM', label: 'Dispatched from Visakhapatnam Port Gate 3', isAlert: false),
      ],
    ),
    ConsignmentEventsGroup(
      consignmentId: 'CONS-002',
      consignmentName: 'Kakinada Chemical Bulk',
      client: 'ONGC Petroadditions',
      activeTruck: 'TRK-005 (Prakash Goud)',
      route: 'Kakinada Port ➔ Vijayawada APIIC',
      progress: 0.28,
      alerts: [
        MonitorAlert(
          id: 'EVT-103',
          type: AlertType.geofenceViolation,
          title: 'Geofence Breach',
          description: 'Left designated safe zone corridor near Peddapuram Bypass.',
          time: '5m ago',
          severity: AlertSeverity.critical,
        ),
      ],
      timeline: [
        TimelineEvent(time: '11:42 AM', label: 'Geofence Exit Violation', isAlert: true),
        TimelineEvent(time: '10:00 AM', label: 'System Route Locking Activated', isAlert: false),
        TimelineEvent(time: '08:30 AM', label: 'Cargo weight verification: 280 Tons OK', isAlert: false),
      ],
    ),
    ConsignmentEventsGroup(
      consignmentId: 'CONS-003',
      consignmentName: 'AP Cement Delivery',
      client: 'Dalmia Cement',
      activeTruck: 'TRK-006 (Srinivas Murthy)',
      route: 'Guntur Cement Plant ➔ Vizag Depot',
      progress: 0.15,
      alerts: [
        MonitorAlert(
          id: 'EVT-104',
          type: AlertType.delayedShipment,
          title: 'ETA Severe Delay Warning',
          description: 'Delayed by +3 hours due to maintenance halt at Guntur Service Center.',
          time: '22m ago',
          severity: AlertSeverity.high,
        ),
      ],
      timeline: [
        TimelineEvent(time: '11:15 AM', label: 'Maintenance Stop Logged', isAlert: true),
        TimelineEvent(time: '10:30 AM', label: 'Trip started from Guntur Plant', isAlert: false),
      ],
    ),
  ];

  Color _severityColor(AlertSeverity sev) {
    switch (sev) {
      case AlertSeverity.critical: return AppColors.brandRed;
      case AlertSeverity.high:     return const Color(0xFFEA580C); // Dark orange
      case AlertSeverity.medium:   return AppColors.warning;
      case AlertSeverity.low:      return AppColors.brandBlue;
    }
  }

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.routeDeviation:   return Icons.alt_route_rounded;
      case AlertType.geofenceViolation: return Icons.door_sliding_rounded;
      case AlertType.truckStopped:      return Icons.motion_photos_off_rounded;
      case AlertType.delayedShipment:   return Icons.hourglass_bottom_rounded;
      case AlertType.etaWarning:        return Icons.more_time_rounded;
      case AlertType.incident:          return Icons.report_problem_rounded;
    }
  }

  void _dismissAlert(String groupId, String alertId) {
    setState(() {
      final gIdx = _groups.indexWhere((element) => element.consignmentId == groupId);
      if (gIdx != -1) {
        _groups[gIdx].alerts.removeWhere((a) => a.id == alertId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Alert marked as resolved.',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredGroups = _groups.where((g) {
      if (_activeCategory == 'All') return true;
      if (_activeCategory == 'Deviations') {
        return g.alerts.any((a) => a.type == AlertType.routeDeviation);
      }
      if (_activeCategory == 'Geofence') {
        return g.alerts.any((a) => a.type == AlertType.geofenceViolation);
      }
      if (_activeCategory == 'Delays') {
        return g.alerts.any((a) => a.type == AlertType.delayedShipment || a.type == AlertType.truckStopped);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'Live Alerts Monitor',
        showBack: true,
      ),
      body: Column(
        children: [
          // ── Realtime Stats Panel ─────────────────────────
          _buildStatsPanel(),

          // ── Category Pills ──────────────────────────────
          _buildCategoryPills(),

          // ── Events List ──────────────────────────────────
          Expanded(
            child: filteredGroups.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredGroups.length,
                    itemBuilder: (context, idx) {
                      final group = filteredGroups[idx];
                      return _buildConsignmentMonitorCard(group);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Stats Panel ─────────────────────────────────────────────────
  Widget _buildStatsPanel() {
    int criticalCount = 0;
    int deviationCount = 0;
    int haltCount = 0;

    for (var g in _groups) {
      criticalCount += g.alerts.where((a) => a.severity == AlertSeverity.critical).length;
      deviationCount += g.alerts.where((a) => a.type == AlertType.routeDeviation).length;
      haltCount += g.alerts.where((a) => a.type == AlertType.truckStopped).length;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.brandRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SYSTEM EMERGENCY LOG',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandRed,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              const Text(
                'Live Syncing',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatMetric(
                label: 'CRITICAL',
                val: criticalCount.toString(),
                color: AppColors.brandRed,
              ),
              Container(width: 1, height: 32, color: AppColors.darkBorder),
              _buildStatMetric(
                label: 'DEVIATIONS',
                val: deviationCount.toString(),
                color: const Color(0xFFEA580C),
              ),
              Container(width: 1, height: 32, color: AppColors.darkBorder),
              _buildStatMetric(
                label: 'UNPLANNED HALTS',
                val: haltCount.toString(),
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric({required String label, required String val, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Pills ──────────────────────────────────────────────
  Widget _buildCategoryPills() {
    final categories = ['All', 'Deviations', 'Geofence', 'Delays'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((cat) {
            final active = _activeCategory == cat;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.brandBlue : AppColors.darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? AppColors.brandBlue : AppColors.darkBorder,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.neutral400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Consignment Live Monitor Card ───────────────────────────────
  Widget _buildConsignmentMonitorCard(ConsignmentEventsGroup group) {
    final exp = _expandedConsignments[group.consignmentId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: group.alerts.isNotEmpty
              ? _severityColor(group.alerts.first.severity).withValues(alpha: 0.4)
              : AppColors.darkBorder,
          width: group.alerts.isNotEmpty ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          InkWell(
            onTap: () => setState(() => _expandedConsignments[group.consignmentId] = !exp),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              group.consignmentId,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (group.alerts.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brandRed.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: AppColors.brandRed, size: 10),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${group.alerts.length} ALERTS',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brandRed,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          group.consignmentName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          group.route,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    exp ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.neutral500,
                  ),
                ],
              ),
            ),
          ),

          // Core details when expanded
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: AppColors.darkBorder, height: 1),
                ),

                // Active vehicle tracker
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_rounded, color: AppColors.neutral400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          group.activeTruck,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Client: ${group.client}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Violations Section
                if (group.alerts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      'ACTIVE VIOLATIONS & ALERTS',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandRed.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...group.alerts.map((alert) => _buildAlertItem(group.consignmentId, alert)),
                ],

                // Live Timeline Stream
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: const Text(
                    'LATEST TRANSIT EVENTS TIMELINE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildTimeline(group.timeline),

                // Actions buttons footer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Dialing driver app via mobile tunnel...',
                                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: AppColors.brandBlue,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone_iphone_rounded, size: 14, color: AppColors.brandBlue),
                          label: const Text(
                            'Call Driver',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandBlue,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.brandBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Sending high-accuracy GPS refresh request...',
                                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                                ),
                                backgroundColor: AppColors.brandBlue,
                              ),
                            );
                          },
                          icon: const Icon(Icons.gps_fixed_rounded, size: 14, color: Colors.white),
                          label: const Text(
                            'Ping Mobile GPS',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            crossFadeState: exp ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // ── Alert Card Item ─────────────────────────────────────────────
  Widget _buildAlertItem(String groupId, MonitorAlert alert) {
    final borderCol = _severityColor(alert.severity);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderCol, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_alertIcon(alert.type), size: 18, color: borderCol),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      alert.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.neutral400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    alert.time,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: borderCol.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      alert.severity.name.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: borderCol,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _dismissAlert(groupId, alert.id),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'MARK RESOLVED',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Timeline Builder ────────────────────────────────────────────
  Widget _buildTimeline(List<TimelineEvent> timeline) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: List.generate(timeline.length, (i) {
          final event = timeline[i];
          final isLast = i == timeline.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator line & dot
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: event.isAlert ? AppColors.brandRed : AppColors.brandBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      color: AppColors.darkBorder,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          event.time,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (event.isAlert)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.brandRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VIOLATION',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: AppColors.brandRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: event.isAlert ? AppColors.brandRed : AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_user_rounded, size: 52, color: AppColors.success),
          const SizedBox(height: 14),
          const Text(
            'All Consignments Clear',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No active geofence, route, or halt violations.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting Data Structures ────────────────────────────────────
class ConsignmentEventsGroup {
  final String consignmentId;
  final String consignmentName;
  final String client;
  final String activeTruck;
  final String route;
  final double progress;
  final List<MonitorAlert> alerts;
  final List<TimelineEvent> timeline;

  ConsignmentEventsGroup({
    required this.consignmentId,
    required this.consignmentName,
    required this.client,
    required this.activeTruck,
    required this.route,
    required this.progress,
    required this.alerts,
    required this.timeline,
  });
}

class MonitorAlert {
  final String id;
  final AlertType type;
  final String title;
  final String description;
  final String time;
  final AlertSeverity severity;

  MonitorAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.severity,
  });
}

class TimelineEvent {
  final String time;
  final String label;
  final bool isAlert;

  TimelineEvent({
    required this.time,
    required this.label,
    required this.isAlert,
  });
}

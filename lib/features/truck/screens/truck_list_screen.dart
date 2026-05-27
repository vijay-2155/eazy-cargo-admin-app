import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class TruckListScreen extends StatefulWidget {
  const TruckListScreen({super.key});
  @override
  State<TruckListScreen> createState() => _TruckListScreenState();
}

class _TruckListScreenState extends State<TruckListScreen> {
  TruckGroup? _groupFilter;
  TruckStatus? _statusFilter;
  String _search = '';
  final _searchCtrl = TextEditingController();
  bool _searchFocused = false;
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() => _searchFocused = _searchFocus.hasFocus));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<TruckModel> get _filtered {
    return MockDataService.trucks.where((t) {
      final matchGroup = _groupFilter == null || t.group == _groupFilter;
      final matchStatus = _statusFilter == null || t.status == _statusFilter;
      final matchSearch = _search.isEmpty ||
          t.regNumber.toLowerCase().contains(_search.toLowerCase()) ||
          t.type.name.toLowerCase().contains(_search.toLowerCase()) ||
          (t.currentLocation != null && t.currentLocation!.toLowerCase().contains(_search.toLowerCase()));
      return matchGroup && matchStatus && matchSearch;
    }).toList();
  }

  Color _truckStatusColor(TruckStatus s) {
    switch (s) {
      case TruckStatus.available:   return AppColors.success;
      case TruckStatus.assigned:    return AppColors.brandBlue;
      case TruckStatus.maintenance: return AppColors.warning;
      case TruckStatus.offline:     return AppColors.neutral400;
    }
  }

  IconData _truckStatusIcon(TruckStatus s) {
    switch (s) {
      case TruckStatus.available:   return Icons.check_circle_outline_rounded;
      case TruckStatus.assigned:    return Icons.local_shipping_rounded;
      case TruckStatus.maintenance: return Icons.build_rounded;
      case TruckStatus.offline:     return Icons.power_settings_new_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'Trucks',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.white, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Sticky Header: Search + Two level filters ─────────
          Container(
            color: AppColors.darkBg,
            child: Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 10),
                _buildGroupFilters(),
                const SizedBox(height: 8),
                _buildStatusFilters(),
                const SizedBox(height: 12),
                _buildStatsStrip(filtered),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // ── Truck List ────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty ? _buildEmpty() : _buildList(filtered),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCTA(),
    );
  }

  // ── Search field ────────────────────────────────────────────────
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocused ? AppColors.brandBlue : AppColors.darkBorder,
            width: _searchFocused ? 1.8 : 1.2,
          ),
          boxShadow: _searchFocused ? [
            BoxShadow(
              color: AppColors.brandBlue.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ] : [],
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search by reg number, type or city...',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.neutral500,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.neutral400,
              size: 20,
            ),
            suffixIcon: _search.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _search = '');
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.neutral700,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.neutral400,
                        size: 14,
                      ),
                    ),
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Ownership Group filter chips ────────────────────────────────
  Widget _buildGroupFilters() {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _groupChip(null, 'All Fleet'),
          _groupChip(TruckGroup.own, 'Own Fleet'),
          _groupChip(TruckGroup.lease, 'Lease'),
          _groupChip(TruckGroup.rented, 'Rented'),
        ],
      ),
    );
  }

  Widget _groupChip(TruckGroup? group, String label) {
    final selected = _groupFilter == group;
    final count = group == null
        ? MockDataService.trucks.length
        : MockDataService.trucks.where((t) => t.group == group).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _groupFilter = group),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandBlue : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.brandBlue : AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.neutral300,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.25) : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.neutral400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Operational Status filter chips ──────────────────────────────
  Widget _buildStatusFilters() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _statusChip(null, 'All Status', AppColors.brandBlue),
          ...TruckStatus.values.map((s) => _statusChip(s, s.name.toUpperCase(), _truckStatusColor(s))),
        ],
      ),
    );
  }

  Widget _statusChip(TruckStatus? status, String label, Color color) {
    final selected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: selected ? color : AppColors.neutral400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Metrics Strip ────────────────────────────────────────────────
  Widget _buildStatsStrip(List<TruckModel> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${filtered.length} vehicle${filtered.length == 1 ? '' : 's'} listed',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral300,
            ),
          ),
          const Spacer(),
          Text(
            'Real-time GPS',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.gps_fixed_rounded, size: 12, color: AppColors.success),
        ],
      ),
    );
  }

  // ── Truck Cards List ─────────────────────────────────────────────
  Widget _buildList(List<TruckModel> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildTruckCard(filtered[i]),
    );
  }

  Widget _buildTruckCard(TruckModel t) {
    final statusColor = _truckStatusColor(t.status);
    final isMaintenance = t.status == TruckStatus.maintenance;
    final isAvailable = t.status == TruckStatus.available;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaintenance ? AppColors.brandRed.withValues(alpha: 0.2) : AppColors.darkBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left status accent strip ──────────────────────
              Container(width: 4, color: statusColor),
              // ── Card core ─────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Registration Number + Group Pill + Status Pill
                      Row(
                        children: [
                          Text(
                            t.regNumber,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: Text(
                              t.group.name.toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Premium Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_truckStatusIcon(t.status), size: 11, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  t.status.name.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        t.type.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.neutral400,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Location info if present
                      if (t.currentLocation != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: isAvailable ? AppColors.success : AppColors.brandBlue,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  t.currentLocation!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral300,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (t.speed > 0) ...[
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(color: AppColors.neutral500, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${t.speed.toInt()} km/h',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Divider Line
                      Container(
                        height: 1,
                        color: AppColors.darkBorder,
                      ),

                      const SizedBox(height: 10),

                      // Footer Row: Specs
                      Row(
                        children: [
                          _specTag(Icons.scale_outlined, '${t.capacityTons} Tons'),
                          const SizedBox(width: 6),
                          _specTag(Icons.settings_input_antenna_rounded, t.gpsDevice),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.neutral400),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral300,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.local_shipping_outlined, size: 36, color: AppColors.brandBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Trucks Found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try widening your search terms\nor choosing another active filter.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.neutral400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() {
                _search = '';
                _statusFilter = null;
                _groupFilter = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.brandBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Reset Filters',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Action Console CTA ────────────────────────────────────
  Widget _buildBottomCTA() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => context.go('${AppConstants.routeTrucks}/create'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandBlue.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Truck to Fleet',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

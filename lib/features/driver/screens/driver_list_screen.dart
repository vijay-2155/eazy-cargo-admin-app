import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});
  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  DriverStatus? _statusFilter;
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

  List<DriverModel> get _filtered {
    return MockDataService.drivers.where((d) {
      final matchStatus = _statusFilter == null || d.status == _statusFilter;
      final matchSearch = _search.isEmpty ||
          d.name.toLowerCase().contains(_search.toLowerCase()) ||
          d.phone.toLowerCase().contains(_search.toLowerCase()) ||
          (d.assignedTruckId != null && d.assignedTruckId!.toLowerCase().contains(_search.toLowerCase()));
      return matchStatus && matchSearch;
    }).toList();
  }

  Color _statusColor(DriverStatus s) {
    switch (s) {
      case DriverStatus.available: return AppColors.success;
      case DriverStatus.onTrip:    return AppColors.brandBlue;
      case DriverStatus.onLeave:   return AppColors.warning;
      case DriverStatus.offline:   return AppColors.neutral400;
    }
  }

  String _statusLabel(DriverStatus s) {
    switch (s) {
      case DriverStatus.available: return 'Available';
      case DriverStatus.onTrip:    return 'On Trip';
      case DriverStatus.onLeave:   return 'On Leave';
      case DriverStatus.offline:   return 'Offline';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'Drivers',
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
          // ── Sticky search + status filter header ─────────────
          Container(
            color: AppColors.darkBg,
            child: Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 10),
                _buildStatusFilters(),
                const SizedBox(height: 12),
                _buildStatsStrip(filtered),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // ── Driver Cards List ────────────────────────────────
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
            hintText: 'Search by driver name, phone or vehicle...',
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

  // ── Operational Status filter pills ──────────────────────────────
  Widget _buildStatusFilters() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _statusChip(null, 'All Drivers', AppColors.brandBlue),
          ...DriverStatus.values.map((s) => _statusChip(s, _statusLabel(s), _statusColor(s))),
        ],
      ),
    );
  }

  Widget _statusChip(DriverStatus? status, String label, Color color) {
    final selected = _statusFilter == status;
    final count = status == null
        ? MockDataService.drivers.length
        : MockDataService.drivers.where((d) => d.status == status).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!selected)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.neutral300,
                ),
              ),
              const SizedBox(width: 5),
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

  // ── Metrics Strip ────────────────────────────────────────────────
  Widget _buildStatsStrip(List<DriverModel> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${filtered.length} driver${filtered.length == 1 ? '' : 's'} registered',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral300,
            ),
          ),
          const Spacer(),
          Text(
            'Active Dispatchers',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  // ── Driver List Builder ──────────────────────────────────────────
  Widget _buildList(List<DriverModel> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final d = filtered[i];
        final color = _statusColor(d.status);
        final truck = d.assignedTruckId != null
            ? MockDataService.trucks.firstWhere((t) => t.id == d.assignedTruckId, orElse: () => MockDataService.trucks.first)
            : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
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
                  // ── Left status accent strip ──────────────────
                  Container(width: 4, color: color),
                  // ── Core Content ──────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Sleek Profile initials badge with online indicator dot
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.brandBlue.withValues(alpha: 0.08),
                                child: Text(
                                  d.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandBlue,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.darkCard, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // 2. Info Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_iphone_rounded, size: 12, color: AppColors.neutral500),
                                    const SizedBox(width: 4),
                                    Text(
                                      d.phone,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: AppColors.neutral400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Status badge + Rating + Trip counters
                                Row(
                                  children: [
                                    // Status tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _statusLabel(d.status).toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: color,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Professional metrics tag
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkSurface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.darkBorder),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${d.rating}',
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.neutral300,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${d.totalTrips} trips',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: AppColors.neutral400,
                                      ),
                                    ),
                                  ],
                                ),

                                // 3. Assigned Truck card
                                if (truck != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandBlueLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.15)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.local_shipping_rounded,
                                          size: 13,
                                          color: AppColors.brandBlue,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          truck.regNumber,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.brandBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${truck.type.name})',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.brandBlue.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.neutral500,
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
      },
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
            child: const Icon(Icons.people_outline_rounded, size: 36, color: AppColors.brandBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Drivers Found',
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
        onTap: () => context.go('${AppConstants.routeDrivers}/create'),
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
              Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Register New Driver',
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

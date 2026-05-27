import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/constants/app_constants.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';
import 'package:eaze_my_cargo/services/mock/mock_data_service.dart';

class ConsignmentListScreen extends StatefulWidget {
  const ConsignmentListScreen({super.key});
  @override
  State<ConsignmentListScreen> createState() => _ConsignmentListScreenState();
}

class _ConsignmentListScreenState extends State<ConsignmentListScreen> {
  ConsignmentStatus? _filter;
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

  List<ConsignmentModel> get _filtered {
    return MockDataService.consignments.where((c) {
      final matchStatus = _filter == null || c.status == _filter;
      final matchSearch = _search.isEmpty ||
          c.name.toLowerCase().contains(_search.toLowerCase()) ||
          c.clientName.toLowerCase().contains(_search.toLowerCase()) ||
          c.id.toLowerCase().contains(_search.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();
  }

  Color _statusColor(ConsignmentStatus s) {
    switch (s) {
      case ConsignmentStatus.active:     return AppColors.brandBlue;
      case ConsignmentStatus.inTransit:  return AppColors.success;
      case ConsignmentStatus.delayed:    return AppColors.brandRed;
      case ConsignmentStatus.pending:    return AppColors.warning;
      case ConsignmentStatus.completed:  return AppColors.neutral400;
    }
  }

  IconData _statusIcon(ConsignmentStatus s) {
    switch (s) {
      case ConsignmentStatus.active:     return Icons.play_circle_rounded;
      case ConsignmentStatus.inTransit:  return Icons.local_shipping_rounded;
      case ConsignmentStatus.delayed:    return Icons.warning_amber_rounded;
      case ConsignmentStatus.pending:    return Icons.hourglass_top_rounded;
      case ConsignmentStatus.completed:  return Icons.check_circle_rounded;
    }
  }

  Color _priorityColor(PriorityLevel p) {
    switch (p) {
      case PriorityLevel.critical: return AppColors.brandRed;
      case PriorityLevel.high:     return AppColors.warning;
      case PriorityLevel.medium:   return AppColors.brandBlue;
      case PriorityLevel.low:      return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'Consignments',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Live Alerts Monitor',
            icon: const Icon(Icons.campaign_rounded, color: AppColors.brandRed, size: 22),
            onPressed: () => context.push(AppConstants.routeConsignmentMonitor),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.white, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Sticky search + filter header ─────────────────────
          Container(
            color: AppColors.darkBg,
            child: Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 10),
                _buildFilterPills(),
                const SizedBox(height: 12),
                _buildSummaryStrip(filtered),
                const SizedBox(height: 4),
              ],
            ),
          ),
          // ── List ──────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty ? _buildEmpty() : _buildList(filtered),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCTA(),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────
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
            hintText: 'Search by name, client or ID...',
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

  // ── Filter pills ────────────────────────────────────────────────
  Widget _buildFilterPills() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip(null, 'All', AppColors.brandBlue),
          ...ConsignmentStatus.values.map(
            (s) => _filterChip(s, s.label, _statusColor(s)),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(ConsignmentStatus? status, String label, Color color) {
    final selected = _filter == status;
    final count = status == null
        ? MockDataService.consignments.length
        : MockDataService.consignments.where((c) => c.status == status).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = status),
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
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.darkSurface,
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

  // ── Summary strip ───────────────────────────────────────────────
  Widget _buildSummaryStrip(List<ConsignmentModel> filtered) {
    final delayed = MockDataService.consignments
        .where((c) => c.status == ConsignmentStatus.delayed)
        .length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${filtered.length} shipment${filtered.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral300,
            ),
          ),
          if (delayed > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.brandRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.brandRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 11, color: AppColors.brandRed),
                  const SizedBox(width: 4),
                  Text(
                    '$delayed delayed',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          Text(
            'Sorted by ETA',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.swap_vert_rounded, size: 14, color: AppColors.neutral500),
        ],
      ),
    );
  }

  // ── List ────────────────────────────────────────────────────────
  Widget _buildList(List<ConsignmentModel> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildCard(filtered[i]),
    );
  }

  Widget _buildCard(ConsignmentModel c) {
    final statusColor = _statusColor(c.status);
    final priorityColor = _priorityColor(c.priority);
    final isDelayed = c.status == ConsignmentStatus.delayed;
    final progressPct = (c.progress * 100).round();

    return GestureDetector(
      onTap: () => context.go('${AppConstants.routeConsignments}/detail/${c.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDelayed
                ? AppColors.brandRed.withValues(alpha: 0.3)
                : AppColors.darkBorder,
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
                // ── Left status accent bar ──────────────────────
                Container(width: 4, color: statusColor),
                // ── Card content ────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: ID + priority + status + chevron
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.brandBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c.id,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: priorityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                c.priority.label.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: priorityColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Status pill with icon
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon(c.status), size: 11, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    c.status.label,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.neutral500,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Row 2: Name + client
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.business_rounded, size: 12, color: AppColors.neutral500),
                            const SizedBox(width: 4),
                            Text(
                              c.clientName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Row 3: Route origin → destination
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.brandBlue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  c.source,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral300,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.east_rounded,
                                  size: 14,
                                  color: AppColors.neutral500,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  c.destination,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral300,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.brandRed,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Row 4: Progress bar + percentage
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: c.progress,
                                  backgroundColor: AppColors.darkSurface,
                                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$progressPct%',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Row 5: Metadata chips + ETA
                        Row(
                          children: [
                            _metaChip(Icons.local_shipping_rounded, '${c.truckIds.length} Trucks'),
                            const SizedBox(width: 6),
                            _metaChip(Icons.scale_outlined, '${c.weightTons}T'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDelayed
                                    ? AppColors.brandRed.withValues(alpha: 0.08)
                                    : AppColors.darkSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDelayed
                                      ? AppColors.brandRed.withValues(alpha: 0.2)
                                      : AppColors.darkBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isDelayed
                                        ? Icons.warning_amber_rounded
                                        : Icons.schedule_rounded,
                                    size: 12,
                                    color: isDelayed
                                        ? AppColors.brandRed
                                        : AppColors.neutral400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ETA ${c.eta}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDelayed
                                          ? AppColors.brandRed
                                          : AppColors.neutral300,
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
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

  // ── Empty state ─────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandBlue.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Shipments Found',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term\nor clear the active filter.',
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
                  _filter = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Clear Filters',
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
      ),
    );
  }

  // ── Bottom CTA bar ──────────────────────────────────────────────
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
        onTap: () => context.go('${AppConstants.routeConsignments}/create'),
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
                'New Shipment',
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

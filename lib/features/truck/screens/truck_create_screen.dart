import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';

class TruckCreateScreen extends StatefulWidget {
  const TruckCreateScreen({super.key});
  @override
  State<TruckCreateScreen> createState() => _TruckCreateScreenState();
}

class _TruckCreateScreenState extends State<TruckCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _driverCtrl = TextEditingController();

  String _group = 'Own Fleet';
  String _type = 'Container';
  bool _isSaving = false;

  final _groups = ['Own Fleet', 'Lease Truck', 'Rented Truck'];
  final _types = ['Container', 'Flatbed', 'Tanker', 'Tipper', 'Refrigerated'];

  @override
  void dispose() {
    _regCtrl.dispose();
    _capacityCtrl.dispose();
    _driverCtrl.dispose();
    super.dispose();
  }

  IconData _truckIcon(String type) {
    switch (type) {
      case 'Tanker':       return Icons.water_drop_rounded;
      case 'Tipper':       return Icons.construction_rounded;
      case 'Refrigerated': return Icons.ac_unit_rounded;
      case 'Flatbed':      return Icons.straighten_rounded;
      default:             return Icons.local_shipping_rounded;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              '${_regCtrl.text} added to fleet!',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: EazeAppBar(
        title: 'Add Truck',
        showBack: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Vehicle Identity ──────────────────
              _sectionHeader(
                icon: Icons.badge_rounded,
                label: 'Vehicle Identity',
              ),
              const SizedBox(height: 14),

              // Registration Number
              _buildField(
                label: 'Registration Number',
                controller: _regCtrl,
                hint: 'e.g. AP 09 AB 1234',
                icon: Icons.confirmation_number_rounded,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Registration number is required'
                    : null,
              ),

              // Capacity
              _buildField(
                label: 'Payload Capacity',
                controller: _capacityCtrl,
                hint: 'e.g. 20',
                icon: Icons.scale_rounded,
                suffix: 'Tons',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Capacity is required'
                    : null,
              ),

              const SizedBox(height: 20),

              // ── Section 2: Fleet Classification ──────────────
              _sectionHeader(
                icon: Icons.category_rounded,
                label: 'Fleet Classification',
              ),
              const SizedBox(height: 14),

              // Ownership Group
              _buildLabel('Ownership Group'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _groups.map((g) {
                  final sel = _group == g;
                  return GestureDetector(
                    onTap: () => setState(() => _group = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.brandBlue : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? AppColors.brandBlue : AppColors.darkBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        g,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.neutral400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Truck Type visual selector
              _buildLabel('Vehicle Type'),
              const SizedBox(height: 10),
              SizedBox(
                height: 88,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _types.map((t) {
                    final sel = _type == t;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 80,
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.brandBlue.withValues(alpha: 0.1)
                                : AppColors.darkCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: sel ? AppColors.brandBlue : AppColors.darkBorder,
                              width: sel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _truckIcon(t),
                                color: sel ? AppColors.brandBlue : AppColors.neutral400,
                                size: 26,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                t,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? AppColors.brandBlue : AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // ── Section 3: Tracking ──────────────────────────
              _sectionHeader(
                icon: Icons.gps_fixed_rounded,
                label: 'Tracking',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone_android_rounded,
                        color: AppColors.brandBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mobile-based Tracking',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'GPS location is tracked via the driver\'s mobile app. No hardware device required.',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.neutral400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                      ),
                      child: const Text(
                        'AUTO',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Summary Card before submit ────────────────────
              if (_regCtrl.text.isNotEmpty || _capacityCtrl.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brandBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preview',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(_truckIcon(_type), color: AppColors.brandBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _regCtrl.text.isNotEmpty ? _regCtrl.text.toUpperCase() : '—',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_type · $_group${_capacityCtrl.text.isNotEmpty ? ' · ${_capacityCtrl.text}T' : ''}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: AppColors.neutral400,
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          border: Border(top: BorderSide(color: AppColors.darkBorder)),
        ),
        child: GestureDetector(
          onTap: _isSaving ? null : _save,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _isSaving
                  ? AppColors.brandBlue.withValues(alpha: 0.6)
                  : AppColors.brandBlue,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandBlue.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  _isSaving ? 'Saving...' : 'Add to Fleet',
                  style: const TextStyle(
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
      ),
    );
  }

  Widget _sectionHeader({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.brandBlue),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral300,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? suffix,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            validator: validator,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.neutral500,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(icon, color: AppColors.neutral400, size: 18),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.neutral400,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: AppColors.darkCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brandBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brandRed),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.brandRed, width: 2),
              ),
              errorStyle: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.brandRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

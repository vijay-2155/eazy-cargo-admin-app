import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eaze_my_cargo/core/theme/app_theme.dart';
import 'package:eaze_my_cargo/core/widgets/brand_logo.dart';

class DriverCreateScreen extends StatefulWidget {
  const DriverCreateScreen({super.key});
  @override
  State<DriverCreateScreen> createState() => _DriverCreateScreenState();
}

class _DriverCreateScreenState extends State<DriverCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _licCtrl     = TextEditingController();
  final _licExpCtrl  = TextEditingController();
  String _shift = 'Day';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _licCtrl.dispose();
    _licExpCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
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
              '${_nameCtrl.text} registered!',
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
      appBar: EazeAppBar(title: 'Add Driver', showBack: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Live Avatar Hero ─────────────────────────────
              Center(
                child: Column(
                  children: [
                    // Animated initial avatar that updates as user types name
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _nameCtrl.text.isEmpty
                            ? AppColors.darkCard
                            : AppColors.brandBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _nameCtrl.text.isEmpty
                              ? AppColors.darkBorder
                              : AppColors.brandBlue.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _nameCtrl.text.isEmpty
                            ? const Icon(
                                Icons.person_outline_rounded,
                                size: 38,
                                color: AppColors.neutral500,
                              )
                            : Text(
                                _initials,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandBlue,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _nameCtrl.text.isEmpty ? 'New Driver' : _nameCtrl.text.trim(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _nameCtrl.text.isEmpty
                            ? AppColors.neutral500
                            : AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Fleet Driver',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Section 1: Personal Details ──────────────────
              _sectionHeader(icon: Icons.person_rounded, label: 'Personal Details'),
              const SizedBox(height: 14),

              _buildField(
                label: 'Full Name',
                controller: _nameCtrl,
                hint: 'e.g. Ravi Kumar Reddy',
                icon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),

              _buildField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                hint: '+91 98765 43210',
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                  LengthLimitingTextInputFormatter(14),
                ],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Phone number is required'
                    : null,
              ),

              const SizedBox(height: 20),

              // ── Section 2: License ───────────────────────────
              _sectionHeader(icon: Icons.card_membership_rounded, label: 'License Details'),
              const SizedBox(height: 14),

              _buildField(
                label: 'License Number',
                controller: _licCtrl,
                hint: 'e.g. AP2012 0034567',
                icon: Icons.verified_rounded,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'License number is required'
                    : null,
              ),

              _buildField(
                label: 'License Expiry Date',
                controller: _licExpCtrl,
                hint: 'MM / YYYY',
                icon: Icons.calendar_today_rounded,
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  LengthLimitingTextInputFormatter(7),
                ],
              ),

              const SizedBox(height: 20),

              // ── Section 3: Shift Preference ──────────────────
              _sectionHeader(icon: Icons.schedule_rounded, label: 'Shift Preference'),
              const SizedBox(height: 14),

              Row(
                children: [
                  _shiftCard('Day',      Icons.wb_sunny_rounded,    const Color(0xFFD97706)),
                  const SizedBox(width: 10),
                  _shiftCard('Night',    Icons.nightlight_rounded,  AppColors.brandBlue),
                  const SizedBox(width: 10),
                  _shiftCard('Rotating', Icons.loop_rounded,        AppColors.success),
                ],
              ),

              const SizedBox(height: 28),

              // ── Live Preview Card ─────────────────────────────
              if (_nameCtrl.text.isNotEmpty || _phoneCtrl.text.isNotEmpty) ...[
                _sectionHeader(icon: Icons.preview_rounded, label: 'Preview'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      // Mini avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brandBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameCtrl.text.isNotEmpty ? _nameCtrl.text : '—',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (_phoneCtrl.text.isNotEmpty)
                              Text(
                                _phoneCtrl.text,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: AppColors.neutral400,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Status pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'AVAILABLE',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.success,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Shift tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSurface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.darkBorder),
                                  ),
                                  child: Text(
                                    '$_shift Shift',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.neutral400,
                                    ),
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
              ],
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
                  const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  _isSaving ? 'Registering...' : 'Register Driver',
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

  // ── Shift Card ───────────────────────────────────────────────────
  Widget _shiftCard(String shift, IconData icon, Color color) {
    final sel = _shift == shift;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _shift = shift),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sel ? color.withValues(alpha: 0.1) : AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: sel ? color : AppColors.darkBorder,
              width: sel ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: sel ? color : AppColors.neutral500, size: 22),
              const SizedBox(height: 6),
              Text(
                shift,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: sel ? color : AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────
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

  // ── Form Field ───────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
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
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral300,
            ),
          ),
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

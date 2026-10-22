import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../farmer/farmer_home_shell.dart';
import '../worker/worker_home_shell.dart';

enum _Step { phone, otp, register }

const _skillOptions = [
  'Koleroga',
  'Bud Rot',
  'Yellow Leaf Disease',
  'Fruit Rot',
  'Anthracnose',
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _Step _step = _Step.phone;
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '800');
  UserRole _role = UserRole.farmer;
  final Set<String> _selectedSkills = {};
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_phoneCtrl.text.trim().length < 10) {
      setState(() => _error = 'Enter a valid 10-digit phone number.');
      return;
    }
    _goToStep(_Step.otp);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo OTP sent — enter 1234 to continue.')),
    );
  }

  /// Moves to another step, dropping focus first so the platform keyboard
  /// connection is torn down rather than carried over with the old input type.
  void _goToStep(_Step step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _step = step;
    });
  }

  void _verifyOtp() {
    if (_otpCtrl.text.trim() != '1234') {
      setState(() => _error = 'Incorrect OTP. Use 1234 for this demo.');
      return;
    }
    final appState = context.read<AppState>();
    final existing = appState.findUserByPhone(_phoneCtrl.text.trim());
    if (existing != null) {
      _completeLogin(existing.role);
    } else {
      _goToStep(_Step.register);
    }
  }

  void _submitRegistration() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (_role == UserRole.worker && _selectedSkills.isEmpty) {
      setState(() => _error = 'Select at least one specialization.');
      return;
    }
    final appState = context.read<AppState>();
    appState.register(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _role,
      workerSkills: _selectedSkills.toList(),
      dailyRate: int.tryParse(_rateCtrl.text.trim()) ?? 800,
    );
    _completeLogin(_role);
  }

  void _completeLogin(UserRole role) {
    setState(() => _busy = true);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => role == UserRole.farmer ? const FarmerHomeShell() : const WorkerHomeShell(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AgriCare',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _headline,
                style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 28),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFF991B1B))),
                ),
              ],
              ..._buildStepFields(),
            ],
          ),
        ),
      ),
    );
  }

  String get _headline {
    switch (_step) {
      case _Step.phone:
        return 'Login or create an account with your phone number.';
      case _Step.otp:
        return 'Enter the OTP sent to ${_phoneCtrl.text}.';
      case _Step.register:
        return "You're new here — tell us a bit about yourself.";
    }
  }

  List<Widget> _buildStepFields() {
    switch (_step) {
      case _Step.phone:
        return [
          TextField(
            // Distinct keys stop Flutter reusing one TextField element across
            // steps, which would otherwise keep the previous step's keyboard
            // type on screen (numeric keypad carried into the name field).
            key: const ValueKey('field-phone'),
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_android_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sendOtp,
            style: FilledButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ];
      case _Step.otp:
        return [
          TextField(
            key: const ValueKey('field-otp'),
            controller: _otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(
              labelText: 'OTP (use 1234)',
              prefixIcon: Icon(Icons.lock_outline_rounded),
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _verifyOtp,
            style: FilledButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Verify & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => _goToStep(_Step.phone),
            child: const Text('Change phone number'),
          ),
        ];
      case _Step.register:
        return [
          TextField(
            key: const ValueKey('field-name'),
            controller: _nameCtrl,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          const Text('I am a', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _RoleChip(
                  label: 'Farmer',
                  icon: Icons.grass_rounded,
                  selected: _role == UserRole.farmer,
                  onTap: () => setState(() => _role = UserRole.farmer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleChip(
                  label: 'Spray Worker',
                  icon: Icons.engineering_rounded,
                  selected: _role == UserRole.worker,
                  onTap: () => setState(() => _role = UserRole.worker),
                ),
              ),
            ],
          ),
          if (_role == UserRole.worker) ...[
            const SizedBox(height: 20),
            const Text('Specializations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skillOptions.map((s) {
                final selected = _selectedSkills.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedSkills.add(s);
                    } else {
                      _selectedSkills.remove(s);
                    }
                  }),
                  selectedColor: const Color(0xFFDCFCE7),
                  checkmarkColor: primaryGreen,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('field-rate'),
              controller: _rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Rate (₹)',
                prefixIcon: Icon(Icons.currency_rupee_rounded),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submitRegistration,
            style: FilledButton.styleFrom(
              backgroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Create Account & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ];
    }
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDCFCE7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primaryGreen : borderSlate, width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primaryGreen : const Color(0xFF64748B)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? primaryGreen : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

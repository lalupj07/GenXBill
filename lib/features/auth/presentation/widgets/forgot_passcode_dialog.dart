import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';

class ForgotPasscodeDialog extends ConsumerStatefulWidget {
  const ForgotPasscodeDialog({super.key});

  @override
  ConsumerState<ForgotPasscodeDialog> createState() =>
      _ForgotPasscodeDialogState();
}

class _ForgotPasscodeDialogState extends ConsumerState<ForgotPasscodeDialog> {
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isVerifying = false;

  final List<String> _newPasscode = [];
  final List<String> _confirmPasscode = [];
  int _step = 1; // 1: Verify, 2: New Passcode, 3: Confirm
  bool _isError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyIdentity() async {
    setState(() {
      _isVerifying = true;
      _isError = false;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    final settings = ref.read(settingsProvider);
    final companyName = _companyNameController.text.trim();
    final email = _emailController.text.trim();

    // Verify against stored settings
    if (companyName.toLowerCase() == settings.companyName.toLowerCase() &&
        email.toLowerCase() == settings.companyEmail.toLowerCase()) {
      setState(() {
        _isVerifying = false;
        _step = 2;
      });
    } else {
      setState(() {
        _isVerifying = false;
        _isError = true;
        _errorMessage = 'Company name or email does not match our records';
      });
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      _isError = false;
      _errorMessage = '';

      if (_step == 2 && _newPasscode.length < 4) {
        _newPasscode.add(number);
        if (_newPasscode.length == 4) {
          _step = 3;
        }
      } else if (_step == 3 && _confirmPasscode.length < 4) {
        _confirmPasscode.add(number);
        if (_confirmPasscode.length == 4) {
          _verifyNewPasscode();
        }
      }
    });
  }

  void _onBackspacePressed() {
    setState(() {
      _isError = false;
      _errorMessage = '';

      if (_step == 2 && _newPasscode.isNotEmpty) {
        _newPasscode.removeLast();
      } else if (_step == 3 && _confirmPasscode.isNotEmpty) {
        _confirmPasscode.removeLast();
      }
    });
  }

  Future<void> _verifyNewPasscode() async {
    final newCode = _newPasscode.join();
    final confirmCode = _confirmPasscode.join();

    await Future.delayed(const Duration(milliseconds: 300));

    if (newCode == confirmCode) {
      // Save new passcode
      ref.read(settingsProvider.notifier).updateSecuritySettings(
            passcode: newCode,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passcode reset successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() {
        _isError = true;
        _errorMessage = 'Passcodes do not match';
        _confirmPasscode.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Forgot Passcode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_step == 1) _buildVerificationStep(),
              if (_step == 2 || _step == 3) _buildPasscodeStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lock_reset,
          size: 60,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        const Text(
          'Verify Your Identity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your company details to reset your passcode',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Company Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        if (_isError)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyIdentity,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify & Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasscodeStep() {
    final title = _step == 2 ? 'Enter New Passcode' : 'Confirm New Passcode';
    final currentList = _step == 2 ? _newPasscode : _confirmPasscode;

    return Column(
      children: [
        // Step Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepIndicator(1, true),
            Container(width: 40, height: 2, color: Colors.green),
            _buildStepIndicator(2, _step >= 2),
            Container(
              width: 40,
              height: 2,
              color: _step >= 3
                  ? Colors.green
                  : Colors.grey.withValues(alpha: 0.3),
            ),
            _buildStepIndicator(3, _step >= 3),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),

        // Passcode Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            final isFilled = index < currentList.length;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isError
                      ? Colors.red
                      : isFilled
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                  border: Border.all(
                    color: _isError
                        ? Colors.red
                        : isFilled
                            ? AppTheme.primaryColor
                            : Colors.white38,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Error Message
        SizedBox(
          height: 20,
          child: _isError
              ? Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                )
              : const SizedBox(),
        ),
        const SizedBox(height: 24),

        // Number Pad
        _buildNumberPad(),
      ],
    );
  }

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.grey.withValues(alpha: 0.3),
      ),
      child: Center(
        child: isActive
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                '$step',
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        const SizedBox(height: 12),
        _buildNumberRow(['4', '5', '6']),
        const SizedBox(height: 12),
        _buildNumberRow(['7', '8', '9']),
        const SizedBox(height: 12),
        _buildNumberRow(['', '0', 'back']),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 60, height: 60);
        }

        if (number == 'back') {
          return _buildNumberButton(
            child: const Icon(Icons.backspace_outlined, size: 20),
            onPressed: _onBackspacePressed,
          );
        }

        return _buildNumberButton(
          child: Text(
            number,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          onPressed: () => _onNumberPressed(number),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton({
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

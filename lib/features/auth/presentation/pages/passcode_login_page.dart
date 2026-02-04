import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/widgets/main_layout.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';
import 'package:genx_bill/features/auth/presentation/widgets/forgot_passcode_dialog.dart';

class PasscodeLoginPage extends ConsumerStatefulWidget {
  const PasscodeLoginPage({super.key});

  @override
  ConsumerState<PasscodeLoginPage> createState() => _PasscodeLoginPageState();
}

class _PasscodeLoginPageState extends ConsumerState<PasscodeLoginPage>
    with SingleTickerProviderStateMixin {
  final List<String> _enteredPasscode = [];
  final int _passcodeLength = 4;
  bool _isError = false;
  bool _isSuccess = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPasscode.length < _passcodeLength) {
      setState(() {
        _enteredPasscode.add(number);
        _isError = false;
      });

      if (_enteredPasscode.length == _passcodeLength) {
        _verifyPasscode();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPasscode.isNotEmpty) {
      setState(() {
        _enteredPasscode.removeLast();
        _isError = false;
      });
    }
  }

  Future<void> _verifyPasscode() async {
    final settings = ref.read(settingsProvider);
    final enteredCode = _enteredPasscode.join();

    // Default passcode is "1234" - can be configured in settings
    final correctPasscode = settings.passcode ?? "1234";

    await Future.delayed(const Duration(milliseconds: 300));

    if (enteredCode == correctPasscode) {
      setState(() => _isSuccess = true);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      }
    } else {
      setState(() => _isError = true);
      _shakeController.forward(from: 0);

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _enteredPasscode.clear();
        _isError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.backgroundColor.withValues(alpha: 0.8),
              AppTheme.primaryColor.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo and Title
                  _buildHeader(),

                  const SizedBox(height: 40),

                  // Passcode Dots
                  _buildPasscodeDots(),

                  const SizedBox(height: 10),

                  // Error/Success Message
                  _buildMessage(),

                  const SizedBox(height: 40),

                  // Number Pad
                  _buildNumberPad(),

                  const SizedBox(height: 20),

                  // Forgot Passcode Link
                  TextButton(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => const ForgotPasscodeDialog(),
                      );

                      if (result == true && mounted) {
                        // Passcode was reset successfully
                        setState(() {
                          _enteredPasscode.clear();
                          _isError = false;
                        });
                      }
                    },
                    child: const Text(
                      'Forgot Passcode?',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.3),
                AppTheme.secondaryColor.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 60,
            color: Colors.white,
          ),
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(delay: 200.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        const Text(
          'Enter Passcode',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        const Text(
          'Enter your 4-digit passcode',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildPasscodeDots() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = _shakeController.value *
            10 *
            (1 - _shakeController.value) *
            (_shakeController.value < 0.5 ? 1 : -1);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_passcodeLength, (index) {
          final isFilled = index < _enteredPasscode.length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isError
                    ? Colors.red
                    : _isSuccess
                        ? Colors.green
                        : isFilled
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                border: Border.all(
                  color: _isError
                      ? Colors.red
                      : _isSuccess
                          ? Colors.green
                          : isFilled
                              ? AppTheme.primaryColor
                              : Colors.white38,
                  width: 2,
                ),
              ),
            ).animate(key: ValueKey('dot_$index')).scale(
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                ),
          );
        }),
      ),
    );
  }

  Widget _buildMessage() {
    return SizedBox(
      height: 30,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isError
            ? const Text(
                'Incorrect passcode. Try again.',
                key: ValueKey('error'),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().shake()
            : _isSuccess
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Success!',
                        key: ValueKey('success'),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ).animate().fadeIn().scale()
                : const SizedBox(key: ValueKey('empty')),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumberRow(['1', '2', '3']),
          const SizedBox(height: 20),
          _buildNumberRow(['4', '5', '6']),
          const SizedBox(height: 20),
          _buildNumberRow(['7', '8', '9']),
          const SizedBox(height: 20),
          _buildNumberRow(['', '0', 'back']),
        ],
      ),
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 75, height: 75);
        }

        if (number == 'back') {
          return _buildNumberButton(
            child: const Icon(Icons.backspace_outlined, color: Colors.white),
            onPressed: _onBackspacePressed,
          );
        }

        return _buildNumberButton(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
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
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Center(child: child),
        ),
      ),
    ).animate().fadeIn(delay: 800.ms).scale(delay: 800.ms);
  }
}

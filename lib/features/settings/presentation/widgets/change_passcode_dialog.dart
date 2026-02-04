import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genx_bill/core/theme/app_theme.dart';
import 'package:genx_bill/core/providers/settings_provider.dart';

class ChangePasscodeDialog extends ConsumerStatefulWidget {
  const ChangePasscodeDialog({super.key});

  @override
  ConsumerState<ChangePasscodeDialog> createState() =>
      _ChangePasscodeDialogState();
}

class _ChangePasscodeDialogState extends ConsumerState<ChangePasscodeDialog> {
  final List<String> _currentPasscode = [];
  final List<String> _newPasscode = [];
  final List<String> _confirmPasscode = [];

  int _step = 1; // 1: Current, 2: New, 3: Confirm
  bool _isError = false;
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    setState(() {
      _isError = false;
      _errorMessage = '';

      if (_step == 1 && _currentPasscode.length < 4) {
        _currentPasscode.add(number);
        if (_currentPasscode.length == 4) {
          _verifyCurrentPasscode();
        }
      } else if (_step == 2 && _newPasscode.length < 4) {
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

      if (_step == 1 && _currentPasscode.isNotEmpty) {
        _currentPasscode.removeLast();
      } else if (_step == 2 && _newPasscode.isNotEmpty) {
        _newPasscode.removeLast();
      } else if (_step == 3 && _confirmPasscode.isNotEmpty) {
        _confirmPasscode.removeLast();
      }
    });
  }

  Future<void> _verifyCurrentPasscode() async {
    final settings = ref.read(settingsProvider);
    final currentCode = _currentPasscode.join();
    final correctPasscode = settings.passcode ?? "1234";

    await Future.delayed(const Duration(milliseconds: 300));

    if (currentCode == correctPasscode) {
      setState(() => _step = 2);
    } else {
      setState(() {
        _isError = true;
        _errorMessage = 'Incorrect current passcode';
        _currentPasscode.clear();
      });
    }
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
          const SnackBar(content: Text('Passcode changed successfully!')),
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

  String _getTitle() {
    switch (_step) {
      case 1:
        return 'Enter Current Passcode';
      case 2:
        return 'Enter New Passcode';
      case 3:
        return 'Confirm New Passcode';
      default:
        return '';
    }
  }

  List<String> _getCurrentList() {
    switch (_step) {
      case 1:
        return _currentPasscode;
      case 2:
        return _newPasscode;
      case 3:
        return _confirmPasscode;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Passcode',
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

            // Step Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isActive = index + 1 == _step;
                final isCompleted = index + 1 < _step;
                return Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Colors.green
                            : isActive
                                ? AppTheme.primaryColor
                                : Colors.grey.withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index < 2)
                      Container(
                        width: 40,
                        height: 2,
                        color: isCompleted
                            ? Colors.green
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              _getTitle(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // Passcode Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _getCurrentList().length;
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

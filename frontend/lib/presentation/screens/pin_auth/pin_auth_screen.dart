import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/auth_provider.dart';

class PinAuthScreen extends ConsumerStatefulWidget {
  final String profileName;

  const PinAuthScreen({super.key, required this.profileName});

  @override
  ConsumerState<PinAuthScreen> createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends ConsumerState<PinAuthScreen> {
  final List<String> _pin = [];
  final int _pinLength = 4;
  bool _isLoading = false;
  String? _error;

  void _onNumberTap(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(number);
        _error = null;
      });

      if (_pin.length == _pinLength) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _error = null;
      });
    }
  }

  Future<void> _submitPin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final pinStr = _pin.join();

    final success = await ref.read(authStateProvider.notifier).login(widget.profileName, pinStr);

    if (success && mounted) {
      context.go('/conversations');
    } else if (mounted) {
      setState(() {
        _isLoading = false;
        _error = 'PIN이 올바르지 않습니다';
        _pin.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('PIN 인증'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                'PIN 번호를 입력하세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              // Number pad
              _NumberPad(
                onNumberTap: _onNumberTap,
                onBackspace: _onBackspace,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  final void Function(String) onNumberTap;
  final VoidCallback onBackspace;
  final bool enabled;

  const _NumberPad({
    required this.onNumberTap,
    required this.onBackspace,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((number) {
          return _NumberButton(
            text: number,
            onTap: () => enabled ? onNumberTap(number) : null,
          );
        }),
        const SizedBox(), // Empty space
        _NumberButton(
          text: '0',
          onTap: () => enabled ? onNumberTap('0') : null,
        ),
        _NumberButton(
          icon: Icons.backspace_outlined,
          onTap: enabled ? onBackspace : null,
        ),
      ],
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;

  const _NumberButton({
    this.text,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: text != null
              ? Text(
                  text!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Icon(icon, size: 28),
        ),
      ),
    );
  }
}

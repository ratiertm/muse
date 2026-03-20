import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NetworkErrorScreen extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const NetworkErrorScreen({
    super.key,
    this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 100,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              
              Text(
                '서버에 연결할 수 없습니다',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                message ?? '인터넷 연결을 확인하거나\n서버 설정을 확인해주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: onRetry ?? () {
                      // Default: just pop back
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('재시도'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push('/settings');
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('서버 설정'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

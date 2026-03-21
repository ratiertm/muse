import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/persona_provider.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final personasAsync = ref.watch(personaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // Profile Card
          _buildProfileCard(context, ref),

          // === 내 페르소나 섹션 (인라인) ===
          _buildSectionHeader(context, '내 페르소나'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '대화할 때 나를 어떻게 소개할지 설정해요',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          personasAsync.when(
            data: (personas) {
              return Column(
                children: [
                  ...personas.map((persona) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: persona.isDefault
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Text(
                        persona.name[0],
                        style: TextStyle(
                          color: persona.isDefault
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(persona.name),
                        if (persona.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '기본',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: persona.personality != null
                        ? Text(persona.personality!, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () async {
                      await context.push('/profile/personas/edit/${persona.id}');
                      ref.invalidate(personaListProvider);
                    },
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await context.push('/profile/personas/create');
                        ref.invalidate(personaListProvider);
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('새 페르소나 만들기'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('페르소나 로딩 실패: $e'),
            ),
          ),

          const Divider(height: 32),

          // === 앱 설정 ===
          _buildSectionHeader(context, '앱 설정'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('테마'),
            subtitle: Text(_getThemeName(themeMode)),
            onTap: () => _showThemeDialog(context, ref, themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('서버 URL'),
            subtitle: Text(AppConstants.baseUrl),
            onTap: () => _showServerUrlDialog(context, ref),
          ),

          const Divider(height: 32),

          // === 계정 ===
          _buildSectionHeader(context, '계정'),
          ListTile(
            leading: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
            title: const Text('프로필 전환'),
            subtitle: const Text('다른 사용자로 로그인'),
            onTap: () => _switchProfile(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context, ref),
          ),

          const Divider(height: 32),

          // About
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Muse'),
            subtitle: Text('v1.0.0 - AI Character Chat'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        final userName = prefs?.getString(AppConstants.keyUserName) ?? '사용자';

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeName(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (m) {
                if (m != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(m);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showServerUrlDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: AppConstants.baseUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서버 URL 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Server URL',
            hintText: 'http://your-server-ip:8000',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              await ref.read(serverUrlProvider.notifier).setServerUrl(controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                SnackbarUtils.showSuccess(context, 'URL이 변경되었습니다. 앱을 재시작하세요.');
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  Future<void> _switchProfile(BuildContext context, WidgetRef ref) async {
    await ref.read(authStateProvider.notifier).logout();
    if (context.mounted) {
      context.go('/profile-selection');
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        context.go('/profile-selection');
      }
    }
  }
}

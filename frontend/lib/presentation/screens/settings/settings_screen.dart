import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers/auth_provider.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme_mode') ?? 'system';
    state = ThemeMode.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => ThemeMode.system,
    );
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    state = mode;
  }
}

// Server URL provider
final serverUrlProvider = StateNotifierProvider<ServerUrlNotifier, String>((ref) {
  return ServerUrlNotifier();
});

class ServerUrlNotifier extends StateNotifier<String> {
  ServerUrlNotifier() : super(AppConstants.baseUrl) {
    _loadServerUrl();
  }
  
  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('server_url') ?? AppConstants.baseUrl;
    state = url;
  }
  
  Future<void> setServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
    state = url;
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _serverUrlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _serverUrlController.text = AppConstants.baseUrl;
  }
  
  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // Theme Section
          _buildSectionHeader('테마'),
          _buildThemeTile(context, themeMode),
          
          const Divider(),
          
          // Server Section
          _buildSectionHeader('서버'),
          _buildServerUrlTile(context),
          
          const Divider(),
          
          // Account Section
          _buildSectionHeader('계정'),
          _buildLogoutTile(context),
          
          const Divider(),
          
          // About Section
          _buildSectionHeader('앱 정보'),
          _buildAboutTiles(),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildThemeTile(BuildContext context, ThemeMode currentMode) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('테마'),
      subtitle: Text(_getThemeName(currentMode)),
      onTap: () => _showThemeDialog(context, currentMode),
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
  
  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('라이트'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  Navigator.of(context).pop();
                  SnackbarUtils.showSuccess(context, '테마가 변경되었습니다');
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  Navigator.of(context).pop();
                  SnackbarUtils.showSuccess(context, '테마가 변경되었습니다');
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                  Navigator.of(context).pop();
                  SnackbarUtils.showSuccess(context, '테마가 변경되었습니다');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServerUrlTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: const Text('서버 URL'),
      subtitle: Text(AppConstants.baseUrl),
      onTap: () => _showServerUrlDialog(context),
    );
  }
  
  void _showServerUrlDialog(BuildContext context) {
    _serverUrlController.text = AppConstants.baseUrl;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서버 URL 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://your-server-ip:8000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            const Text(
              '앱을 재시작해야 변경사항이 적용됩니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              final url = _serverUrlController.text.trim();
              if (url.isEmpty) {
                SnackbarUtils.showError(context, 'URL을 입력해주세요');
                return;
              }
              
              await ref.read(serverUrlProvider.notifier).setServerUrl(url);
              if (context.mounted) {
                Navigator.of(context).pop();
                SnackbarUtils.showSuccess(context, 'URL이 변경되었습니다');
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('로그아웃'),
      onTap: () => _logout(context),
    );
  }
  
  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/profiles');
        SnackbarUtils.showSuccess(context, '로그아웃되었습니다');
      }
    }
  }
  
  Widget _buildAboutTiles() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('버전'),
          subtitle: const Text('1.0.0+1'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('제작'),
          subtitle: const Text('Muse Team'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('라이선스'),
          subtitle: const Text('MIT License'),
          onTap: () {
            showLicensePage(context: context);
          },
        ),
      ],
    );
  }
}

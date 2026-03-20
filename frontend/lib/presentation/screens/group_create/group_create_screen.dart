import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scenario.dart';
import '../../../data/models/character.dart';
import '../../../data/providers/scenario_provider.dart';
import '../../../data/providers/group_chat_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/scenario_repository.dart';

class GroupCreateScreen extends ConsumerStatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  ConsumerState<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends ConsumerState<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  Scenario? _selectedScenario;
  List<Character> _availableCharacters = [];
  final List<String> _selectedCharacterIds = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadScenarioCharacters(String scenarioId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = ScenarioRepository(apiClient);

      final characters = await repository.getScenarioCharacters(scenarioId);

      setState(() {
        _availableCharacters = characters;
        _selectedCharacterIds.clear();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('캐릭터 로딩 실패: $e')),
      );
    }
  }

  Future<void> _createGroupChat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedScenario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시나리오를 선택하세요')),
      );
      return;
    }

    if (_selectedCharacterIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 2명의 캐릭터를 선택하세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(groupChatRepositoryProvider);

      final conversation = await repository.createGroupChat(
        scenarioId: _selectedScenario!.id,
        characterIds: _selectedCharacterIds,
        title: _titleController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 채팅이 생성되었습니다')),
      );

      context.go('/group-chat/${conversation.id}');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('생성 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 채팅 만들기'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroupChat,
            child: const Text('시작'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '그룹 제목 *',
                hintText: '예: 학교 친구들',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text(
              '시나리오 선택 *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            scenariosAsync.when(
              data: (scenarios) {
                if (scenarios.isEmpty) {
                  return const Text('시나리오가 없습니다. 먼저 시나리오를 만드세요.');
                }

                return Column(
                  children: scenarios.map((scenario) {
                    return RadioListTile<Scenario>(
                      title: Text(scenario.name),
                      subtitle: Text(scenario.description),
                      value: scenario,
                      groupValue: _selectedScenario,
                      onChanged: (value) {
                        setState(() {
                          _selectedScenario = value;
                        });
                        if (value != null) {
                          _loadScenarioCharacters(value.id);
                        }
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('오류: $error'),
            ),
            const SizedBox(height: 24),
            const Text(
              '캐릭터 선택 (최소 2명) *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_availableCharacters.isEmpty)
              const Text('시나리오를 선택하면 캐릭터가 표시됩니다')
            else
              ..._availableCharacters.map((character) {
                final isSelected = _selectedCharacterIds.contains(character.id);

                return CheckboxListTile(
                  secondary: CircleAvatar(
                    backgroundImage: character.avatarUrl != null
                        ? NetworkImage(character.avatarUrl!)
                        : null,
                    child: character.avatarUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(character.name),
                  subtitle: Text(
                    character.personality,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedCharacterIds.add(character.id);
                      } else {
                        _selectedCharacterIds.remove(character.id);
                      }
                    });
                  },
                );
              }).toList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

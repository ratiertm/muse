import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scenario.dart';
import '../../../data/models/character.dart';
import '../../../data/providers/scenario_provider.dart';
import '../../../data/providers/group_chat_provider.dart';
import '../../../data/models/persona.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/persona_provider.dart';
import '../../../data/repositories/scenario_repository.dart';
import '../../../core/constants/app_constants.dart';

class GroupCreateScreen extends ConsumerStatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  ConsumerState<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends ConsumerState<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  Scenario? _selectedScenario;
  Persona? _selectedPersona;
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
        personaId: _selectedPersona?.id,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 채팅이 생성되었습니다')),
      );

      context.push('/group-chat/${conversation.id}');
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
    final personasAsync = ref.watch(personaListProvider);

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
              '페르소나 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            personasAsync.when(
              data: (personas) {
                return DropdownButtonFormField<Persona>(
                  value: _selectedPersona,
                  hint: const Text('나는 누구로 참여할까?'),
                  isExpanded: true,
                  items: personas.map((persona) {
                    return DropdownMenuItem<Persona>(
                      value: persona,
                      child: Row(
                        children: [
                          Expanded(child: Text(persona.name)),
                          if (persona.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '기본',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPersona = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => Text('페르소나 로딩 실패: $error'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  '스토리와 캐릭터 선택 *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (_selectedCharacterIds.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedCharacterIds.length}명 선택',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            scenariosAsync.when(
              data: (scenarios) {
                if (scenarios.isEmpty) {
                  return const Text('스토리가 없습니다. 먼저 스토리를 만드세요.');
                }

                return Column(
                  children: scenarios.map((scenario) {
                    final isSelected = _selectedScenario?.id == scenario.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                            : BorderSide.none,
                      ),
                      child: Column(
                        children: [
                          // 시나리오 헤더 (탭하여 선택)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _selectedScenario = isSelected ? null : scenario;
                                if (!isSelected) {
                                  _selectedCharacterIds.clear();
                                }
                              });
                              if (!isSelected) {
                                _loadScenarioCharacters(scenario.id);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scenario.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                        if (scenario.description.isNotEmpty)
                                          Text(
                                            scenario.description,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isSelected ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 캐릭터 목록 (선택된 시나리오만 펼침)
                          if (isSelected) ...[
                            const Divider(height: 1),
                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_availableCharacters.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('이 스토리에 캐릭터가 없습니다'),
                              )
                            else
                              ..._availableCharacters.map((character) {
                                final isCharSelected = _selectedCharacterIds.contains(character.id);
                                final avatarUrl = AppConstants.resolveAvatarUrl(character.avatarUrl);

                                return CheckboxListTile(
                                  secondary: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: avatarUrl != null
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl == null
                                        ? Text(character.name[0])
                                        : null,
                                  ),
                                  title: Text(character.name, style: const TextStyle(fontSize: 14)),
                                  dense: true,
                                  value: isCharSelected,
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
                              }),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('오류: $error'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

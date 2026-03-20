import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scenario.dart';
import '../../../data/models/character.dart';
import '../../../data/providers/scenario_provider.dart';
import '../../../data/providers/character_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/scenario_repository.dart';

class ScenarioEditScreen extends ConsumerStatefulWidget {
  final String? scenarioId;

  const ScenarioEditScreen({super.key, this.scenarioId});

  @override
  ConsumerState<ScenarioEditScreen> createState() => _ScenarioEditScreenState();
}

class _ScenarioEditScreenState extends ConsumerState<ScenarioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Character> _scenarioCharacters = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.scenarioId != null) {
      _loadScenario();
    }
  }

  Future<void> _loadScenario() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = ScenarioRepository(apiClient);

      final scenario = await repository.getScenario(widget.scenarioId!);
      final characters = await repository.getScenarioCharacters(widget.scenarioId!);

      setState(() {
        _nameController.text = scenario.name;
        _descriptionController.text = scenario.description;
        _scenarioCharacters = characters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = ScenarioRepository(apiClient);

      if (widget.scenarioId != null) {
        // Update existing scenario
        await repository.updateScenario(
          widget.scenarioId!,
          ScenarioUpdate(
            name: _nameController.text,
            description: _descriptionController.text,
          ),
        );
      } else {
        // Create new scenario
        await repository.createScenario(
          ScenarioCreate(
            name: _nameController.text,
            description: _descriptionController.text,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ref.invalidate(scenarioListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다')),
      );
      context.pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  Future<void> _showAddCharacterDialog() async {
    final allCharactersAsync = await ref.read(characterListProvider.future);

    // Filter out characters already in scenario
    final availableCharacters = allCharactersAsync
        .where((c) => !_scenarioCharacters.any((sc) => sc.id == c.id))
        .toList();

    if (!mounted) return;

    final selected = await showDialog<Character>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐릭터 추가'),
        content: SizedBox(
          width: double.maxFinite,
          child: availableCharacters.isEmpty
              ? const Text('추가할 캐릭터가 없습니다')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableCharacters.length,
                  itemBuilder: (context, index) {
                    final character = availableCharacters[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: character.avatarUrl != null
                            ? NetworkImage(character.avatarUrl!)
                            : null,
                        child: character.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(character.name),
                      onTap: () => Navigator.pop(context, character),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected != null && widget.scenarioId != null) {
      await _addCharacter(selected.id);
    }
  }

  Future<void> _addCharacter(String characterId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = ScenarioRepository(apiClient);

      await repository.addCharacterToScenario(widget.scenarioId!, characterId);

      // Reload characters
      final characters = await repository.getScenarioCharacters(widget.scenarioId!);

      setState(() {
        _scenarioCharacters = characters;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐릭터가 추가되었습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추가 실패: $e')),
      );
    }
  }

  Future<void> _removeCharacter(String characterId) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = ScenarioRepository(apiClient);

      await repository.removeCharacterFromScenario(widget.scenarioId!, characterId);

      setState(() {
        _scenarioCharacters.removeWhere((c) => c.id == characterId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐릭터가 제거되었습니다')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제거 실패: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenarioId != null ? '시나리오 편집' : '새 시나리오'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('저장'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '시나리오 이름 *',
                      hintText: '예: 학교 방과후',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력하세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명 *',
                      hintText: '시나리오 배경과 상황',
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '설명을 입력하세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (widget.scenarioId != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '캐릭터',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddCharacterDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('추가'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_scenarioCharacters.isEmpty)
                      const Text('캐릭터가 없습니다')
                    else
                      ..._scenarioCharacters.map((character) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: character.avatarUrl != null
                                ? NetworkImage(character.avatarUrl!)
                                : null,
                            child: character.avatarUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(character.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed: () => _removeCharacter(character.id),
                          ),
                        );
                      }).toList(),
                  ],
                ],
              ),
            ),
    );
  }
}

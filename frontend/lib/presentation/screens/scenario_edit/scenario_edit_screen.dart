import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scenario.dart';
import '../../../data/models/character.dart';
import '../../../data/providers/scenario_provider.dart';
import '../../../data/providers/character_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/scenario_repository.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';

class ScenarioEditScreen extends ConsumerStatefulWidget {
  final String? scenarioId;

  const ScenarioEditScreen({super.key, this.scenarioId});

  @override
  ConsumerState<ScenarioEditScreen> createState() => _ScenarioEditScreenState();
}

class _ScenarioEditScreenState extends ConsumerState<ScenarioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Character> _scenarioCharacters = [];
  bool _isLoading = false;
  bool _isPublic = false;

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
        _purposeController.text = scenario.purpose;
        _descriptionController.text = scenario.description;
        _scenarioCharacters = characters;
        _isPublic = scenario.isPublic;
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
            purpose: _purposeController.text,
            description: _descriptionController.text,
            isPublic: _isPublic,
          ),
        );
      } else {
        // Create new scenario
        await repository.createScenario(
          ScenarioCreate(
            name: _nameController.text,
            purpose: _purposeController.text,
            description: _descriptionController.text,
            isPublic: _isPublic,
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
                        backgroundImage: AppConstants.resolveAvatarUrl(character.avatarUrl) != null
                            ? NetworkImage(AppConstants.resolveAvatarUrl(character.avatarUrl)!)
                            : null,
                        child: AppConstants.resolveAvatarUrl(character.avatarUrl) == null
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

  Future<void> _deleteScenario() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('시나리오 삭제'),
        content: const Text('이 시나리오를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      final repository = ScenarioRepository(apiClient);
      await repository.deleteScenario(widget.scenarioId!);
      ref.invalidate(scenarioListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제되었습니다')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
      }
    }
  }

  Future<void> _autoGenerate() async {
    final sourceWorkController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('원작에서 시나리오 생성'),
        content: TextField(
          controller: sourceWorkController,
          decoration: const InputDecoration(
            labelText: '작품명',
            hintText: '예: 전지적독자시점, 나루토',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              if (sourceWorkController.text.isNotEmpty) {
                Navigator.pop(context, sourceWorkController.text);
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.scenarios}/auto-generate',
        data: {'source_work': result},
      );

      final data = response.data!;

      setState(() {
        _isLoading = false;
      });

      // 이미 백엔드에서 저장됨 → 목록 갱신 후 편집 화면으로 이동
      ref.invalidate(scenarioListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시나리오 + 캐릭터가 생성되었습니다!')),
        );
        // 생성된 시나리오 편집 화면으로 이동
        final scenarioId = data['id'] as String;
        context.pop(); // 현재 새 시나리오 화면 닫기
        context.push('/scenarios/edit/$scenarioId');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scenarioId != null ? '시나리오 편집' : '새 시나리오'),
        actions: [
          if (widget.scenarioId != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _deleteScenario,
            ),
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
                  if (widget.scenarioId == null) ...[
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _autoGenerate,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('원작에서 자동 생성'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
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
                    controller: _purposeController,
                    decoration: const InputDecoration(
                      labelText: '목적',
                      hintText: '예: DIO를 처치하고 가족을 구하라',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명 *',
                      hintText: '시나리오 배경과 상황',
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '설명을 입력하세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('공용으로 공유'),
                    subtitle: const Text('다른 유저도 이 시나리오를 사용할 수 있습니다'),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
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
                            backgroundImage: AppConstants.resolveAvatarUrl(character.avatarUrl) != null
                                ? NetworkImage(AppConstants.resolveAvatarUrl(character.avatarUrl)!)
                                : null,
                            child: AppConstants.resolveAvatarUrl(character.avatarUrl) == null
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

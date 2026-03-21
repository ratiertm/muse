import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/persona.dart';
import '../../../data/providers/persona_provider.dart';
import '../../../data/providers/auth_provider.dart';

class PersonaEditScreen extends ConsumerStatefulWidget {
  final String? personaId;

  const PersonaEditScreen({super.key, this.personaId});

  @override
  ConsumerState<PersonaEditScreen> createState() => _PersonaEditScreenState();
}

class _PersonaEditScreenState extends ConsumerState<PersonaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isEditMode => widget.personaId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPersona() async {
    if (!isEditMode || _isInitialized) return;

    setState(() => _isLoading = true);

    try {
      final personas = await ref.read(personaListProvider.future);
      final persona = personas.firstWhere((p) => p.id == widget.personaId);

      _nameController.text = persona.name;
      _appearanceController.text = persona.appearance ?? '';
      _personalityController.text = persona.personality ?? '';
      _descriptionController.text = persona.description ?? '';
      _isDefault = persona.isDefault;
      _isInitialized = true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('데이터 로딩 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(personaRepositoryProvider);

      if (isEditMode) {
        await repository.updatePersona(widget.personaId!, {
          'name': _nameController.text.trim(),
          'appearance': _appearanceController.text.trim().isEmpty
              ? null
              : _appearanceController.text.trim(),
          'personality': _personalityController.text.trim().isEmpty
              ? null
              : _personalityController.text.trim(),
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'is_default': _isDefault,
        });
      } else {
        await repository.createPersona(PersonaCreate(
          name: _nameController.text.trim(),
          appearance: _appearanceController.text.trim().isEmpty
              ? null
              : _appearanceController.text.trim(),
          personality: _personalityController.text.trim().isEmpty
              ? null
              : _personalityController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isDefault: _isDefault,
        ));
      }

      ref.invalidate(personaListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? '페르소나가 수정되었습니다' : '페르소나가 생성되었습니다'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _autoGenerate() async {
    final controllers = {
      'sourceWork': TextEditingController(),
      'characterName': TextEditingController(),
    };

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('원작에서 페르소나 생성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controllers['sourceWork'],
              decoration: const InputDecoration(
                labelText: '작품명',
                hintText: '예: 전지적독자시점, 나루토',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controllers['characterName'],
              decoration: const InputDecoration(
                labelText: '캐릭터 이름',
                hintText: '예: 김독자, 나루토',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (controllers['sourceWork']!.text.isNotEmpty &&
                  controllers['characterName']!.text.isNotEmpty) {
                Navigator.pop(context, {
                  'source_work': controllers['sourceWork']!.text,
                  'character_name': controllers['characterName']!.text,
                });
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
      // 캐릭터 자동생성 API를 빌려서 페르소나 정보 생성
      final response = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/characters/auto-generate',
        data: result,
      );

      final data = response.data!;

      setState(() {
        _nameController.text = data['name'] ?? '';
        _appearanceController.text = ''; // 캐릭터 API에는 외모가 없으므로 backstory에서 유추
        _personalityController.text = data['personality'] ?? '';
        _descriptionController.text = data['backstory'] ?? '';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('생성 완료! 내용을 확인 후 저장하세요.')),
        );
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
  void initState() {
    super.initState();
    if (isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPersona());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '페르소나 수정' : '페르소나 만들기'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('저장'),
          ),
        ],
      ),
      body: _isLoading && !_isInitialized && isEditMode
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!isEditMode) ...[
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
                      labelText: '이름 *',
                      hintText: '페르소나 이름을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '이름을 입력하세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _appearanceController,
                    decoration: const InputDecoration(
                      labelText: '외모',
                      hintText: '캐릭터의 외모를 설명하세요',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    minLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _personalityController,
                    decoration: const InputDecoration(
                      labelText: '성격',
                      hintText: '캐릭터의 성격을 설명하세요',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    minLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명',
                      hintText: '추가 설명을 입력하세요',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    minLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: const Text('기본 페르소나로 설정'),
                    subtitle: const Text('그룹 채팅에서 기본으로 선택됩니다'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() => _isDefault = value);
                    },
                  ),
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
    );
  }
}

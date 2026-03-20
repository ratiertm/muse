import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/character.dart';
import '../../../data/providers/character_provider.dart';

class CharacterCreateScreen extends ConsumerStatefulWidget {
  const CharacterCreateScreen({super.key});

  @override
  ConsumerState<CharacterCreateScreen> createState() => _CharacterCreateScreenState();
}

class _CharacterCreateScreenState extends ConsumerState<CharacterCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _personalityController = TextEditingController();
  final _speechStyleController = TextEditingController();
  final _backstoryController = TextEditingController();
  final _scenarioController = TextEditingController();
  final _firstMessageController = TextEditingController();
  final _exampleDialogueController = TextEditingController();
  final _tagController = TextEditingController();

  final List<String> _tags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _personalityController.dispose();
    _speechStyleController.dispose();
    _backstoryController.dispose();
    _scenarioController.dispose();
    _firstMessageController.dispose();
    _exampleDialogueController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveCharacter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final character = CharacterCreate(
      name: _nameController.text,
      personality: _personalityController.text,
      speechStyle: _speechStyleController.text,
      backstory: _backstoryController.text,
      scenario: _scenarioController.text,
      firstMessage: _firstMessageController.text,
      exampleDialogue: _exampleDialogueController.text,
      tags: _tags,
    );

    await ref.read(characterCreateProvider.notifier).createCharacter(character);

    if (mounted) {
      final state = ref.read(characterCreateProvider);
      state.when(
        data: (createdCharacter) {
          if (createdCharacter != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('캐릭터가 생성되었습니다')),
            );
            ref.invalidate(characterListProvider);
            context.pop();
          }
        },
        loading: () {},
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('오류: $error')),
          );
        },
      );
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(characterCreateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 캐릭터'),
        actions: [
          TextButton(
            onPressed: createState.isLoading ? null : _saveCharacter,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 *',
                hintText: '캐릭터 이름',
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
              controller: _personalityController,
              decoration: const InputDecoration(
                labelText: '성격 *',
                hintText: '상냥하고 호기심 많음',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '성격을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _speechStyleController,
              decoration: const InputDecoration(
                labelText: '말투 *',
                hintText: '따뜻하고 부드러움',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '말투를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _backstoryController,
              decoration: const InputDecoration(
                labelText: '배경 스토리 *',
                hintText: '캐릭터의 과거와 설정',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '배경 스토리를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scenarioController,
              decoration: const InputDecoration(
                labelText: '시나리오 (선택)',
                hintText: '대화 상황 설정',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstMessageController,
              decoration: const InputDecoration(
                labelText: '첫 메시지 (선택)',
                hintText: '캐릭터의 첫 인사',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exampleDialogueController,
              decoration: const InputDecoration(
                labelText: '예시 대화 (선택)',
                hintText: '<START>\n유저: 안녕?\n캐릭터: 안녕하세요!',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text(
              '태그',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: '태그 입력',
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            if (createState.isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

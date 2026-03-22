import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/scenario_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/persona_provider.dart';
import '../../../data/providers/group_chat_provider.dart';
import '../../../data/models/persona.dart';
import '../conversation_list/conversation_list_screen.dart';
import '../../../core/api/api_endpoints.dart';

class ScenarioListScreen extends ConsumerWidget {
  const ScenarioListScreen({super.key});

  Future<void> _autoGenerateScenario(BuildContext context, WidgetRef ref) async {
    final sourceWorkController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('원작에서 시나리오 생성'),
        content: TextField(
          controller: sourceWorkController,
          decoration: const InputDecoration(
            labelText: '작품명',
            hintText: '예: 전지적독자시점, 죠죠의 기묘한 모험',
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

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시나리오 생성 중... 잠시 기다려주세요')),
      );

      try {
        final apiClient = ref.read(apiClientProvider);
        final response = await apiClient.post<Map<String, dynamic>>(
          '${ApiEndpoints.scenarios}/auto-generate',
          data: {'source_work': result},
        );

        ref.invalidate(scenarioListProvider);

        if (context.mounted) {
          final scenarioId = response.data!['id'] as String;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('시나리오 + 캐릭터가 생성되었습니다!')),
          );
          context.push('/scenarios/edit/$scenarioId');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('생성 실패: $e')),
          );
        }
      }
    }
  }

  // WHY: 별도 화면 대신 바텀시트에서 상세+채팅생성을 통합 → 동선 2탭으로 단축
  // SEE: docs/decisions/006-scenario-inline-chat-creation.md
  void _showScenarioDetail(BuildContext context, WidgetRef ref, dynamic scenario) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ScenarioDetailSheet(
        scenario: scenario,
        parentContext: context,
      ),
    );
  }

  Widget _buildWorldStateChips(BuildContext context, Map<String, dynamic> ws) {
    final chips = <Widget>[];
    if (ws['timeline'] != null) {
      chips.add(_chip(context, Icons.timeline, ws['timeline']));
    }
    if (ws['location'] != null) {
      chips.add(_chip(context, Icons.place, ws['location']));
    }
    if (ws['current_time'] != null) {
      chips.add(_chip(context, Icons.access_time, ws['current_time']));
    }
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _chip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('스토리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: '원작에서 생성',
            onPressed: () => _autoGenerateScenario(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scenarios/create'),
        child: const Icon(Icons.add),
      ),
      body: scenariosAsync.when(
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('아직 스토리가 없어요', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('+ 버튼을 눌러 새로운 스토리를 만들어보세요!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(scenarioListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: scenarios.length,
              itemBuilder: (context, index) {
                final scenario = scenarios[index];
                return _buildScenarioCard(context, ref, scenario);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류: $error')),
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context, WidgetRef ref, dynamic scenario) {
    final avatars = scenario.characterAvatars as List<Map<String, dynamic>>;
    final summary = scenario.description.length > 80
        ? '${scenario.description.substring(0, 80)}...'
        : scenario.description;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showScenarioDetail(context, ref, scenario),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Character avatars row (hero image area)
            if (avatars.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    // Stacked avatars
                    SizedBox(
                      width: avatars.length * 30.0 + 20,
                      height: 52,
                      child: Stack(
                        children: [
                          for (int i = 0; i < avatars.length && i < 5; i++)
                            Positioned(
                              left: i * 26.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: AppConstants.resolveAvatarUrl(
                                          avatars[i]['avatar_url'] as String?) != null
                                      ? CachedNetworkImageProvider(
                                          AppConstants.resolveAvatarUrl(
                                              avatars[i]['avatar_url'] as String?)!)
                                      : null,
                                  child: AppConstants.resolveAvatarUrl(
                                              avatars[i]['avatar_url'] as String?) == null
                                      ? Text(
                                          (avatars[i]['name'] as String? ?? '?')[0],
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Character names
                    Expanded(
                      child: Text(
                        avatars.map((a) => a['name'] as String? ?? '').join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Title + summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      scenario.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (scenario.isPublic)
                    Icon(Icons.public, size: 16, color: Colors.green.shade400),
                ],
              ),
            ),

            // Purpose (if exists)
            if (scenario.purpose.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scenario.purpose,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            // Summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                summary,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// === Scenario Detail Bottom Sheet with Group Chat Creation ===

class _ScenarioDetailSheet extends ConsumerStatefulWidget {
  final dynamic scenario;
  final BuildContext parentContext;

  const _ScenarioDetailSheet({required this.scenario, required this.parentContext});

  @override
  ConsumerState<_ScenarioDetailSheet> createState() => _ScenarioDetailSheetState();
}

class _ScenarioDetailSheetState extends ConsumerState<_ScenarioDetailSheet> {
  final _titleController = TextEditingController();
  Persona? _selectedPersona;
  final Set<String> _selectedCharIds = {};
  bool _isCreating = false;
  bool _showDetail = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.scenario.name;
    // 기본으로 전체 캐릭터 선택
    for (final c in widget.scenario.characterAvatars) {
      final id = c['id'] as String?;
      if (id != null) _selectedCharIds.add(id);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _startGroupChat() async {
    if (_titleController.text.isEmpty) return;
    if (_selectedCharIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 2명의 캐릭터를 선택하세요')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final repository = ref.read(groupChatRepositoryProvider);
      final conversation = await repository.createGroupChat(
        scenarioId: widget.scenario.id,
        characterIds: _selectedCharIds.toList(),
        title: _titleController.text,
        personaId: _selectedPersona?.id,
      );

      // 대화 목록 갱신
      ref.invalidate(conversationListProvider);

      if (mounted) Navigator.pop(context);
      if (widget.parentContext.mounted) {
        widget.parentContext.push('/group-chat/${conversation.id}');
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('생성 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scenario = widget.scenario;
    final avatars = scenario.characterAvatars as List<Map<String, dynamic>>;
    final personasAsync = ref.watch(personaListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),

              // Title + edit button
              Row(
                children: [
                  Expanded(
                    child: Text(scenario.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  if (scenario.isMine)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.parentContext.push('/scenarios/edit/${scenario.id}');
                      },
                    ),
                ],
              ),

              // Purpose
              if (scenario.purpose.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flag, size: 14, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        scenario.purpose,
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],

              // Summary + "더보기"
              const SizedBox(height: 8),
              Text(
                _showDetail ? scenario.description : (scenario.description.length > 100
                    ? '${scenario.description.substring(0, 100)}...'
                    : scenario.description),
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
              ),
              if (scenario.description.length > 100)
                GestureDetector(
                  onTap: () => setState(() => _showDetail = !_showDetail),
                  child: Text(
                    _showDetail ? '접기' : '더보기',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),

              // World State chips
              if (scenario.worldState.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: [
                    if (scenario.worldState['timeline'] != null)
                      _chip(Icons.timeline, scenario.worldState['timeline']),
                    if (scenario.worldState['location'] != null)
                      _chip(Icons.place, scenario.worldState['location']),
                  ],
                ),
              ],

              const Divider(height: 24),

              // === 채팅 설정 ===
              const Text('채팅 시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // 채팅방 이름
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '채팅방 이름',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // 페르소나 선택
              personasAsync.when(
                data: (personas) {
                  if (personas.isEmpty) return const SizedBox.shrink();
                  return DropdownButtonFormField<Persona>(
                    value: _selectedPersona,
                    hint: const Text('나는 누구로 참여할까? (선택)'),
                    isExpanded: true,
                    items: personas.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                    onChanged: (v) => setState(() => _selectedPersona = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // 캐릭터 선택
              Text(
                '캐릭터 선택 (${_selectedCharIds.length}명)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (avatars.isEmpty)
                const Text('이 스토리에 캐릭터가 없습니다', style: TextStyle(color: Colors.grey))
              else
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: avatars.map((c) {
                    final charId = c['id'] as String? ?? '';
                    final charName = c['name'] as String? ?? '?';
                    final avatarUrl = AppConstants.resolveAvatarUrl(c['avatar_url'] as String?);
                    final selected = _selectedCharIds.contains(charId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedCharIds.remove(charId);
                          } else {
                            _selectedCharIds.add(charId);
                          }
                        });
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl == null ? Text(charName[0]) : null,
                              ),
                              if (selected)
                                Positioned(
                                  right: 0, bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                                  ),
                                ),
                              if (!selected)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 56,
                            child: Text(
                              charName, textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, color: selected ? null : Colors.grey),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              // 시작 버튼
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isCreating ? null : _startGroupChat,
                  icon: _isCreating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow),
                  label: Text(_isCreating ? '생성 중...' : '플레이 시작'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

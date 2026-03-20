import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../repositories/character_repository.dart';
import 'auth_provider.dart';

// Character Repository Provider
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository(ref.watch(apiClientProvider));
});

// Character List Provider
final characterListProvider = FutureProvider<List<Character>>((ref) async {
  final repository = ref.watch(characterRepositoryProvider);
  return await repository.getCharacters();
});

// Single Character Provider
final characterProvider = FutureProvider.family<Character, String>((ref, id) async {
  final repository = ref.watch(characterRepositoryProvider);
  return await repository.getCharacter(id);
});

// Character creation state
final characterCreateProvider = StateNotifierProvider<CharacterCreateNotifier, AsyncValue<Character?>>((ref) {
  return CharacterCreateNotifier(ref.watch(characterRepositoryProvider));
});

class CharacterCreateNotifier extends StateNotifier<AsyncValue<Character?>> {
  final CharacterRepository _repository;

  CharacterCreateNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createCharacter(CharacterCreate character) async {
    state = const AsyncValue.loading();
    try {
      final created = await _repository.createCharacter(character);
      state = AsyncValue.data(created);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

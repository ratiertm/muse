import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/persona.dart';
import '../repositories/persona_repository.dart';
import 'auth_provider.dart';

final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return PersonaRepository(ref.watch(apiClientProvider));
});

final personaListProvider = FutureProvider<List<Persona>>((ref) async {
  final repository = ref.watch(personaRepositoryProvider);
  return await repository.getPersonas();
});

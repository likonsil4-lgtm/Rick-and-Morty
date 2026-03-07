
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // register repositories
  // sl.registerLazySingleton<CharacterRepository>(() => CharacterRepositoryImpl());

  // register usecases
  // sl.registerLazySingleton(() => GetCharacters(sl()));
}

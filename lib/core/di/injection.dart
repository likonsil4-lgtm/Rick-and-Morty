import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../presentation/blocs/theme/theme_cubit.dart';
import '../../presentation/blocs/characters/characters_cubit.dart';
import '../../presentation/blocs/favorites/favorites_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {

  /// external
  final prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerSingleton<Dio>(
    Dio(BaseOptions(
      baseUrl: "https://rickandmortyapi.com/api",
    )),
  );

  getIt.registerSingleton<InternetConnectionChecker>(
    InternetConnectionChecker(),
  );

  /// cubits
  getIt.registerFactory(
        () => ThemeCubit(getIt<SharedPreferences>()),
  );

  getIt.registerFactory(
        () => CharactersCubit(getIt<Dio>()),
  );

  getIt.registerFactory(
        () => FavoritesCubit(getIt<SharedPreferences>()),
  );
}
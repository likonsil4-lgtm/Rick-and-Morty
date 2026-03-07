import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/character_local_datasource.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/remote/character_api_service.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../domain/repositories/character_repository.dart';
import '../../presentation/blocs/characters/characters_cubit.dart';
import '../../presentation/blocs/favorites/favorites_cubit.dart';
import '../../presentation/blocs/theme/theme_cubit.dart';
import '../network/network_info.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {

  // Network Info
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl(getIt<InternetConnectionChecker>()));

  // Database
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());

  // Data sources
  getIt.registerFactory<CharacterLocalDataSource>(
        () => CharacterLocalDataSourceImpl(getIt<SharedPreferences>(), getIt<DatabaseHelper>()),
  );

  getIt.registerFactory<CharacterApiService>(
        () => CharacterApiService(getIt<Dio>()),
  );

  // Repository
  getIt.registerFactory<CharacterRepository>(
        () => CharacterRepositoryImpl(
      getIt<CharacterApiService>(),
      getIt<CharacterLocalDataSource>(),
      getIt<NetworkInfo>(),
    ),
  );


  getIt.registerFactory<ThemeCubit>(
        () => ThemeCubit(getIt<SharedPreferences>()),
  );

  getIt.registerFactory<CharactersCubit>(
        () => CharactersCubit(getIt<CharacterRepository>()),
  );

  getIt.registerFactory<FavoritesCubit>(
        () => FavoritesCubit(getIt<CharacterRepository>()),
  );
}
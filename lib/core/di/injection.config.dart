// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/local/database_helper.dart' as _i380;
import '../../data/datasources/remote/character_api_service.dart' as _i234;
import '../../data/repositories/character_repository_impl.dart' as _i1071;
import '../../domain/repositories/character_repository.dart' as _i863;
import '../../presentation/blocs/characters/characters_cubit.dart' as _i434;
import '../../presentation/blocs/favorites/favorites_cubit.dart' as _i993;
import '../../presentation/blocs/theme/theme_cubit.dart' as _i473;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i380.DatabaseHelper>(() => _i380.DatabaseHelper());
    gh.factory<_i234.CharacterApiService>(
        () => _i234.CharacterApiService(gh<_i361.Dio>()));
    gh.factory<_i473.ThemeCubit>(() => _i473.ThemeCubit(gh<InvalidType>()));
    gh.factory<_i863.CharacterRepository>(() => _i1071.CharacterRepositoryImpl(
          gh<_i234.CharacterApiService>(),
          gh<_i380.DatabaseHelper>(),
        ));
    gh.factory<_i434.CharactersCubit>(
        () => _i434.CharactersCubit(gh<_i863.CharacterRepository>()));
    gh.factory<_i993.FavoritesCubit>(
        () => _i993.FavoritesCubit(gh<_i863.CharacterRepository>()));
    return this;
  }
}

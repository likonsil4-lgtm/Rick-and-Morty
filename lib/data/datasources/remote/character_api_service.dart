import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/character_model.dart';

@injectable
class CharacterApiService {
  final Dio _dio;

  CharacterApiService(this._dio);

  Future<List<CharacterModel>> getCharacters({int page = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
        queryParameters: {'page': page},
      );

      final results = response.data['results'] as List;
      return results.map((json) => CharacterModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load characters: $e');
    }
  }
}
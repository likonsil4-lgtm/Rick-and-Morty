import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/api_constants.dart';
import '../../models/character_model.dart';

@injectable
class CharacterApiService {
  final Dio _dio;

  CharacterApiService(this._dio);

  Future<List<CharacterModel>> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? gender,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;

      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.charactersEndpoint}',
        queryParameters: queryParams,
      );

      final results = response.data['results'] as List;
      return results.map((json) => CharacterModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load characters: $e');
    }
  }
}
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/character.dart';

part 'character_model.g.dart';

@JsonSerializable()
class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final LocationModel location;
  final LocationModel origin;

  // Исправлено: episode это List<String>, не String
  final List<String>? episode;
  final String? url;
  final String? created;

  CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.location,
    required this.origin,
    this.episode,
    this.url,
    this.created,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterModelToJson(this);

  Character toEntity({bool isFavorite = false}) => Character(
    id: id,
    name: name,
    status: status,
    species: species,
    type: type,
    gender: gender,
    image: image,
    location: location.name,
    origin: origin.name,
    isFavorite: isFavorite,
  );

  factory CharacterModel.fromEntity(Character entity) => CharacterModel(
    id: entity.id,
    name: entity.name,
    status: entity.status,
    species: entity.species,
    type: entity.type,
    gender: entity.gender,
    image: entity.image,
    location: LocationModel(name: entity.location),
    origin: LocationModel(name: entity.origin),
  );
}

@JsonSerializable()
class LocationModel {
  final String name;
  final String? url;

  LocationModel({required this.name, this.url});

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
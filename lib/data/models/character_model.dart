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
}

@JsonSerializable()
class LocationModel {
  final String name;

  LocationModel({required this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
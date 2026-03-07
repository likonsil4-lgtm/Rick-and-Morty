
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterFilterState {
  final String? status;
  final String? gender;

  const CharacterFilterState({this.status, this.gender});

  CharacterFilterState copyWith({String? status, String? gender}) {
    return CharacterFilterState(
      status: status ?? this.status,
      gender: gender ?? this.gender,
    );
  }
}

class CharacterFilterCubit extends Cubit<CharacterFilterState> {
  CharacterFilterCubit() : super(const CharacterFilterState());

  void setStatus(String status) {
    emit(state.copyWith(status: status));
  }

  void setGender(String gender) {
    emit(state.copyWith(gender: gender));
  }

  void clearFilters() {
    emit(const CharacterFilterState());
  }
}

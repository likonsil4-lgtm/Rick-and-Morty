import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server Error', super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache Error'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No Internet Connection'});
}
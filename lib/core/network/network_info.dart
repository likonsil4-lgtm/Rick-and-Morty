import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:injectable/injectable.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectionChange;
}

@Injectable(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker _checker;

  NetworkInfoImpl(this._checker);

  @override
  Future<bool> get isConnected => _checker.hasConnection;

  @override
  Stream<bool> get onConnectionChange => _checker.onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
  );
}
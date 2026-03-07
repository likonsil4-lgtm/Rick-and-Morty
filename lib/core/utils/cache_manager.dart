
class CacheManager {
  final Map<String, dynamic> _cache = {};

  T? get<T>(String key) {
    return _cache[key];
  }

  void set(String key, dynamic value) {
    _cache[key] = value;
  }
}

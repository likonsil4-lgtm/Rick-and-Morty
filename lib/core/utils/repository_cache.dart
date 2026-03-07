
class RepositoryCache<T> {
  T? _data;

  bool get hasData => _data != null;

  T? get data => _data;

  void save(T data) {
    _data = data;
  }

  void clear() {
    _data = null;
  }
}

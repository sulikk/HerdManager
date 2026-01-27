mixin FilterableListMixin<T> {
  List<T> allItems = [];
  List<T> filteredItems = [];

  void initFilter(List<T> items) {
    allItems = items;
    filteredItems = List.from(items);
  }

  void applySearch(String query, bool Function(T item, String query) matcher) {
    final q = query.toLowerCase();
    filteredItems = allItems.where((item) => matcher(item, q)).toList();
  }

  void sortItems(int Function(T a, T b) compare) {
    filteredItems.sort(compare);
  }
}
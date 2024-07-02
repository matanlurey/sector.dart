import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

/// A base grid implementation that delegates all methods to another grid.
@internal
abstract base class DelegatingGridView<T> implements Grid<T> {
  /// Creates a new grid that delegates all methods to the provided view.
  const DelegatingGridView(this.view);

  @protected
  final Grid<T> view;

  @override
  int get width => view.width;

  @override
  int get height => view.height;

  @override
  bool get isEmpty => view.isEmpty;

  @override
  bool contains(T value) => view.contains(value);

  @override
  bool containsXY(int x, int y) => view.containsXY(x, y);

  @override
  bool containsXYWH(int x, int y, int width, int height) {
    return view.containsXYWH(x, y, width, height);
  }

  @override
  T get(int x, int y) => view.get(x, y);

  @override
  T getUnchecked(int x, int y) => view.getUnchecked(x, y);

  @override
  void set(int x, int y, T value) => view.set(x, y, value);

  @override
  void setUnchecked(int x, int y, T value) => view.setUnchecked(x, y, value);

  @override
  void clear() => view.clear();

  @override
  GridAxis<T> get rows => view.rows;

  @override
  GridAxis<T> get columns => view.columns;

  @override
  GridIterable<T> traverse([Traversal<T>? order]) {
    return view.traverse(order);
  }

  @override
  LayoutHint get layoutHint => view.layoutHint;

  @override
  T getByIndexUnchecked(int index) => view.getByIndexUnchecked(index);

  @override
  Grid<T> subGrid({
    int left = 0,
    int top = 0,
    int? width,
    int? height,
  }) {
    return view.subGrid(left: left, top: top, width: width, height: height);
  }

  @override
  Grid<T> asSubGrid({
    int left = 0,
    int top = 0,
    int? width,
    int? height,
  }) {
    return view.asSubGrid(left: left, top: top, width: width, height: height);
  }

  @override
  String toString() => view.toString();
}

@internal
base class DelegatingGridAxis<T> extends GridAxis<T> {
  const DelegatingGridAxis(this._axis);
  final GridAxis<T> _axis;

  @override
  Iterator<Iterable<T>> get iterator => _axis.iterator;

  @override
  set first(Iterable<T> cells) {
    _axis.first = cells;
  }

  @override
  set last(Iterable<T> cells) {
    _axis.last = cells;
  }

  @override
  void operator []=(int index, Iterable<T> cells) {
    _axis[index] = cells;
  }

  @override
  Iterable<T> operator [](int index) => _axis[index];

  @override
  void insertAt(int index, Iterable<T> cells) {
    _axis.insertAt(index, cells);
  }

  @override
  void insertFirst(Iterable<T> cells) {
    _axis.insertFirst(cells);
  }

  @override
  void insertLast(Iterable<T> cells) {
    _axis.insertLast(cells);
  }

  @override
  void removeAt(int index) {
    _axis.removeAt(index);
  }

  @override
  void removeFirst() {
    _axis.removeFirst();
  }

  @override
  void removeLast() {
    _axis.removeLast();
  }
}

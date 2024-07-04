// This file is not tested; the API that matters is tested through other APIs.
// coverage:ignore-file

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
  bool containsPos(Pos position) => view.containsPos(position);

  @override
  bool containsRect(Pos topLeft, int width, int height) {
    return view.containsRect(topLeft, width, height);
  }

  @override
  T get(Pos position) => view.get(position);

  @override
  T getUnchecked(Pos position) => view.getUnchecked(position);

  @override
  void set(Pos pos, T value) => view.set(pos, value);

  @override
  void setUnchecked(Pos pos, T value) => view.setUnchecked(pos, value);

  @override
  void clear() => view.clear();

  @override
  GridAxis<T> get rows => view.rows;

  @override
  GridAxis<T> get columns => view.columns;

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
  const DelegatingGridAxis(this.view);

  @protected
  final GridAxis<T> view;

  @override
  Iterator<Iterable<T>> get iterator => view.iterator;

  @override
  set first(Iterable<T> cells) {
    view.first = cells;
  }

  @override
  set last(Iterable<T> cells) {
    view.last = cells;
  }

  @override
  void operator []=(int index, Iterable<T> cells) {
    view[index] = cells;
  }

  @override
  Iterable<T> operator [](int index) => view[index];

  @override
  void insertAt(int index, Iterable<T> cells) {
    view.insertAt(index, cells);
  }

  @override
  void insertFirst(Iterable<T> cells) {
    view.insertFirst(cells);
  }

  @override
  void insertLast(Iterable<T> cells) {
    view.insertLast(cells);
  }

  @override
  void removeAt(int index) {
    view.removeAt(index);
  }

  @override
  void removeFirst() {
    view.removeFirst();
  }

  @override
  void removeLast() {
    view.removeLast();
  }
}

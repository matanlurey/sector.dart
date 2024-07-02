import 'package:sector/sector.dart';

/// A naive implementation of [Grid] that uses default methods where possible.
///
/// This class is not optimized for performance, and is intended to be used as a
/// reference implementation for testing and debugging default [Grid] methods.
final class NaiveListGrid<T> with Grid<T> {
  NaiveListGrid(this._cells, this._width);

  factory NaiveListGrid.fromRows(Iterable<Iterable<T>> rows) {
    final width = rows.isEmpty ? 0 : rows.first.length;
    final cells = rows.expand((row) => row).toList();
    return NaiveListGrid(cells, width);
  }

  final List<T> _cells;

  @override
  int get width => _width;
  int _width;

  @override
  int get height => _width == 0 ? 0 : _cells.length ~/ _width;

  @override
  GridAxis<T> get rows => _Rows(this);

  @override
  GridAxis<T> get columns => _Columns(this);

  @override
  T getUnchecked(int x, int y) => _cells[x + y * _width];

  @override
  void setUnchecked(int x, int y, T value) {
    _cells[x + y * _width] = value;
  }
}

final class _Rows<T> extends GridAxis<T> with RowsMixin<T> {
  _Rows(this.grid);

  @override
  final NaiveListGrid<T> grid;

  @override
  void removeAt(int index) {
    grid._cells.removeAt(index);
  }

  @override
  void insertAt(int index, Iterable<T> row) {
    if (grid.isEmpty && index == 0) {
      grid._cells.addAll(row);
      grid._width = row.length;
      return;
    }
    grid._cells.insertAll(index, row);
  }
}

final class _Columns<T> extends GridAxis<T> with ColumnsMixin<T> {
  _Columns(this.grid);

  @override
  final NaiveListGrid<T> grid;

  @override
  void removeAt(int index) {
    for (var i = index; i < grid._cells.length; i += grid.width) {
      grid._cells.removeAt(i);
    }

    grid._width -= 1;
  }

  @override
  void insertAt(int index, Iterable<T> column) {
    if (grid.isEmpty && index == 0) {
      grid._cells.addAll(column);
      grid._width = 1;
      return;
    }

    final columnList = List.of(column);
    for (var y = grid.height - 1; y >= 0; y--) {
      grid._cells.insert(index + y * grid.width, columnList[y]);
    }

    grid._width += 1;
  }
}

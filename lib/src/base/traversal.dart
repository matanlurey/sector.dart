import 'package:sector/sector.dart';

/// A traversal that can be used to iterate over a grid in a specific order.
///
/// This interface is used to define the order in which elements are visited
/// when iterating over a grid. For example, a row-major traversal will visit
/// each row in order from left to right, while a spiral traversal will visit
/// the elements in a spiral pattern starting from the center.
///
/// ## Examples
///
/// To use a traversal, call the `traverse` method on the grid with the desired
/// type of traversal. For example, to iterate over a grid in row-major order:
/// ```dart
/// final grid = ListGrid.fromRows([
///   ['a', 'b'],
///   ['c', 'd'],
/// ]);
/// for (final cell in grid.traverse(rowMajor)) {
///   print(cell);
/// }
/// ```
///
/// The output of the example is:
///
/// ```txt
/// a
/// b
/// c
/// d
/// ```
typedef Traversal<T> = GridIterable<T> Function(
  Grid<T> grid, {
  (int x, int y)? start,
});

/// A row-major traversal that visits each row in order from left to right.
///
/// This traversal visits each row in order from left to right, starting at the
/// top-left corner of the grid and moving to the right until the end of the
/// row, then moving to the next row and repeating the process until the entire
/// grid has been visited.
GridIterable<T> rowMajor<T>(
  Grid<T> grid, {
  (int x, int y)? start,
  (int x, int y) step = (1, 0),
}) {
  final start_ = start ?? (0, 0);
  return GridIterable.from(() {
    return _RowMajorIterator<T>(grid, step.$1, step.$2, start_.$1, start_.$2);
  });
}

final class _RowMajorIterator<T> with GridIterator<T> {
  _RowMajorIterator(
    this._grid,
    this._dx,
    this._dy,
    int startX,
    int startY,
  )   : _x = startX - _dx,
        _y = startY - _dy {
    RangeError.checkNotNegative(_dx, 'dx');
    RangeError.checkNotNegative(_dy, 'dy');
  }

  final Grid<T> _grid;
  final int _dx;
  final int _dy;

  int _x;
  int _y;

  @override
  bool moveNext() {
    _x += _dx;
    if (_x >= _grid.width) {
      _x = 0;
      _y += 1;
    }
    _y += _dy;
    return _y < _grid.height;
  }

  @override
  T get current => _grid.get(_x, _y);

  @override
  (int, int) get position => (_x, _y);
}

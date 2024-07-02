import 'package:sector/sector.dart';

/// A row-major traversal that visits each row in order from left to right.
///
/// This traversal visits each row in order from left to right, starting at the
/// top-left corner of the grid and moving to the right until the end of the
/// row, then moving to the next row and repeating the process until the entire
/// grid has been visited.
Traversal<T> rowMajor<T>({
  (int x, int y) step = (1, 0),
}) {
  return (grid, {start}) {
    final (startX, startY) = start ?? (0, 0);
    return GridIterable.from(
      () => _RowMajorIterator(
        grid,
        step.$1,
        step.$2,
        startX,
        startY,
      ),
    );
  };
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

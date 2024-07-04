part of '../traversal_2.dart';

final class _RowMajorGridTraveral implements GridTraversal {
  const _RowMajorGridTraveral({
    (int, int) start = (0, 0),
  }) : _start = start;

  final (int, int) _start;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    if (grid is EfficientIndexGrid<T> && grid.layoutHint.isRowMajorContiguous) {
      var index = 0;
      if (_start != (0, 0)) {
        index = grid.layoutHint.toIndex(
          _start.$1,
          _start.$2,
          width: grid.width,
        );
      }
      return _FastRowMajorIterator<T>(grid, index - 1);
    }
    return _RowMajorIterator<T>(grid, _start);
  }
}

final class _RowMajorIterator<T> extends XYGridIterator<T> {
  _RowMajorIterator(super.grid, super.position);

  @override
  (int, int) firstPosition() => position;

  @override
  (int, int) nextPosition(int x, int y) {
    if (x + 1 < grid.width) {
      return (x + 1, y);
    } else if (y + 1 < grid.height) {
      return (0, y + 1);
    }
    return done;
  }
}

final class _FastRowMajorIterator<T> extends IndexGridIterator<T> {
  _FastRowMajorIterator(super.grid, super.index);

  @override
  bool moveNext() => ++index < length;
}

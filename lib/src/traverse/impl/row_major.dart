part of '../traversal.dart';

final class _RowMajorGridTraveral implements GridTraversal {
  const _RowMajorGridTraveral({
    Pos start = Pos.zero,
  }) : _start = start;

  final Pos _start;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    if (grid is EfficientIndexGrid<T> && grid.layoutHint.isRowMajorContiguous) {
      var index = 0;
      if (_start != Pos.zero) {
        index = grid.layoutHint.toIndex(_start, width: grid.width);
      }
      return _FastRowMajorIterator<T>(grid, index - 1);
    }
    return _RowMajorIterator<T>(grid, _start);
  }
}

final class _RowMajorIterator<T> extends XYGridIterator<T> {
  _RowMajorIterator(super.grid, super.position);

  @override
  Pos firstPosition() => position;

  @override
  Pos nextPosition(Pos previous) {
    if (previous.x + 1 < grid.width) {
      return Pos(previous.x + 1, previous.y);
    } else if (previous.y + 1 < grid.height) {
      return Pos(0, previous.y + 1);
    }
    return done;
  }
}

final class _FastRowMajorIterator<T> extends IndexGridIterator<T> {
  _FastRowMajorIterator(super.grid, super.index);

  @override
  bool moveNext() => ++index < length;
}

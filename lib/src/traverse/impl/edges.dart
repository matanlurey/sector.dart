part of '../traversal.dart';

final class _EdgesGridTraveral implements GridTraversal {
  const _EdgesGridTraveral();

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    if (grid.isEmpty) {
      return GridIterator.empty();
    }
    return _EdgesIterator<T>(grid);
  }
}

final class _EdgesIterator<T> extends XYGridIterator<T> {
  _EdgesIterator(super.grid);

  @override
  Pos firstPosition() => Pos.zero;

  var _direction = _Direction.right;

  @override
  Pos nextPosition(Pos previous) {
    if (_direction == _Direction.right) {
      if (previous.x < grid.width - 1) {
        return Pos(previous.x + 1, previous.y);
      }
      _direction = _Direction.down;
    }

    if (_direction == _Direction.down) {
      if (previous.y < grid.height - 1) {
        return Pos(previous.x, previous.y + 1);
      }
      _direction = _Direction.left;
    }

    if (_direction == _Direction.left) {
      if (previous.x > 0) {
        return Pos(previous.x - 1, previous.y);
      }
      _direction = _Direction.up;
    }

    if (_direction == _Direction.up && previous.y > 0) {
      return Pos(previous.x, previous.y - 1);
    }

    return done;
  }
}

enum _Direction {
  right,
  down,
  left,
  up;
}

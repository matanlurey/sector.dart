part of '../traversal_2.dart';

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
  (int, int) firstPosition() {
    return (0, 0);
  }

  var _direction = _Direction.right;

  @override
  (int, int) nextPosition(int x, int y) {
    if (_direction == _Direction.right) {
      if (x < grid.width - 1) {
        return (x + 1, y);
      }
      _direction = _Direction.down;
    }

    if (_direction == _Direction.down) {
      if (y < grid.height - 1) {
        return (x, y + 1);
      }
      _direction = _Direction.left;
    }

    if (_direction == _Direction.left) {
      if (x > 0) {
        return (x - 1, y);
      }
      _direction = _Direction.up;
    }

    if (_direction == _Direction.up && y > 0) {
      return (x, y - 1);
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

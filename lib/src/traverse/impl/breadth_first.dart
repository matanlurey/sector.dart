part of '../traversal_2.dart';

final class _BreadthFirstTraversal implements GridTraversal {
  const _BreadthFirstTraversal(this._x, this._y);

  final int _x;
  final int _y;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    return _BreadthFirstIterator(grid, (_x, _y));
  }
}

final class _BreadthFirstIterator<T> extends XYGridIterator<T> {
  _BreadthFirstIterator(super.grid, super.position) {
    _queue.add(position);
  }

  final _queue = Queue<(int, int)>();
  final _visited = HashSet<(int, int)>();

  @override
  (int, int) nextPosition(int x, int y) {
    while (_queue.isNotEmpty) {
      final next = _queue.removeFirst();
      if (!_visited.add(next)) {
        continue;
      }

      for (final (dx, dy) in _adjacentDXDY) {
        final nx = x + dx;
        final ny = y + dy;
        if (grid.containsXY(nx, ny)) {
          _queue.add((nx, ny));
        }
      }

      return next;
    }

    return done;
  }
}

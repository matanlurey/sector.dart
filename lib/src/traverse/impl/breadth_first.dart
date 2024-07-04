part of '../traversal.dart';

final class _BreadthFirstTraversal implements GridTraversal {
  const _BreadthFirstTraversal(this._x, this._y);

  final int _x;
  final int _y;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    return _BreadthFirstIterator(grid, Pos(_x, _y));
  }
}

final class _BreadthFirstIterator<T> extends XYGridIterator<T> {
  _BreadthFirstIterator(super.grid, super.position) {
    _queue.add(position);
  }

  final _queue = Queue<Pos>();
  final _visited = HashSet<Pos>();

  @override
  Pos nextPosition(Pos previous) {
    while (_queue.isNotEmpty) {
      final next = _queue.removeFirst();
      if (!_visited.add(next)) {
        continue;
      }

      for (final (dx, dy) in _adjacentDXDY) {
        final check = Pos(next.x + dx, next.y + dy);
        if (grid.containsPos(check)) {
          _queue.add(check);
        }
      }

      return next;
    }

    return done;
  }
}

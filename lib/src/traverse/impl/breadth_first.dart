part of '../traversal.dart';

final class _BreadthFirstTraversal implements GridTraversal {
  const _BreadthFirstTraversal(this._start);

  final Pos _start;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    return _BreadthFirstIterator(grid, _start);
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

      for (final direction in Cardinal.values) {
        final check = next + direction.offset;
        if (grid.containsPos(check)) {
          _queue.add(check);
        }
      }

      return next;
    }

    return done;
  }
}

part of '../traversal.dart';

final class _NeighborsTraversal implements GridTraversal {
  const _NeighborsTraversal(
    this._start,
    this._directions,
  );

  const _NeighborsTraversal.adjacent(Pos start) : this(start, Cardinal.values);

  const _NeighborsTraversal.diagonal(Pos start) : this(start, Direction.values);

  final Pos _start;
  final List<Direction> _directions;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    return _NeighborsIterator(
      grid,
      _start,
      _directions.map((d) => d.offset).toList(),
    );
  }
}

final class _NeighborsIterator<T> with GridIterator<T> {
  _NeighborsIterator(
    this._grid,
    this._position,
    this._directions,
  );

  final Grid<T> _grid;
  final Pos _position;
  final List<Pos> _directions;
  var _index = 0;

  @override
  late Pos position;

  @override
  T get current => _grid.getUnchecked(position);

  @override
  bool moveNext() {
    while (_index < _directions.length) {
      final delta = _directions[_index];
      _index += 1;

      final next = _position + delta;
      if (_grid.containsPos(next)) {
        position = next;
        return true;
      }
    }

    return false;
  }
}

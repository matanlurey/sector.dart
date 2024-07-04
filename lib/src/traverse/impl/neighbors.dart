part of '../traversal.dart';

const _adjacentDXDY = [
  (0, -1),
  (1, 0),
  (0, 1),
  (-1, 0),
];

const _diagonalDXDY = [
  (0, -1),
  (1, -1),
  (1, 0),
  (1, 1),
  (0, 1),
  (-1, 1),
  (-1, 0),
  (-1, -1),
];

final class _NeighborsTraversal implements GridTraversal {
  const _NeighborsTraversal(this._x, this._y, this._directions);
  const _NeighborsTraversal.adjacent(int x, int y) : this(x, y, _adjacentDXDY);
  const _NeighborsTraversal.diagonal(int x, int y) : this(x, y, _diagonalDXDY);

  final int _x;
  final int _y;
  final List<(int, int)> _directions;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    return _NeighborsIterator(
      grid,
      (_x, _y),
      _directions,
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
  final (int, int) _position;
  final List<(int, int)> _directions;
  var _index = 0;

  @override
  late Pos position;

  @override
  T get current => _grid.getUnchecked(position);

  @override
  bool moveNext() {
    while (_index < _directions.length) {
      final (dx, dy) = _directions[_index];
      _index += 1;

      final (x, y) = _position;
      final nx = x + dx;
      final ny = y + dy;

      if (_grid.containsPos(Pos(nx, ny))) {
        position = Pos(nx, ny);
        return true;
      }
    }

    return false;
  }
}

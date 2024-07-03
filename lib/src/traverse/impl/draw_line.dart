part of '../traversal_2.dart';

final class _DrawLineGridTraveral implements GridTraversal {
  factory _DrawLineGridTraveral(
    int x1,
    int y1,
    int x2,
    int y2, {
    bool inclusive = true,
  }) {
    final octant = Octant.fromPoints(x1, y1, x2, y2);
    (x1, y1) = octant.toOctant1(x1, y1);
    (x2, y2) = octant.toOctant1(x2, y2);
    final dx = x2 - x1;
    final dy = y2 - y1;
    return _DrawLineGridTraveral._(
      x1,
      y1,
      x2,
      dx,
      dy,
      octant,
      inclusive,
    );
  }

  const _DrawLineGridTraveral._(
    this._x1,
    this._y1,
    this._x2,
    this._dx,
    this._dy,
    this._octant,
    // ignore: avoid_positional_boolean_parameters
    this._inclusive,
  );

  final Octant _octant;
  final bool _inclusive;
  final int _x1;
  final int _y1;
  final int _x2;
  final int _dx;
  final int _dy;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    return _DrawLineIterator<T>(
      grid,
      _octant,
      _x1,
      _y1,
      _x2,
      _inclusive,
      _dx,
      _dy,
    );
  }
}

final class _DrawLineIterator<T> with GridIterator<T> {
  _DrawLineIterator(
    this._grid,
    this._octant,
    this._startX,
    this._startY,
    this._endX,
    // ignore: avoid_positional_boolean_parameters
    this._inclusive,
    this._dx,
    this._dy,
  ) : _diff = _dy - _dx;

  final Grid<T> _grid;

  final int _dx;
  final int _dy;
  final Octant _octant;
  final int _endX;

  int _startX;
  int _startY;
  int _diff;

  final bool _inclusive;

  @override
  late (int, int) position;

  @override
  T get current => _grid.getUnchecked(position.$1, position.$2);

  @override
  bool moveNext() {
    final x = _startX;
    if (_inclusive ? x > _endX : x >= _endX) {
      return false;
    }

    final y = _startY;
    position = _octant.fromOctant1(x, y);
    if (_diff >= 0) {
      _startY += 1;
      _diff -= _dx;
    }
    _diff += _dy;
    _startX += 1;

    return true;
  }
}

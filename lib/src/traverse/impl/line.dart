// ignore_for_file: avoid_positional_boolean_parameters

part of '../traversal.dart';

final class _LineGridTraveral implements GridTraversal {
  const _LineGridTraveral(
    this._x1,
    this._y1,
    this._x2,
    this._y2, {
    bool inclusive = true,
  }) : _inclusive = inclusive;

  final int _x1;
  final int _y1;
  final int _x2;
  final int _y2;
  final bool _inclusive;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    var x1 = _x1;
    var y1 = _y1;
    var x2 = _x2;
    var y2 = _y2;

    // Ensure bounds.
    GridImpl.checkBoundsExclusive(grid, x1, y1);
    GridImpl.checkBoundsExclusive(grid, x2, y2);

    // First, determine what octant the line is in, i.e. the origin octant.
    // We store this octant so that we can convert the points back to the
    // original octant after traversing the line.
    final octant = Octant.fromPoints(x1, y1, x2, y2);

    // Convert the points to the first octant.
    // This is the octant where the line has a slope between 0 and 1, which
    // makes it easier to traverse, as the direction of the line is always
    // either right or down.
    (x1, y1) = octant.toOctant1(x1, y1);
    (x2, y2) = octant.toOctant1(x2, y2);

    // Calculate the change in x and y.
    final dx = x2 - x1;
    final dy = y2 - y1;

    return _LineIterator<T>(
      grid,
      octant,
      x1,
      y1,
      x2,
      _inclusive,
      dx,
      dy,
    );
  }
}

final class _LineIterator<T> with GridIterator<T> {
  _LineIterator(
    this._grid,
    this._octant,
    this._startX,
    this._startY,
    this._endX,
    this._inclusive,
    this._dx,
    this._dy,
  ) : _diff = _dy - _dx;

  // Immutable state.
  // ---------------------------------------------------------------------------

  /// Grid being traversed.
  final Grid<T> _grid;

  /// Direction of the line in the x-axis.
  final int _dx;

  /// Direction of the line in the y-axis.
  final int _dy;

  /// Which octant the line is in.
  final Octant _octant;

  /// The final x-coordinate of the line.
  final int _endX;

  /// Whether the line should include the end point.
  final bool _inclusive;

  // Mutable state.
  // ---------------------------------------------------------------------------

  /// The current x-coordinate of the line, which is stored in the first octant.
  int _startX;

  /// The current y-coordinate of the line, which is stored in the first octant.
  int _startY;

  /// The difference between the y-coordinate and the x-coordinate.
  int _diff;

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
      _diff -= _dx;
      _startY += 1;
    }

    _diff += _dy;
    _startX += 1;

    return true;
  }
}

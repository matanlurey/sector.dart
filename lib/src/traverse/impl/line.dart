// ignore_for_file: avoid_positional_boolean_parameters

part of '../traversal.dart';

final class _LineGridTraveral implements GridTraversal {
  const _LineGridTraveral(
    this._start,
    this._end, {
    bool inclusive = true,
  }) : _inclusive = inclusive;

  final Pos _start;
  final Pos _end;
  final bool _inclusive;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    var start = _start;
    var end = _end;

    // Ensure bounds.
    GridImpl.checkBoundsExclusive(grid, start);
    GridImpl.checkBoundsExclusive(grid, end);

    // First, determine what octant the line is in, i.e. the origin octant.
    // We store this octant so that we can convert the points back to the
    // original octant after traversing the line.
    final octant = Octant.between(start, end);

    // Convert the points to the first octant.
    // This is the octant where the line has a slope between 0 and 1, which
    // makes it easier to traverse, as the direction of the line is always
    // either right or down.
    start = octant.toOctant1(start);
    end = octant.toOctant1(end);

    // Calculate the change in x and y.
    final delta = end - start;

    return _LineIterator<T>(
      grid,
      octant,
      start,
      end,
      delta,
      _inclusive,
    );
  }
}

final class _LineIterator<T> with GridIterator<T> {
  _LineIterator(
    this._grid,
    this._octant,
    this._start,
    this._end,
    this._delta,
    this._inclusive,
  ) : _diff = _delta.y - _delta.x;

  // Immutable state.
  // ---------------------------------------------------------------------------

  /// Grid being traversed.
  final Grid<T> _grid;

  /// Direction of the line.
  final Pos _delta;

  /// Which octant the line is in.
  final Octant _octant;

  /// The final coordinate of the line.
  final Pos _end;

  /// Whether the line should include the end point.
  final bool _inclusive;

  // Mutable state.
  // ---------------------------------------------------------------------------

  /// The current coordinate in the line, stored in the first octant.
  Pos _start;

  /// The difference between the y-coordinate and the x-coordinate.
  int _diff;

  @override
  late Pos position;

  @override
  T get current => _grid.getUnchecked(position);

  @override
  bool moveNext() {
    var Pos(:x, :y) = _start;
    if (_inclusive ? x > _end.x : x >= _end.x) {
      return false;
    }

    position = _octant.fromOctant1(_start);
    if (_diff >= 0) {
      _diff -= _delta.x;
      y += 1;
    }

    _diff += _delta.y;
    x += 1;

    _start = Pos(x, y);
    return true;
  }
}

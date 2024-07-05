// ignore_for_file: avoid_positional_boolean_parameters

part of '../traversal.dart';

final class _LineGridTraveral implements GridTraversal {
  const _LineGridTraveral(
    this._start,
    this._end, {
    bool exclusive = false,
  }) : _exclusive = exclusive;

  final Pos _start;
  final Pos _end;
  final bool _exclusive;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    // Ensure bounds.
    GridImpl.checkBoundsExclusive(grid, _start);
    GridImpl.checkBoundsExclusive(grid, _end);

    final points = _start.lineTo(_end, exclusive: _exclusive).iterator;
    return _LineIterator(grid, points);
  }
}

final class _LineIterator<T> with GridIterator<T> {
  _LineIterator(this._grid, this._points);

  final Grid<T> _grid;
  final Iterator<Pos> _points;

  @override
  T get current => _grid.get(position);

  @override
  Pos get position => _points.current;

  @override
  bool moveNext() => _points.moveNext();
}

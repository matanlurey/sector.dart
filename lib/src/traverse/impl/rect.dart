part of '../traversal.dart';

final class _RectGridTraversal implements GridTraversal {
  const _RectGridTraversal(
    this._left,
    this._top,
    this._width,
    this._height,
  );

  final int _left;
  final int _top;
  final int _width;
  final int _height;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) {
    GridImpl.checkBoundsXYWH(grid, _left, _top, _width, _height);
    return _RectIterator(
      grid,
      _left,
      _top,
      _width,
      _height,
    );
  }
}

final class _RectIterator<T> extends XYGridIterator<T> {
  _RectIterator(
    super.grid,
    this._left,
    this._top,
    int width,
    int height,
  )   : _right = width + _left,
        _bottom = height + _top;

  final int _left;
  final int _top;
  final int _right;
  final int _bottom;

  @override
  Pos firstPosition() => Pos(_left, _top);

  @override
  Pos nextPosition(Pos previous) {
    if (previous.x + 1 < _right) {
      return Pos(previous.x + 1, previous.y);
    } else if (previous.y + 1 < _bottom) {
      return Pos(_left, previous.y + 1);
    }
    return done;
  }
}

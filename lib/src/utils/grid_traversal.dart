import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

/// A grid traversal algorithim that iterates over a grid in a row-major order.
const GridTraversal rowMajor = GridTraversal.rowMajorByXY(1, 0);

/// A grid traversal algorithim that iterates over a grid in a specific order.
///
/// ## Implementing
///
/// Implementations of this class should be immutable and have a const
/// constructor if able, as they are intended to be used as immutable
/// algorithm objects.
///
/// You may find it easier to implement this interface by creating a
/// [GridIterator] sub-type that implements the traversal logic. See [iterator]
/// and [traverse] for more recommendations on implementing this interface.
@immutable
abstract mixin class GridTraversal {
  /// Creates a traversal that iterates over a grid with set directional steps.
  ///
  /// The [dx] and [dy] parameters specify the steps to take in the x and y
  /// directions, respectively. For example, to traverse a grid in a zig-zag
  /// pattern, you could use `GridTraversal.byStepsXY(1, 1)`.
  const factory GridTraversal.rowMajorByXY(
    int dx,
    int dy,
  ) = _RowMajorTraversal;

  /// Returns an iterable that traverses a [grid] in a specific order.
  ///
  /// The order of traversal is determined by the specific implementation.
  ///
  /// The optional [start] parameter specifies the starting point of the
  /// traversal. If not provided, the traversal will start at a default point
  /// that makes sense for the specific implementation, and attempt to visit
  /// _all_ or _most_ elements in the grid, if possible.
  ///
  /// See [Grid.traverse] for usage examples.
  ///
  /// ## Performance
  ///
  /// In order to keep the API surface small, [traverse] returns both the
  /// position of the cell and the value of the cell. If you only need one or
  /// the other, or your code is performance-sensitive, you may choose to
  /// rely directly on the [iterator] method, which has specific getters, e.g.
  ///
  /// - [GridIterator.current]
  /// - [GridIterator.position]
  ///
  /// ## Implementing
  ///
  /// Depending on what kind of iterator is produced by [iterator], you may
  /// choose to create a specific more efficient kind of iterable. For example:
  ///
  /// - [GridIterator], use [GridImpl.forwardIterable].
  /// - [BidirectionalGridIterator], use [GridImpl.bidirectionalIterable].
  /// - [SeekableGridIterator], use [GridImpl.seekableIterable].
  ///
  /// The default implementation uses [GridImpl.forwardIterable].
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// Iterable<(int, int, T)> traverse<T>(Grid<T> grid, {(int, int)? start}) {
  ///   return GridImpl.forwardIterable(() => iterator(grid, start: start));
  /// }
  /// ```
  Iterable<(int, int, T)> traverse<T>(Grid<T> grid, {(int, int)? start}) {
    return GridImpl.forwardIterable(() => iterator(grid, start: start));
  }

  /// Returns an iterator that traverses a [grid] in a specific order.
  ///
  /// The order of traversal is determined by the specific implementation.
  ///
  /// The optional [start] parameter specifies the starting point of the
  /// traversal. If not provided, the traversal will start at a default point
  /// that makes sense for the specific implementation, and attempt to visit
  /// _all_ or _most_ elements in the grid, if possible.
  ///
  /// ## Implementing
  ///
  /// Some algorithms have different requirements for traversal.
  ///
  /// - If you only traverse _forwards_, return a [GridIterator].
  /// - If you traverse _backwards_, return a [BidirectionalGridIterator].
  /// - If you can can _seek_ forwards and backwards [SeekableGridIterator].
  GridIterator<T> iterator<T>(Grid<T> grid, {(int, int)? start});
}

final class _RowMajorTraversal implements GridTraversal {
  const _RowMajorTraversal(this._dx, this._dy);

  final int _dx;
  final int _dy;

  @override
  Iterable<(int, int, T)> traverse<T>(Grid<T> grid, {(int, int)? start}) {
    return GridImpl.seekableIterable(() => iterator(grid, start: start));
  }

  @override
  SeekableGridIterator<T> iterator<T>(Grid<T> grid, {(int, int)? start}) {
    final (x, y) = start ?? (0, 0);
    return _RowMajorIterator(grid, _dx, _dy, x, y);
  }
}

/// An iterator that walks the grid by applying a progressive step function.
///
/// Each time the iterator would advance beyond the horizontal bounds of the
/// grid, it will instead move to the next row and reset the x-coordinate to
/// the start or end of the row + the remainder of the x-coordinate step.
final class _RowMajorIterator<T> with SeekableGridIterator<T> {
  _RowMajorIterator(
    this._grid,
    this._dx,
    this._dy,
    int startX,
    int startY,
  )   : _x = startX - _dx,
        _y = startY - _dy;

  final Grid<T> _grid;
  final int _dx;
  final int _dy;

  int _x;
  int _y;

  @override
  T get current => _grid.getUnchecked(_x, _y);

  @override
  (int, int) get position => (_x, _y);

  @override
  bool seek(int step) {
    return switch (step) {
      > 0 => _seek(step, _dx, _dy),
      < 0 => _seek(-step, -_dx, -_dy),
      _ => _grid.containsXY(_x, _y),
    };
  }

  bool _seek(int times, int dx, int dy) {
    final w = _grid.width;
    var x = _x;
    var y = _y;

    for (var i = 0; i < times; i++) {
      // We are going to wrap x.
      final newX = x + dx;

      // We are not going to wrap y.
      y += dy;

      // If we are in the negatives, go the beginning of the previous row.
      if (newX < 0) {
        // It's possible it's multiple rows, so use %.
        y += newX ~/ w - 1;
        x = newX % w;
      } else if (newX >= w) {
        // It's possible it's multiple rows, so use %.
        y += newX ~/ w;
        x = newX % w;
      } else {
        x = newX;
      }
    }

    return _grid.containsXY(_x = x, _y = y);
  }
}

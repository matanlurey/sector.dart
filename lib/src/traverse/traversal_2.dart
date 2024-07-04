import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sector/sector.dart';
import 'package:sector/src/base/iterator.dart';

part 'impl/breadth_first.dart';
part 'impl/edges.dart';
part 'impl/line.dart';
part 'impl/neighbors.dart';
part 'impl/rect.dart';
part 'impl/row_major.dart';

/// An algorithim or strategy for traversing a grid.
///
/// This interface is used to define the order in which elements are visited
/// when iterating over a grid. For example, a row-major traversal will visit
/// each row in order from left to right, while a spiral traversal will visit
/// the elements in a spiral pattern starting from the center.
///
/// Grid traversals are immutable and stateless, and are used to produce a
/// (stateful) [GridIterator], which is used to iterate over the cells of a grid
/// according to the traversal strategy.
///
/// ## Examples
///
/// To use a traversal, call the `traverse` method on the grid with the desired
/// type of traversal. For example, to iterate over a grid in row-major order:
/// ```dart
/// final grid = ListGrid.fromRows([
///   ['a', 'b'],
///   ['c', 'd'],
/// ]);
/// for (final cell in grid.traverse(GridTraversal.rowMajor())) {
///   print(cell);
/// }
/// ```
///
/// The output of the example is:
///
/// ```txt
/// a
/// b
/// c
/// d
/// ```
@immutable
abstract interface class GridTraversal {
  /// Creates a grid traversal from the given [traversal] function.
  ///
  /// This constructor is suitable for simple grid traversal strategies that
  /// can be defined as a single function, i.e. do not require any additional
  /// configuration or parameters; for more complex strategies implement the
  /// [GridTraversal] interface directly.
  const factory GridTraversal.from(
    GridIterator<T> Function<T>(Grid<T> grid) traversal,
  ) = _GridTraversal;

  /// Creates a traversal that visits each cell in the grid breadth-first.
  ///
  /// This traversal visits each cell in the grid in a breadth-first order
  /// starting from the given position. The traversal will visit each cell in
  /// the grid exactly once.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.breadthFirst(1, 1))) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 5
  /// 2
  /// 8
  /// 4
  /// 6
  /// 1
  /// 3
  /// 7
  /// 9
  /// ```
  const factory GridTraversal.breadthFirst(
    int x,
    int y,
  ) = _BreadthFirstTraversal;

  /// Creates a traversal that visits each cell intersected by a line.
  ///
  /// This traversal draws a line between two positions using Bresenham's line
  /// algorithm. The line is drawn from the start position to the end position
  /// and the traversal will visit each cell that the line passes through.
  ///
  /// Optionally, the [inclusive] parameter can be set to `false` to exclude the
  /// end position from the traversal, otherwise the end position will be
  /// included.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.line(0, 0, 2, 2))) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 1
  /// 5
  /// 9
  /// ```
  const factory GridTraversal.line(
    int x1,
    int y1,
    int x2,
    int y2, {
    bool inclusive,
  }) = _LineGridTraveral;

  /// Creates a traversal that visits a rectangle's-worth of cells.
  ///
  /// This traversal draws a rectangle between a [top] and [left] position, and
  /// a [width] and [height] from that position. The traversal will visit each
  /// cell that the (filled) rectangle passes through.
  ///
  /// TODO: For just the edges of the rectangle, see [GridTraversal.edges].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.rect(0, 0, 2, 2))) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 1
  /// 2
  /// 4
  /// 5
  /// ```
  const factory GridTraversal.rect(
    int left,
    int top,
    int width,
    int height,
  ) = _RectGridTraversal;

  /// Creates a traversal that visits edges of the grid.
  ///
  /// This traversal visits the edges of the grid in a clockwise order starting
  /// from the top-left corner corner of the grid. The traversal will visit each
  /// edge of the grid exactly once.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.edges())) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 1
  /// 2
  /// 3
  /// 6
  /// 9
  /// 8
  /// 7
  /// 4
  /// ```
  const factory GridTraversal.edges() = _EdgesGridTraveral;

  /// Creates a traversal that returns the neighbors of the given position.
  ///
  /// The neighbors are returned in order of the compass directions: north,
  /// east, south, west, with missing neighbors (due to bounds checking)
  /// omitted from the results.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.neighbors(1, 1))) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 2
  /// 6
  /// 8
  /// 4
  /// ```
  const factory GridTraversal.neighbors(
    int x,
    int y,
  ) = _NeighborsTraversal.adjacent;

  /// Creates a traversal that returns the neighbors of the given position.
  ///
  /// The neighbors are returned in order of the compass directions with
  /// diagonals included: north, north east, east, south east, south, south
  /// west, west, north west, with missing neighbors (due to bounds checking)
  /// omitted from the results.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.neighborsDiagonal(1, 1))) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 2
  /// 3
  /// 6
  /// 9
  /// 8
  /// 7
  /// 4
  /// 1
  /// ```
  const factory GridTraversal.neighborsDiagonal(
    int x,
    int y,
  ) = _NeighborsTraversal.diagonal;

  /// A traversal that visits each cell in the grid in row-major order.
  ///
  /// This traversal visits each cell in the grid in row-major order, starting
  /// from the given [start] position. The traversal will visit each cell in the
  /// grid exactly once.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [1, 2, 3],
  ///   [4, 5, 6],
  ///   [7, 8, 9],
  /// ]);
  /// for (final cell in grid.traverse(GridTraversal.rowMajor()) {
  ///   print(cell);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// 1
  /// 2
  /// 3
  /// 4
  /// 5
  /// 6
  /// 7
  /// 8
  /// 9
  /// ```
  const factory GridTraversal.rowMajor({
    (int, int) start,
  }) = _RowMajorGridTraveral;

  /// Returns a [GridIterator] that will traverse the given [grid].
  ///
  /// The returned iterator will traverse the grid according to the strategy
  /// defined by this traversal, starting at whatever is the logical starting
  /// point for the traversal; some strategies may provide additional options
  /// for specifying the starting point.
  GridIterator<T> traverse<T>(Grid<T> grid);
}

final class _GridTraversal implements GridTraversal {
  const _GridTraversal(this._traversal);
  final GridIterator<T> Function<T>(Grid<T> grid) _traversal;

  @override
  GridIterator<T> traverse<T>(Grid<T> grid) => _traversal(grid);
}

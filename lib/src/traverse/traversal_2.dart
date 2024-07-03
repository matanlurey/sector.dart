import 'dart:io';

import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

part 'impl/draw_line.dart';
part 'impl/edges.dart';

/// An algorithim or strategy for traversing a grid.
///
/// Grid traversals are immutable and stateless, and are used to produce a
/// (stateful) [GridIterator], which is used to iterate over the cells of a grid
/// according to the traversal strategy.
@immutable
abstract interface class GridTraversal {
  /// Creates a new grid traversal from the given [traversal] function.
  ///
  /// This constructor is suitable for simple grid traversal strategies that
  /// can be defined as a single function, i.e. do not require any additional
  /// configuration or parameters; for more complex strategies implement the
  /// [GridTraversal] interface directly.
  @literal
  const factory GridTraversal.from(
    GridIterator<T> Function<T>(Grid<T> grid) traversal,
  ) = _GridTraversal;

  /// A traversal that draws a line between two positions.
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
  /// for (final cell in grid.traverse(GridTraversal.drawLine(0, 0, 2, 2))) {
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
  factory GridTraversal.drawLine(
    int x1,
    int y1,
    int x2,
    int y2, {
    bool inclusive,
  }) = _DrawLineGridTraveral;

  /// A traversal that visits edges of the grid.
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
  @literal
  const factory GridTraversal.edges() = _EdgesGridTraveral;

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

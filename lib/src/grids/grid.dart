import 'package:sector/sector.dart';

// ignore: unused_import
import 'package:sector/src/_dartdoc_macros.dart';

/// A data structure representing a 2-dimensional grid of elements of type [T].
///
/// Where as a [List] is a 1-dimensional data structure of elements, a [Grid] is
/// a 2-dimensional data structure of elements, where each element is accessed
/// by its `x` and `y` coordinates ([get], [set], [containsXY]).
///
/// The `x` and `y` coordinates are zero-based, where `x` is the horizontal
/// axis and `y` is the vertical axis. The origin `(0, 0)` is at the top-left
/// corner of the grid, and [width] and [height] are the number of columns and
/// rows in the grid, respectively.
///
/// ## Layout
///
/// The internal layout of a grid may vary, including row-major order,
/// column-major order, or even a sparse layout. The only requirement is that
/// the grid must be able to store elements at any `x` and `y` coordinates
/// within the bounds of the grid.
///
/// The _default_ implementation (i.e. the grid returned by the constructors) is
/// a row-major dense grid, where each row is stored contiguously in memory.
/// This is the most common layout for a grid, and is the most efficient for
/// most use-cases.
///
/// See [ListGrid] for details.
///
/// ## Examples
///
/// Creating a 3x3 grid with all elements set to `0`:
/// ```dart
/// final grid = Grid.filled(3, 3, 0);
/// // 0 0 0
/// // 0 0 0
/// // 0 0 0
/// ```
///
/// Setting the element at `(1, 1)` to `1`:
/// ```dart
/// final grid = Grid.filled(3, 3, 0);
/// // 0 0 0
/// // 0 0 0
/// // 0 0 0
///
/// grid.set(1, 1, 1);
/// // 0 0 0
/// // 0 1 0
/// // 0 0 0
/// ```
///
/// Iterating over each row in a grid:
/// ```dart
/// final grid = Grid.filled(3, 3, 0);
/// // 0 0 0
/// // 0 0 0
/// // 0 0 0
///
/// for (final row in grid.rows) {
///   print(row);
/// }
/// // [0, 0, 0]
/// // [0, 0, 0]
/// // [0, 0, 0]
/// ```
///
/// ## Implementing
///
/// [Grid] is a _mixin class_, meaning it can either be implemented from scratch
/// or extended or mixed into an existing class in order to inherit some methods
/// that are derived from other methods.
abstract mixin class Grid<T> {
  /// Creates a new grid with the provided [width] and [height].
  ///
  /// The grid is initialized with all elements set to [fill].
  ///
  /// The [width] and [height] must be non-negative.
  ///
  /// If either dimension is `0`, an [Grid.empty] is returned.
  factory Grid.filled(
    int width,
    int height,
    T fill,
  ) = ListGrid<T>.filled;

  /// Creates a new grid with the provided [width] and [height].
  ///
  /// The grid is initialized with elements generated by the provided
  /// [generator], where the element at index `(x, y)` is `generator(x, y)`.
  ///
  /// The [width] and [height] must be non-negative.
  ///
  /// If either dimension is `0`, an [Grid.empty] is returned.
  factory Grid.generate(
    int width,
    int height,
    T Function(int x, int y) generator,
  ) = ListGrid<T>.generate;

  /// Creates a new grid from an existing [grid].
  ///
  /// The new grid is a shallow copy of the original grid.
  factory Grid.from(Grid<T> grid) = ListGrid<T>.from;

  /// Creates a new grid from the provided [cells].
  ///
  /// The grid will have a width equal to the provided [width], and a height
  /// equal to the number of cells divided by the width, which must be an
  /// integer.
  ///
  /// The grid is initialized with the elements in the cells, where the element
  /// at index `(x, y)` is `cells[y * width + x]`.
  ///
  /// If [width] is `0`, an [Grid.empty] is returned.
  factory Grid.fromCells(
    Iterable<T> cells, {
    required int width,
  }) = ListGrid<T>.fromCells;

  /// Creates a new grid from the provided [rows].
  ///
  /// Each row must have the same length, and the grid will have a width equal
  /// to the length of the first row, and a height equal to the number of rows.
  ///
  /// The grid is initialized with the elements in the rows, where the element
  /// at index `(x, y)` is `rows[y][x]`.
  factory Grid.fromRows(
    Iterable<Iterable<T>> rows,
  ) = ListGrid<T>.fromRows;

  /// Creates a new grid from the provided [columns].
  ///
  /// Each column must have the same length, and the grid will have a width
  /// equal to the number of columns, and a height equal to the length of the
  /// first column.
  ///
  /// The grid is initialized with the elements in the columns, where the
  /// element at index `(x, y)` is `columns[x][y]`.
  factory Grid.fromColumns(
    Iterable<Iterable<T>> columns,
  ) = ListGrid<T>.fromColumns;

  /// Creates a new empty grid.
  ///
  /// The grid has a width and height of `0` and will not contain any elements.
  factory Grid.empty() = ListGrid<T>.empty;

  /// Width of the grid, in _columns_.
  ///
  /// This is the number of columns in the grid, where each column is a vertical
  /// slice of the grid. The width is the maximum `x` coordinate that can be
  /// accessed in the grid.
  ///
  /// The width is always greater than or equal to `0`, where `0` indicates an
  /// empty grid. If the width is `0`, then the height is also `0`.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// print(grid.width); // 3
  /// ```
  int get width;

  /// Height of the grid, in _rows_.
  ///
  /// This is the number of rows in the grid, where each row is a horizontal
  /// slice of the grid. The height is the maximum `y` coordinate that can be
  /// accessed in the grid.
  ///
  /// The height is always greater than or equal to `0`, where `0` indicates an
  /// empty grid. If the height is `0`, then the width is also `0`.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// print(grid.height); // 3
  /// ```
  int get height;

  /// Returns `true` if the grid is empty.
  ///
  /// A grid is considered empty if it has no elements.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// print(grid.isEmpty); // false
  ///
  /// final empty = Grid.filled(0, 0, 0);
  /// print(empty.isEmpty); // true
  /// ```
  bool get isEmpty => width == 0 || height == 0;

  /// Returns `true` if the grid contains the provided [element].
  ///
  /// The equality of the elements is determined by the `==` operator.
  bool contains(T element) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (getUnchecked(x, y) == element) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns `true` if the grid contains an element at the given [x] and [y].
  ///
  /// The `x` and `y` coordinates are zero-based, where `x` is the horizontal
  /// axis and `y` is the vertical axis. The origin `(0, 0)` is at the top-left
  /// corner of the grid.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// print(grid.containsXY(1, 1)); // true
  /// print(grid.containsXY(3, 3)); // false
  /// ```
  bool containsXY(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  /// Returns `true` if the grid contains the bounds provided.
  ///
  /// The bounds are inclusive, where the `x` and `y` coordinates are
  /// zero-based, and the `width` and `height` are the number of columns and
  /// rows, respectively.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// print(grid.containsXYWH(1, 1, 1, 1)); // true
  /// print(grid.containsXYWH(2, 2, 2, 2)); // false
  /// ```
  bool containsXYWH(int x, int y, int width, int height) {
    return containsXY(x, y) && containsXY(x + width - 1, y + height - 1);
  }

  /// Returns the element at the given [x] and [y].
  ///
  /// The `x` and `y` coordinates are zero-based, where `x` is the horizontal
  /// axis and `y` is the vertical axis. The origin `(0, 0)` is at the top-left
  /// corner of the grid.
  ///
  /// If the coordinates are out of bounds, this method throws.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// print(grid.get(1, 1)); // 0
  /// print(grid.get(3, 3)); // throws
  /// ```
  T get(int x, int y) {
    GridImpl.checkBoundsExclusive(this, x, y);
    return getUnchecked(x, y);
  }

  /// Returns the element at the given [x] and [y].
  ///
  /// The `x` and `y` coordinates are zero-based, where `x` is the horizontal
  /// axis and `y` is the vertical axis. The origin `(0, 0)` is at the top-left
  /// corner of the grid.
  ///
  /// If the coordinates are out of bounds, the behavior is undefined.
  ///
  /// > [!WARNING]
  /// > Use this method with caution, as it may lead to undefined behavior if
  /// > the coordinates are out of bounds. It is recommended to use [get]
  /// > instead.
  T getUnchecked(int x, int y);

  /// Sets the element at the given [x] and [y] to [value].
  ///
  /// The `x` and `y` coordinates are zero-based, where `x` is the horizontal
  /// axis and `y` is the vertical axis. The origin `(0, 0)` is at the top-left
  /// corner of the grid.
  ///
  /// If the coordinates are out of bounds, this method throws.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// grid.set(1, 1, 1);
  /// print(grid.get(1, 1)); // 1
  /// ```
  void set(int x, int y, T value) {
    GridImpl.checkBoundsExclusive(this, x, y);
    setUnchecked(x, y, value);
  }

  /// Sets the element at the given [x] and [y] to [value].
  ///
  /// The `x` and `y` coordinates are zero-based, where `x` is the horizontal
  /// axis and `y` is the vertical axis. The origin `(0, 0)` is at the top-left
  /// corner of the grid.
  ///
  /// If the coordinates are out of bounds, the behavior is undefined.
  ///
  /// > [!WARNING]
  /// > Use this method with caution, as it may lead to undefined behavior if
  /// > the coordinates are out of bounds. It is recommended to use [set]
  /// > instead.
  void setUnchecked(int x, int y, T value);

  /// Clears all elements in the grid, making it empty.
  ///
  /// {@macro warn-grid-might-not-be-growable}
  void clear() {
    final rows = this.rows;
    while (isNotEmpty) {
      rows.removeLast();
    }
  }

  /// All rows in the grid, from top to bottom.
  ///
  /// This is an iterable of all rows in the grid, where each row is an iterable
  /// of elements in the row. The rows are ordered from top to bottom, where the
  /// first row is at the top of the grid, and the elements in each row are
  /// ordered from left to right.
  ///
  /// ## Performance
  ///
  /// Depending on the implementation of the grid, this method may be more or
  /// less efficient. For example, a row-major grid may have a more efficient
  /// implementation of this method than a column-major grid.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// for (final row in grid.rows) {
  ///   print(row);
  /// }
  /// // [0, 0, 0]
  /// // [0, 0, 0]
  /// // [0, 0, 0]
  /// ```
  GridAxis<T> get rows;

  /// All columns in the grid, from left to right.
  ///
  /// This is an iterable of all columns in the grid, where each column is an
  /// iterable of elements in the column. The columns are ordered from left to
  /// right, where the first column is at the left of the grid, and the elements
  /// in each column are ordered from top to bottom.
  ///
  /// ## Performance
  ///
  /// Depending on the implementation of the grid, this method may be more or
  /// less efficient. For example, a column-major grid may have a more efficient
  /// implementation of this method than a row-major grid.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 3, 0);
  /// for (final column in grid.columns) {
  ///   print(column);
  /// }
  /// // [0, 0, 0]
  /// // [0, 0, 0]
  /// // [0, 0, 0]
  /// ```
  GridAxis<T> get columns;

  /// Returns an iterable that traverses the grid in a specific [order].
  ///
  /// The order of the traversal is determined by the provided [order], which
  /// is a [Traversal] implementation. If not provided, the default order is
  /// determined by the specific implementation of the grid, often row-major.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid.generate(2, 2, (x, y) => (x, y));
  /// for (final (x, y, element) in grid.traverse(rowMajor())) {
  ///   print(element);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// (0, 0)
  /// (1, 0)
  /// (0, 1)
  /// (1, 1)
  /// ```
  R traverse<R>(Traversal<R, T> order) => order(this);

  /// Returns a _new_ grid with a shallow copy of the provided bounds.
  ///
  /// The new grid is a sub-grid of the original grid, where the top-left corner
  /// of the sub-grid is at `(left, top)`, and the width and height of the sub-
  /// grid are `width` and `height`, respectively.
  ///
  /// Throws if the bounds are out of range.
  Grid<T> subGrid({
    int left = 0,
    int top = 0,
    int? width,
    int? height,
  }) {
    width ??= this.width - left;
    height ??= this.height - top;
    GridImpl.checkBoundsXYWH(this, left, top, width, height);

    return Grid.generate(width, height, (x, y) => get(left + x, top + y));
  }

  /// Returns a _delegate_ grid that performs operations relative to this grid.
  ///
  /// The view is a sub-grid of the original grid, where the top-left corner of
  /// the view is at `(left, top)`, and the width and height of the view are
  /// `width` and `height`, respectively.
  ///
  /// Throws if the bounds are out of range.
  Grid<T> asSubGrid({
    int left = 0,
    int top = 0,
    int? width,
    int? height,
  }) {
    return GridImpl.subGridView(
      this,
      left: left,
      top: top,
      width: width,
      height: height,
    );
  }

  @override
  String toString() => GridImpl.debugString(this);
}

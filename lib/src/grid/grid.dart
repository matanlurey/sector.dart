import 'package:sector/sector.dart';
import 'package:sector/src/internal.dart';

/// A collection of elements accessible by a two-dimensional coordinate [Pos].
///
/// The elements of the grid are organized in a two-dimensional structure, where
/// each element is accessed by a `x` and `y` coordinate, represented by [Pos],
/// which are zero-based indices where `x` represents the column, `y` the row,
/// the origin `(0, 0)` is the top-left corner of the grid, and [width] and
/// [height] are the number of columns and rows respectively.
///
/// ## Performance
///
/// A grid is a potentially complex data structure, and the performance of
/// operations can vary depending on the implementation. For example, a
/// [ListGrid], backed by a 1-dimensional list, will have different performance
/// characteristics than a grid backed by a sparse data structure.
///
/// ## Implementing
///
/// Most users will not need to implement this interface, and will instead use
/// the factory methods provided by [Grid], such as [Grid.filled] or
/// [Grid.fromRows].
///
/// If you do need to implement this interface, you should consider _mixing in_
/// this interface to receive a default implementation of most methods, and then
/// implement the remaining methods:
///
/// ```dart
/// class MyGrid<T> with Grid<T> {
///   @override
///   int get width => /* ... */;
///
///   @override
///   int get height => /* ... */;
///
///   @override
///   T getUnchecked(Pos pos) => /* ... */;
///
///   @override
///   void setUnchecked(Pos pos, T element) => /* ... */;
/// }
/// ```
///
/// ## Example
///
/// ```dart
/// final grid = GridBuffer.fromRows([
///   [Tile.wall, Tile.wall, Tile.wall],
///   [Tile.wall, Tile.floor, Tile.wall],
/// ]);
/// print(grid.width); // 3
/// print(grid.height); // 2
/// print(grid.get(Pos(1, 1))); // Tile.floor
/// ```
abstract mixin class Grid<T> {
  /// Creates a new grid with the given [width] and [height].
  ///
  /// Each element of the grid is initialized to [fill].
  ///
  /// The [width] and [height] must be non-negative.
  ///
  /// ## Example
  ///
  /// This constructor is optimal for grids that start with a single element
  /// repeated across the entire grid, such as incremental or imperatively
  /// built grids.
  ///
  /// ```dart
  /// final grid = Grid.filled(3, 2, Tile.floor);
  /// print(grid.width); // 3
  /// print(grid.height); // 2
  /// print(grid.get(Pos(1, 1))); // Tile.floor
  ///
  /// // Now do things with the grid...
  /// ```
  factory Grid.filled(
    int width,
    int height,
    T fill,
  ) = ListGrid.filled;

  /// Creates a new grid with the given [width] and [height].
  ///
  /// Each element of the grid is generated by calling [generator] with the
  /// position of the element, where the element at position `(x, y)` is
  /// `generator(Pos(x, y))`.
  ///
  /// The [width] and [height] must be non-negative.
  ///
  /// ## Example
  ///
  /// This constructor is optimal for grids that are generated based on a
  /// function, such as procedural generation or mapping to another data source
  /// with efficient position-based access.
  ///
  /// ```dart
  /// final grid = Grid.generate(3, 2, (pos) {
  ///   return _database.getTileAt(pos.x, pos.y);
  /// });
  /// ```
  factory Grid.generate(
    int width,
    int height,
    T Function(Pos) generator,
  ) = ListGrid.generate;

  /// Creates a new grid with the same elements and positions as [other].
  ///
  /// The new grid is a shallow copy of the existing grid.
  ///
  /// ## Example
  ///
  /// This constructor is optimal for creating a new grid with the same elements
  /// as an existing grid, such as when a defensive copy of a grid is needed and
  /// the grid is not known to be a specific implementation.
  ///
  /// ```dart
  /// final grid = GridBuffer.fromGrid(otherGrid);
  /// ```
  factory Grid.fromGrid(Grid<T> other) = ListGrid.fromGrid;

  /// Creates a new grid from the provided [rows] of columns of elements.
  ///
  /// Each element in `rows`, a column, must have the same length, and the
  /// resulting grid will have a width equal to the number of columns, and a
  /// height equal to the length of each column.
  ///
  /// The grid is initialized with the elements in the rows, where the element
  /// at index `(x, y)` is `rows.elementAt(y).elementAt(x)`.
  ///
  /// ## Example
  ///
  /// This constructor is optimal for creating a grid from a list of rows, such
  /// as for simple examples or tests, as nested lists are a very readale way to
  /// encode a grid:
  ///
  /// ```dart
  /// final grid = Grid.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// ```
  factory Grid.fromRows(
    Iterable<Iterable<T>> rows,
  ) = ListGrid.fromRows;

  /// Creates a new grid from the provided [elements] in row-major order.
  ///
  /// The grid will have a width of [width], and the number of rows is
  /// determined by the number of elements divided by the width, which must be
  /// an integer.
  ///
  /// ## Example
  ///
  /// This constructor is optimal for creating a grid from an iterable or list
  /// of elements that is already in row-major order, such as when the elements
  /// were natively stored in a list-like format and the width is known:
  ///
  /// ```dart
  /// final grid = Grid.fromIterable([0, 1, 2, 3, 4, 5], width: 3);
  /// print(grid.width); // 3
  /// print(grid.height); // 2
  /// print(grid.get(Pos(1, 1))); // 4
  /// ```
  factory Grid.fromIterable(
    Iterable<T> elements, {
    required int width,
  }) = ListGrid.fromIterable;

  /// Creates a new empty grid.
  ///
  /// The grid has a width and height of `0` and will not contain any elements.
  const factory Grid.empty() = ListGrid.empty;

  /// Number of columns in the grid.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.width); // 3
  /// ```
  int get width;

  /// Number of rows in the grid.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.height); // 2
  /// ```
  int get height;

  /// Whether the grid is empty, i.e. has no elements.
  ///
  /// A grid is considered empty if its [width] or [height] is zero.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([]);
  /// print(grid.isEmpty); // true
  ///
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.isEmpty); // false
  /// ```
  bool get isEmpty => width == 0 || height == 0;

  /// Whether the grid is not empty, i.e. has elements.
  ///
  /// A grid is considered not empty if both [width] and [height] are non-zero.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.isNotEmpty); // true
  ///
  /// final grid = GridBuffer.fromRows([]);
  /// print(grid.isNotEmpty); // false
  /// ```
  bool get isNotEmpty => !isEmpty;

  /// Returns whether the grid contains an element equal to [element].
  ///
  /// This operation will typically check _each_ element using [Object.==].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.contains(Tile.floor)); // true
  /// print(grid.contains(Tile.door)); // false
  bool contains(T element) {
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (getUnchecked(Pos(x, y)) == element) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns whether [pos] is within the bounds of the grid.
  ///
  /// A position is considered within the bounds of the grid if:
  /// - `0 <= pos.x < width`;
  /// - `0 <= pos.y < height`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.containsPos(Pos(0, 0))); // true
  /// print(grid.containsPos(Pos(2, 1))); // true
  /// print(grid.containsPos(Pos(3, 0))); // false
  /// ```
  bool containsPos(Pos pos) => toRect().contains(pos);

  /// Returns whether [rect] is within the bounds of the grid.
  ///
  /// A rectangle is considered within the bounds of the grid if:
  /// - `0 <= rect.left < width`;
  /// - `0 <= rect.right <= width`;
  /// - `0 <= rect.top < height`;
  /// - `0 <= rect.bottom <= height`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.containsRect(Rect.fromLTWH(0, 0, 3, 2))); // true
  /// print(grid.containsRect(Rect.fromLTWH(1, 0, 2, 2))); // true
  /// print(grid.containsRect(Rect.fromLTWH(0, 0, 4, 2))); // false
  /// ```
  bool containsRect(Rect rect) => toRect().containsRect(rect);

  /// Returns the element at the given position in the grid.
  ///
  /// Must provide a valid position within the bounds of the grid, which means
  /// [containsPos] must return `true` for the given position.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.get(Pos(0, 0))); // Tile.wall
  /// print(grid.get(Pos(1, 1))); // Tile.floor
  /// ```
  T get(Pos pos) {
    if (!containsPos(pos)) {
      throw RangeError('$pos is out of bounds');
    }
    return getUnchecked(pos);
  }

  /// Returns the element at the given position in the grid.
  ///
  /// If the position is not within the bounds of the grid, the behavior is
  /// undefined. This method is intended to be used in cases where the position
  /// can be trusted, such as an iterator or other trusted synchronous
  /// operation.
  ///
  /// ## Example
  ///
  /// ```dart
  /// for (var y = 0; y < grid.height; y++) {
  ///   for (var x = 0; x < grid.width; x++) {
  ///     final pos = Pos(x, y);
  ///
  ///     // Safe because we are implicitly checking the bounds.
  ///     print(grid.getUnchecked(pos));
  ///   }
  /// }
  /// ```
  T getUnchecked(Pos pos);

  /// Sets the element at the given position in the grid.
  ///
  /// The new element is then reflected on calls such as [get] or [contains].
  ///
  ///M ust provide a valid position within the bounds of the grid which means
  /// [containsPos] must return `true` for the given position.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// grid.set(Pos(1, 1), Tile.door);
  /// print(grid.get(Pos(1, 1))); // Tile.door
  /// ```
  void set(Pos pos, T element) {
    // TODO: Refactor out into common errors/methods.
    if (!containsPos(pos)) {
      throw RangeError('$pos is out of bounds');
    }
    return setUnchecked(pos, element);
  }

  /// Sets the element at the given position in the grid.
  ///
  /// If the position is not within the bounds of the grid, the behavior is
  /// undefined. This method is intended to be used in cases where the position
  /// can be trusted, such as an iterator or other trusted synchronous
  /// operation.
  ///
  /// ## Example
  ///
  /// ```dart
  /// for (var y = 0; y < grid.height; y++) {
  ///   for (var x = 0; x < grid.width; x++) {
  ///     final pos = Pos(x, y);
  ///
  ///     // Safe because we are implicitly checking the bounds.
  ///     grid.setUnchecked(pos, Tile.floor);
  ///   }
  /// }
  /// ```
  void setUnchecked(Pos pos, T element);

  /// Rows of the grid.
  ///
  /// An iterable of rows, where each row is an iterable representing the
  /// columns of that particular row, in the order they appear in the grid;
  /// the first row is the top-most row, and the last row is the bottom-most
  /// row.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.rows.first); // [Tile.wall, Tile.wall, Tile.wall]
  /// print(grid.rows.last); // [Tile.wall, Tile.floor, Tile.wall]
  /// ```
  Iterable<Iterable<T>> get rows => _Rows(this);

  /// Columns of the grid.
  ///
  /// An iterable of columns, where each column is an iterable representing the
  /// rows of that particular column, in the order they appear in the grid;
  /// the first column is the left-most column, and the last column is the
  /// right-most column.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = GridBuffer.fromRows([
  ///   [Tile.wall, Tile.wall, Tile.wall],
  ///   [Tile.wall, Tile.floor, Tile.wall],
  /// ]);
  /// print(grid.columns.first); // [Tile.wall, Tile.wall]
  /// print(grid.columns.last); // [Tile.wall, Tile.wall]
  /// ```
  Iterable<Iterable<T>> get columns => _Columns(this);

  /// Returns a rectangle representing the bounds of the grid.
  ///
  /// The rectangle is positioned at `(0, 0)`, unless [topLeft] is specified.
  Rect toRect({Pos topLeft = Pos.zero}) {
    return Rect.fromLTWH(topLeft.x, topLeft.y, width, height);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('┌${'─' * (width * 2 + 1)}┐');
    for (var y = 0; y < height; y++) {
      buffer.write('│');
      for (var x = 0; x < width; x++) {
        buffer.write(' ${getUnchecked(Pos(x, y))}');
      }
      buffer.writeln(' │');
    }
    buffer.write('└${'─' * (width * 2 + 1)}┘');
    return buffer.toString();
  }
}

final class _Rows<E> extends FixedLengthIterable<Iterable<E>> {
  const _Rows(this._grid);
  final Grid<E> _grid;

  @override
  int get length => _grid.height;

  @override
  Iterable<E> elementAt(int index) {
    return Iterable.generate(_grid.width, (x) {
      return _grid.getUnchecked(Pos(x, index));
    });
  }
}

final class _Columns<E> extends FixedLengthIterable<Iterable<E>> {
  const _Columns(this._grid);
  final Grid<E> _grid;

  @override
  int get length => _grid.width;

  @override
  Iterable<E> elementAt(int index) {
    return Iterable.generate(_grid.height, (y) {
      return _grid.getUnchecked(Pos(index, y));
    });
  }
}

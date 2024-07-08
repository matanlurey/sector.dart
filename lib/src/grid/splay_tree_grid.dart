import 'dart:collection';

import 'package:sector/sector.dart';
import 'package:sector/src/internal.dart';

/// A sparse grid implementation using a [SplayTreeMap] to store elements.
///
/// This implementation is a sparse grid, where elements are stored in row-major
/// order, but with elements matching the result of [Object.==] with [fill]
/// omitted from memory.
///
/// ## Examples
///
/// The following grid:
///
/// ```dart
/// final grid = SplayTreeGrid.fromRows([
///   ['a', ' ', 'b'],
///   ['c', ' ', ' '],
///   [' ', ' ', 'd'],
/// ]);
/// print(grid.asSparseMap());
/// ```
///
/// Produces the following output:
///
/// ```txt
/// {0: a, 2: b, 3: c, 8: d}
/// ```
///
/// {@category Grids}
final class SplayTreeGrid<T> with Grid<T> {
  /// Creates a new grid with the given [width] and [height].
  ///
  /// Each element of the grid is initialized to [fill].
  ///
  /// The [width] and [height] must be non-negative.
  factory SplayTreeGrid.filled(int width, int height, T fill) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');

    return SplayTreeGrid._(
      SplayTreeMap<Pos, T>(Pos.byRowMajor),
      width: width,
      height: height,
      fill: fill,
    );
  }

  /// Creates a new grid with the given [width] and [height].
  ///
  /// Each element of the grid is generated by calling [generator] with the
  /// position of the element, where the element at position `(x, y)` is
  /// `generator(Pos(x, y))`. The [fill] element is omitted from the grid's
  /// memory.
  ///
  /// The [width] and [height] must be non-negative.
  factory SplayTreeGrid.generate(
    int width,
    int height,
    T Function(Pos) generator, {
    required T fill,
  }) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');

    final elements = SplayTreeMap<Pos, T>(Pos.byRowMajor);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final position = Pos(x, y);
        final element = generator(position);
        if (element != fill) {
          elements[position] = element;
        }
      }
    }

    return SplayTreeGrid._(
      elements,
      width: width,
      height: height,
      fill: fill,
    );
  }

  /// Creates a new grid with the same elements and positions as [other].
  ///
  /// The new grid is a shallow copy of the existing grid.
  ///
  /// The [fill] element is omitted from the grid's memory.
  factory SplayTreeGrid.fromGrid(Grid<T> other, {required T fill}) {
    if (other is SplayTreeGrid<T>) {
      return SplayTreeGrid._(
        SplayTreeMap.of(other._elements, Pos.byRowMajor),
        width: other.width,
        height: other.height,
        fill: fill,
      );
    }

    return SplayTreeGrid.generate(
      other.width,
      other.height,
      other.getUnchecked,
      fill: fill,
    );
  }

  /// Creates a new grid from the provided [rows] of columns of elements.
  ///
  /// Each element in `rows`, a column, must have the same length, and the
  /// resulting grid will have a width equal to the number of columns, and a
  /// height equal to the length of each column.
  ///
  /// The grid is initialized with the elements in the rows, where the element
  /// at index `(x, y)` is `rows.elementAt(y).elementAt(x)`. The [fill] element
  /// is omitted from the grid's memory.
  ///
  /// If [fill] is not provided, the most common element in the rows is used.
  factory SplayTreeGrid.fromRows(Iterable<Iterable<T>> rows, {T? fill}) {
    final rowsList = List.of(rows);
    final rowsFlat = expandEqualLength(rowsList);
    return SplayTreeGrid.fromIterable(
      rowsFlat,
      width: rowsList.isEmpty ? 0 : rowsList.first.length,
      fill: fill ?? mostCommonElement(rowsFlat),
    );
  }

  /// Creates a new grid from the provided [elements] in row-major order.
  ///
  /// The grid will have a width of [width], and the number of rows is
  /// determined by the number of elements divided by the width, which must be
  /// an integer.
  ///
  /// The [fill] element is omitted from the grid's memory. If not provided,
  /// the most common element in the elements is used.
  factory SplayTreeGrid.fromIterable(
    Iterable<T> elements, {
    required int width,
    T? fill,
  }) {
    RangeError.checkNotNegative(width, 'width');
    final elementsList = List.of(elements);
    if (width != 0 && elementsList.length % width != 0) {
      throw ArgumentError(
        'The number of elements must be a multiple of the width.',
      );
    }

    final height = width == 0 ? 0 : elementsList.length ~/ width;
    return SplayTreeGrid.generate(
      width,
      height,
      (pos) => elementsList[rowMajor1D(pos, width: width)],
      fill: fill ?? mostCommonElement(elementsList),
    );
  }

  const SplayTreeGrid._(
    this._elements, {
    required int width,
    required int height,
    required this.fill,
  })  : width = height > 0 ? width : 0,
        height = width > 0 ? height : 0;

  final SplayTreeMap<Pos, T> _elements;

  @override
  final int width;

  @override
  final int height;

  /// Clears all elements from the grid to the default [fill] value.
  ///
  /// The grid retains its dimensions.
  void clear() {
    _elements.clear();
  }

  /// What element is omitted as the default value.
  final T fill;

  @override
  @pragma('vm:prefer-inline')
  T getUnchecked(Pos pos) {
    final result = _elements[pos];
    if (result == null) {
      if (result is T && _elements.containsKey(pos)) {
        return result;
      }
      return fill;
    }
    return result;
  }

  @override
  @pragma('vm:prefer-inline')
  void setUnchecked(Pos pos, T element) {
    if (element == fill) {
      _elements.remove(pos);
    } else {
      _elements[pos] = element;
    }
  }

  /// Returns an unmodfiable map view of the grid, with [fill] elements omitted.
  ///
  /// Each position is mapped to the element at that position, where the keys
  /// are positions in row-major order, and the values are the elements at that
  /// position.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final grid = SplayTreeGrid.fromRows([
  ///   ['a', ' ', 'b'],
  ///   ['c', ' ', ' '],
  /// ]);
  /// print(grid.asSparseMap()); // {0: a, 2: b, 3: c}
  /// ```
  Map<Pos, T> asSparseMap() => UnmodifiableMapView(_elements);
}

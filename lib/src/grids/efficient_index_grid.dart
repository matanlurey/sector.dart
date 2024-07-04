import 'package:sector/sector.dart';

/// A mixin that augments [Grid] to indicate it supports efficient index access.
///
/// This mixin is used to provide hints to algorithms about the internal layout
/// of the grid, which can be used to optimize performance for certain
/// operations, and provides a default implementation for [getUnchecked] and
/// [setUnchecked] based on the internal layout.
mixin EfficientIndexGrid<T> on Grid<T> {
  /// A hint to algorithms about the internal layout of the grid.
  LayoutHint get layoutHint;

  @override
  @pragma('vm:prefer-inline')
  T getUnchecked(Pos position) {
    final index = layoutHint.toIndex(position, width: width);
    return getByIndexUnchecked(index);
  }

  @override
  @pragma('vm:prefer-inline')
  void setUnchecked(Pos position, T value) {
    final index = layoutHint.toIndex(position, width: width);
    setByIndexUnchecked(index, value);
  }

  /// Given a grid of `width * height` cells, returns the nth-cell.
  ///
  /// This method is based on the internal layout of the grid.
  ///
  /// > [!WARNING]
  /// > Use this method with caution, as it may lead to undefined behavior if
  /// > the index is out of bounds. It is recommended to use [get] instead
  /// > unless writing performance-sensitive code with proper bounds checking.
  T getByIndexUnchecked(int index);

  /// Given a grid of `width * height` cells, sets the nth-cell to [value].
  ///
  /// This method is based on the internal layout of the grid.
  ///
  /// > [!WARNING]
  /// > Use this method with caution, as it may lead to undefined behavior if
  /// > the index is out of bounds. It is recommended to use [set] instead
  /// > unless writing performance-sensitive code with proper bounds checking.
  void setByIndexUnchecked(int index, T value);
}

/// Optional hint for the layout of the data in memory.
///
/// Can be used to optimize performance for certain operations.
abstract final class LayoutHint {
  /// Each cell is stored in an ordered block of memory in row-major order.
  ///
  /// In other words, `index = y * width + x`.
  static const LayoutHint rowMajorContiguous = _RowMajorContiguous();

  /// Whether the layout is row-major contiguous.
  bool get isRowMajorContiguous;

  /// Converts an [index], given the [width] of a grid, to a position.
  Pos toPosition(int index, {required int width});

  /// Converts a [position] to an `index`, given the [width] of a grid.
  int toIndex(Pos position, {required int width});
}

final class _RowMajorContiguous implements LayoutHint {
  const _RowMajorContiguous();

  @override
  @pragma('vm:prefer-inline')
  bool get isRowMajorContiguous => true;

  @override
  @pragma('vm:prefer-inline')
  Pos toPosition(int index, {required int width}) {
    return Pos(index % width, index ~/ width);
  }

  @override
  @pragma('vm:prefer-inline')
  int toIndex(Pos position, {required int width}) {
    return position.y * width + position.x;
  }
}

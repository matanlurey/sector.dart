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
  T getUnchecked(int x, int y) {
    final index = layoutHint.toIndex(x, y, width: width);
    return getByIndexUnchecked(index);
  }

  @override
  @pragma('vm:prefer-inline')
  void setUnchecked(int x, int y, T value) {
    final index = layoutHint.toIndex(x, y, width: width);
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

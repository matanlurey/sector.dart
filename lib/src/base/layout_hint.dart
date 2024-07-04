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

  /// Converts an [index], given the [width] of a grid, to a position `(x, y)`.
  (int x, int y) toPosition(int index, {required int width});

  /// Converts a position `(x, y)` to an `index`, given the [width] of a grid.
  int toIndex(int x, int y, {required int width});
}

final class _RowMajorContiguous implements LayoutHint {
  const _RowMajorContiguous();

  @override
  @pragma('vm:prefer-inline')
  bool get isRowMajorContiguous => true;

  @override
  @pragma('vm:prefer-inline')
  (int x, int y) toPosition(int index, {required int width}) {
    return (index % width, index ~/ width);
  }

  @override
  @pragma('vm:prefer-inline')
  int toIndex(int x, int y, {required int width}) {
    return y * width + x;
  }
}

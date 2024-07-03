/// Optional hint for the layout of the data in memory.
///
/// Can be used to optimize performance for certain operations.
enum LayoutHint {
  /// Each cell is stored in an ordered block of memory in row-major order.
  ///
  /// In other words, `index = y * width + x`.
  rowMajorContiguous,

  // Prevents the enum from being exhaustively checked.
  // ignore: unused_field
  _;

  /// Converts an [index], given the [width] of a grid, to a position `(x, y)`.
  (int x, int y) toPosition(int index, {required int width}) {
    switch (this) {
      case LayoutHint.rowMajorContiguous:
        return (index % width, index ~/ width);
      default:
        throw UnimplementedError();
    }
  }

  /// Converts a position `(x, y)` to an [index], given the [width] of a grid.
  int toIndex(int x, int y, {required int width}) {
    switch (this) {
      case LayoutHint.rowMajorContiguous:
        return y * width + x;
      default:
        throw UnimplementedError(); // coverage:ignore-line
    }
  }
}

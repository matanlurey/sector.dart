import '../../_prelude.dart';

import 'mutable_fixed.dart';

/// Runs a test suite that checks that operations that mutate fail.
void runUnmodifiableTestSuite<T>(
  Grid<T> Function() getGrid, {
  required T fill,
}) {
  runFixedSizeTestSuite(getGrid, fill: fill);

  test('.set should fail', () {
    final grid = getGrid();
    final cells = grid.traverse(GridTraversal.rowMajor()).toList();
    check(() => grid.set(Pos(0, 0), fill)).throws<UnsupportedError>();
    check(grid.traverse(GridTraversal.rowMajor())).deepEquals(cells);
  });

  test('.setUnchecked should fail', () {
    final grid = getGrid();
    final cells = grid.traverse(GridTraversal.rowMajor()).toList();
    check(() => grid.setUnchecked(Pos(0, 0), fill)).throws<UnsupportedError>();
    check(grid.traverse(GridTraversal.rowMajor())).deepEquals(cells);
  });
}

import '../_prelude.dart';

import '../src/suites/mutable_growable.dart';
import '../src/suites/mutable_in_place.dart';
import '../src/suites/read.dart';

void main() {
  runGrowableTestSuite(SplayTreeGrid.fromRows);
  runReadOnlyTestSuite(SplayTreeGrid.fromRows);
  runMutableInPlaceTestSuite(SplayTreeGrid.fromRows);

  test('SplayTreeGrid.generate can return an empty grid', () {
    final grid = SplayTreeGrid.generate(0, 0, (x, y) => x + y, fill: 0);
    check(grid)
      ..width.equals(0)
      ..height.equals(0);
  });

  test('SplayTreeGrid.from copies a grid', () {
    final grid = Grid.fromRows([
      [1, 2],
      [3, 4],
    ]);
    final copy = SplayTreeGrid.from(grid);
    check(copy.rows).deepEquals(grid.rows);
  });

  test('SplayTreeGrid.fromColumns can return an emtpy grid', () {
    final grid = SplayTreeGrid.fromColumns([]);
    check(grid)
      ..width.equals(0)
      ..height.equals(0);
  });

  test('SplayTreeGrid.fromColumns rewrites the layout', () {
    final grid = SplayTreeGrid.fromColumns([
      [1, 2],
      [3, 4],
    ]);
    check(grid).rows.deepEquals([
      [1, 3],
      [2, 4],
    ]);
  });

  test('SplayTreeGrid.fromRows throws if the rows are not rectangular', () {
    check(
      () => SplayTreeGrid.fromRows([
        [1, 2],
        [3],
      ]),
    ).throws<ArgumentError>();
  });

  test('SplayTreeGrid.fromColumns throws if the columns are not rectangular',
      () {
    check(
      () => SplayTreeGrid.fromColumns([
        [1, 2],
        [3],
      ]),
    ).throws<ArgumentError>();
  });
}

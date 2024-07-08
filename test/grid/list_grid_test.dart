import 'dart:typed_data';

import '../prelude.dart';
import 'suite.dart';

void main() {
  group('Grid.filled', () {
    runSuiteGridFilled(Grid.filled);
  });

  group('Grid.generate', () {
    runSuiteGridGenerate(Grid.generate);
  });

  group('Grid.fromGrid', () {
    runSuiteGridFromGrid(Grid.fromGrid);
  });

  group('Grid.fromRows', () {
    runSuiteGridFromRows(Grid.fromRows);
  });

  group('Grib.fromIterable', () {
    runSuiteGridFromIterable(Grid.fromIterable);
  });

  group('Grid.empty', () {
    runSuiteGridEmpty(Grid.empty);
  });

  group('Grid', () {
    runSuiteGridBody(Grid.fromRows);
  });

  group('ListGrid.backedBy', () {
    test('should create a grid backed by a Uint8List', () {
      final buffer = Uint8List(9);
      final grid = ListGrid.withList(buffer, width: 3);
      check(grid.rows).deepEquals([
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
      ]);

      grid.set(Pos(1, 1), 42);
      check(buffer).deepEquals([0, 0, 0, 0, 42, 0, 0, 0, 0]);
    });

    test(
      'should throw if the number of elements is not a multiple of width',
      () {
        final buffer = Uint8List(8);
        check(
          () => ListGrid.withList(buffer, width: 3),
        ).throws<ArgumentError>();
      },
    );
  });
}

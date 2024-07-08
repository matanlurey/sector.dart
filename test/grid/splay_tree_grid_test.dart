import '../prelude.dart';
import 'suite.dart';

void main() {
  group('SplayTreeGrid.filled', () {
    runSuiteGridFilled(SplayTreeGrid.filled);
  });

  group('SplayTreeGrid.generate', () {
    runSuiteGridGenerate(<T>(width, height, generator) {
      final T fill;
      if (T == int) {
        fill = 0 as T;
      } else if (T == String) {
        fill = '#' as T;
      } else {
        throw ArgumentError('Unsupported type: $T');
      }
      return SplayTreeGrid.generate(
        width,
        height,
        generator,
        fill: fill,
      );
    });
  });

  group('SplayTreeGrid.fromGrid', () {
    runSuiteGridFromGrid(<T>(Grid<T> other) {
      final T fill;
      if (T == int) {
        fill = 0 as T;
      } else if (T == String) {
        fill = '#' as T;
      } else {
        throw ArgumentError('Unsupported type: $T');
      }
      return SplayTreeGrid.fromGrid(other, fill: fill);
    });
  });

  group('SplayTreeGrid.fromGrid(<SplayTreeGrid>)', () {
    runSuiteGridFromGrid(<T>(Grid<T> other) {
      final T fill;
      if (T == int) {
        fill = 0 as T;
      } else if (T == String) {
        fill = '#' as T;
      } else {
        throw ArgumentError('Unsupported type: $T');
      }
      final grid = SplayTreeGrid.fromGrid(other, fill: fill);
      return SplayTreeGrid.fromGrid(grid, fill: fill);
    });
  });

  group('SplayTreeGrid.fromRows', () {
    runSuiteGridFromRows(SplayTreeGrid.fromRows);
  });

  group('SplayTreeGrid.fromIterable', () {
    runSuiteGridFromIterable(SplayTreeGrid.fromIterable);
  });

  group('SplayTreeGrid', () {
    runSuiteGridBody(SplayTreeGrid.fromRows);
  });

  group('asSparseMap', () {
    test('should return a map with the elements of the grid', () {
      final grid = SplayTreeGrid.fromRows(
        [
          [0, 1],
          [1, 2],
        ],
        fill: 0,
      );
      final map = grid.asSparseMap();
      check(map).deepEquals({
        Pos(1, 0): 1,
        Pos(0, 1): 1,
        Pos(1, 1): 2,
      });
    });

    test('should remove fill elements', () {
      final grid = SplayTreeGrid.fromRows(
        [
          [1, 1],
          [1, 1],
        ],
        fill: 0,
      );
      grid.set(Pos(0, 0), 0);

      final map = grid.asSparseMap();
      check(map).deepEquals({
        Pos(1, 0): 1,
        Pos(0, 1): 1,
        Pos(1, 1): 1,
      });
    });

    test('should clear the map if the grid is cleared', () {
      final grid = SplayTreeGrid.fromRows(
        [
          [1, 1],
          [1, 1],
        ],
        fill: 0,
      );
      final map = grid.asSparseMap();

      grid.clear();
      check(map).isEmpty();
      check(grid.rows).deepEquals([
        [0, 0],
        [0, 0],
      ]);
    });
  });
}

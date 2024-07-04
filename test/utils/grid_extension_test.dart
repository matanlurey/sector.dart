import '../_prelude.dart';

void main() {
  group('.isNotEmpty', () {
    test('returns true when the grid is not empty', () {
      final grid = Grid.filled(3, 3, 0);
      check(grid.isNotEmpty).isTrue();
    });

    test('returns false when the grid is empty', () {
      final empty = Grid.filled(0, 0, 0);
      check(empty.isNotEmpty).isFalse();
    });
  });

  group('subGridClamped', () {
    test('clamp left and top', () {
      final grid = Grid.filled(3, 3, 0);
      final subGrid = grid.subGridClamped(left: -1, top: -1);
      check(subGrid)
        ..width.equals(3)
        ..height.equals(3);
    });

    test('clamp width and height', () {
      final grid = Grid.filled(3, 3, 0);
      final subGrid = grid.subGridClamped(width: 5, height: 5);
      check(subGrid)
        ..width.equals(3)
        ..height.equals(3);
    });
  });

  group('asSubGridClamped', () {
    test('clamp left and top', () {
      final grid = Grid.filled(3, 3, 0);
      final subGrid = grid.asSubGridClamped(left: -1, top: -1);
      check(subGrid)
        ..width.equals(3)
        ..height.equals(3);
    });

    test('clamp width and height', () {
      final grid = Grid.filled(3, 3, 0);
      final subGrid = grid.asSubGridClamped(width: 5, height: 5);
      check(subGrid)
        ..width.equals(3)
        ..height.equals(3);
    });
  });

  test('fill', () {
    final grid = Grid.filled(3, 3, 0);
    grid.fill(GridTraversal.rowMajor(), 1);
    check(grid.rows).deepEquals([
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1],
    ]);
  });

  test('fillWith', () {
    final grid = Grid.filled(3, 3, 0);
    grid.fillWith(GridTraversal.rowMajor(), (x, y, t) => x + y);
    check(grid.rows).deepEquals([
      [0, 1, 2],
      [1, 2, 3],
      [2, 3, 4],
    ]);
  });
}

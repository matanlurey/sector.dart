import '../_prelude.dart';
import '../src/naive_grid.dart';

void main() {
  group('rowMajor (Slow)', () {
    test('should traverse', () {
      final grid = NaiveListGrid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      check(
        grid.traverse(GridTraversal.rowMajor()),
      ).deepEquals([1, 2, 3, 4, 5, 6]);
    });

    test('should traverse empty', () {
      final grid = NaiveListGrid.fromRows([]);
      check(grid.traverse(GridTraversal.rowMajor())).isEmpty();
    });

    test('should traverse with a custom starting point', () {
      final grid = NaiveListGrid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      check(
        grid.traverse(GridTraversal.rowMajor(start: (1, 0))),
      ).deepEquals([
        2,
        3,
        4,
        5,
        6,
      ]);
    });

    test('should support seek', () {
      final grid = NaiveListGrid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      final iterator = GridTraversal.rowMajor().traverse(grid);
      iterator.seek(2);
      check(iterator.current).equals(2);
    });

    test('should support iterable.last', () {
      final grid = NaiveListGrid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      check(grid.traverse(GridTraversal.rowMajor())).last.equals(6);
    });

    test('should support position', () {
      final grid = NaiveListGrid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      final iterator = GridTraversal.rowMajor().traverse(grid);
      iterator.moveNext();
      check(iterator.position).equals((0, 0));
    });
  });

  group('rowMajor (Optimized)', () {
    test('should traverse', () {
      final grid = Grid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      check(
        grid.traverse(GridTraversal.rowMajor()),
      ).deepEquals([1, 2, 3, 4, 5, 6]);
    });

    test('should traverse empty', () {
      final grid = Grid.fromRows([]);
      check(grid.traverse(GridTraversal.rowMajor())).isEmpty();
    });

    test('should traverse with a custom starting point', () {
      final grid = Grid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      check(
        grid.traverse(GridTraversal.rowMajor(start: (1, 0))),
      ).deepEquals([2, 3, 4, 5, 6]);
    });

    test('should support seek', () {
      final grid = Grid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      final iterator = GridTraversal.rowMajor().traverse(grid);
      iterator.seek(2);
      check(iterator.current).equals(2);
    });

    test('should support iterable.last', () {
      final grid = Grid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      check(grid.traverse(GridTraversal.rowMajor())).last.equals(6);
    });

    test('should support position', () {
      final grid = Grid.fromRows([
        [1, 2, 3],
        [4, 5, 6],
      ]);
      final iterator = GridTraversal.rowMajor().traverse(grid);
      iterator.moveNext();
      check(iterator.position).equals((0, 0));
    });
  });
}

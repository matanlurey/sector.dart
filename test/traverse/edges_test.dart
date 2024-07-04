import '../_prelude.dart';

void main() {
  test('should traverse the edges', () {
    final grid = Grid.fromRows([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ]);
    final results = grid.traverse(const GridTraversal.edges());
    check(results).deepEquals([
      1, 2, 3, //
      6, 9, 8, //
      7, 4, 1, //
    ]);
  });

  test('should traverse an empty grid', () {
    final grid = Grid<int>.empty();
    final results = grid.traverse(const GridTraversal.edges());
    check(results).isEmpty();
  });

  test('should traverse a single element grid', () {
    final grid = Grid.fromRows([
      [1],
    ]);
    final results = grid.traverse(const GridTraversal.edges());
    check(results).deepEquals([1]);
  });
}

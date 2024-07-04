import '../_prelude.dart';

void main() {
  test('should draw a rect from (0, 0) to (2, 2)', () {
    final grid = Grid.fromRows([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ]);
    check(
      grid.traverse(GridTraversal.rect(0, 0, 2, 2)),
    ).deepEquals([1, 2, 4, 5]);
    check(
      grid.traverse(GridTraversal.rect(0, 0, 2, 2)).positions,
    ).deepEquals([
      Pos(0, 0),
      Pos(1, 0),
      Pos(0, 1),
      Pos(1, 1),
    ]);
  });

  test('should draw a rect from (1, 1) to (2, 1)', () {
    final grid = Grid.fromRows([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ]);
    check(
      grid.traverse(GridTraversal.rect(1, 1, 2, 1)),
    ).deepEquals([5, 6]);
  });
}

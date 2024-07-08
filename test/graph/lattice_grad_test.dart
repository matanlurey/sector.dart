import '../prelude.dart';

void main() {
  test('has an empty graph with 0 elements', () {
    final grid = Grid<String>.empty();
    final graph = LatticeGraph.view(grid);

    check(graph).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('has an empty graph if 1x1', () {
    final grid = ListGrid<String>.filled(1, 1, '');
    final graph = LatticeGraph.view(grid);

    check(graph).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('has a non-empty graph if 1', () {
    final grid = ListGrid<String>.filled(2, 1, '');
    final graph = LatticeGraph.view(grid);

    check(graph).has((g) => g.isNotEmpty, 'isNotEmpty').isTrue();
  });

  test('has edges for each cardinal direction', () {
    final grid = Grid.fromRows([
      ['a', ' '],
      ['c', ' '],
    ]);
    final graph = LatticeGraph.view(grid);

    check(graph).has((g) => g.edges, 'edges').unorderedEquals([
      (Pos(0, 0), Pos(1, 0), ('a', ' ')),
      (Pos(1, 0), Pos(0, 0), (' ', 'a')),
      (Pos(0, 0), Pos(0, 1), ('a', 'c')),
      (Pos(0, 1), Pos(0, 0), ('c', 'a')),
    ]);
  });
}

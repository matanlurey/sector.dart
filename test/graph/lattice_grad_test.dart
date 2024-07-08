import 'package:test/test.dart';

import '../prelude.dart';

void main() {
  test('has an empty graph with 0 elements', () {
    final grid = Grid<String>.empty();
    final graph = Graph.withGrid(grid);

    check(graph).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('has an empty graph if 1x1', () {
    final grid = ListGrid<String>.filled(1, 1, '');
    final graph = Graph.withGrid(grid);

    check(graph).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('has a non-empty graph if 1', () {
    final grid = ListGrid<String>.filled(2, 1, '');
    final graph = Graph.withGrid(grid);

    check(graph).has((g) => g.isNotEmpty, 'isNotEmpty').isTrue();
  });

  test('has edges for each cardinal direction', () {
    final grid = Grid.fromRows([
      ['a', ' '],
      ['c', ' '],
    ]);
    final graph = Graph.withGrid(grid);

    check(graph).has((g) => g.edges, 'edges').unorderedEquals([
      (Pos(0, 0), Pos(1, 0), ('a', ' ')),
      (Pos(0, 0), Pos(0, 1), ('a', 'c')),
      (Pos(1, 0), Pos(0, 0), (' ', 'a')),
      (Pos(1, 0), Pos(1, 1), (' ', ' ')),
      (Pos(0, 1), Pos(0, 0), ('c', 'a')),
      (Pos(0, 1), Pos(1, 1), ('c', ' ')),
      (Pos(1, 1), Pos(0, 1), (' ', 'c')),
      (Pos(1, 1), Pos(1, 0), (' ', ' ')),
    ]);
  });

  test('has vertices for each position', () {
    final grid = ListGrid<String>.filled(2, 2, '');
    final graph = Graph.withGrid(grid);

    check(graph).has((g) => g.vertices, 'vertices').unorderedEquals([
      Pos(0, 0),
      Pos(1, 0),
      Pos(0, 1),
      Pos(1, 1),
    ]);
  });

  test('should fail on adding an edge', () {
    final grid = ListGrid<String>.filled(2, 2, '');
    final graph = Graph.withGrid(grid);

    check(
      () => graph.addEdge(('a', 'b'), source: Pos(0, 0), target: Pos(1, 0)),
    ).throws<UnsupportedError>();
  });

  test('should fail on removing an edge', () {
    final grid = ListGrid<String>.filled(2, 2, '');
    final graph = Graph.withGrid(grid);

    check(
      () => graph.removeEdge(Pos(0, 0), Pos(1, 0)),
    ).throws<UnsupportedError>();
  });

  test('should fail on clearing all edges and vertices', () {
    final grid = ListGrid<String>.filled(2, 2, '');
    final graph = Graph.withGrid(grid);

    check(graph.clear).throws<UnsupportedError>();
  });

  test('should contain an edge if adjacent', () {
    final grid = ListGrid<String>.filled(2, 2, '');
    final graph = Graph.withGrid(grid);

    check(graph)
        .has(
          (g) => g.containsEdge(Pos(0, 0), Pos(1, 0)),
          'containsEdge',
        )
        .isTrue();
  });

  test('should return an edge if adjacent', () {
    final grid = ListGrid<String>.filled(2, 2, ' ');
    final graph = Graph.withGrid(grid);

    final edge = graph.getEdge(Pos(0, 0), Pos(1, 0));
    check(edge).equals((' ', ' '));
  });

  test('should return null if not adjacent', () {
    final grid = ListGrid<String>.filled(2, 2, '');
    final graph = Graph.withGrid(grid);

    check(graph)
        .has(
          (g) => g.getEdge(Pos(0, 0), Pos(1, 1)),
          'getEdge',
        )
        .isNull();
  });

  test('should return the edges from a source', () {
    final grid = ListGrid<String>.filled(2, 2, ' ');
    final graph = Graph.withGrid(grid);

    final edges = graph.edgesFrom(Pos(0, 0)).toList();
    check(edges).unorderedEquals([
      (Pos(1, 0), (' ', ' ')),
      (Pos(0, 1), (' ', ' ')),
    ]);
  });

  test('should return the edges to a target', () {
    final grid = ListGrid<String>.filled(2, 2, ' ');
    final graph = Graph.withGrid(grid);

    final edges = graph.edgesTo(Pos(0, 0)).toList();
    check(edges).unorderedEquals([
      (Pos(1, 0), (' ', ' ')),
      (Pos(0, 1), (' ', ' ')),
    ]);
  });

  test('should provide custom directions', () {
    final grid = ListGrid<String>.filled(2, 2, ' ');
    final graph = Graph.withGrid(
      grid,
      adjacent: [
        Pos(1, 0),
        Pos(0, 1),
      ],
    );

    final edges = graph.edgesFrom(Pos(0, 0)).toList();
    check(edges).unorderedEquals([
      (Pos(1, 0), (' ', ' ')),
      (Pos(0, 1), (' ', ' ')),
    ]);
  });

  group('custom isEdge filter', () {
    late Grid<_Tile> grid;
    late Graph<Pos, (_Tile, _Tile)> graph;

    setUp(() {
      grid = ListGrid<_Tile>.filled(2, 2, _Tile.empty);
      graph = Graph.withGrid(
        grid,
        isEdge: (from, to) => from != _Tile.wall && to != _Tile.wall,
      );
    });

    test('should filter out walls', () {
      grid.set(Pos(1, 1), _Tile.wall);

      check(graph).has((g) => g.edgesFrom(Pos(1, 1)), 'edgesFrom').isEmpty();
      check(graph).has((g) => g.edgesTo(Pos(1, 1)), 'edgesTo').isEmpty();
      check(graph)
          .has((g) => g.containsEdge(Pos(1, 1), Pos(1, 0)), 'containsEdge')
          .isFalse();
    });

    test('should include non-walls', () {
      grid.set(Pos(1, 1), _Tile.empty);

      check(graph).has((g) => g.edgesFrom(Pos(1, 1)), 'edgesFrom').isNotEmpty();
      check(graph).has((g) => g.edgesTo(Pos(1, 1)), 'edgesTo').isNotEmpty();
      check(graph)
          .has((g) => g.containsEdge(Pos(1, 1), Pos(1, 0)), 'containsEdge')
          .isTrue();

      check(graph).has((g) => g.edges, 'edges').unorderedEquals([
        (Pos(0, 0), Pos(1, 0), (_Tile.empty, _Tile.empty)),
        (Pos(0, 0), Pos(0, 1), (_Tile.empty, _Tile.empty)),
        (Pos(1, 0), Pos(0, 0), (_Tile.empty, _Tile.empty)),
        (Pos(1, 0), Pos(1, 1), (_Tile.empty, _Tile.empty)),
        (Pos(0, 1), Pos(0, 0), (_Tile.empty, _Tile.empty)),
        (Pos(0, 1), Pos(1, 1), (_Tile.empty, _Tile.empty)),
        (Pos(1, 1), Pos(0, 1), (_Tile.empty, _Tile.empty)),
        (Pos(1, 1), Pos(1, 0), (_Tile.empty, _Tile.empty)),
      ]);
    });
  });
}

enum _Tile {
  wall,
  empty;
}

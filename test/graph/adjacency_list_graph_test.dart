import '../prelude.dart';

void main() {
  test('should be empty with no edges', () {
    final graph = Graph<String, int>();
    check(graph).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('should not be empty with edges', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    check(graph).has((g) => g.isNotEmpty, 'isNotEmpty').isTrue();
  });

  test('addEdge should refuse a circular edge', () {
    final graph = Graph<String, int>();
    check(
      () => graph.addEdge(42, source: 'A', target: 'A'),
    ).throws<ArgumentError>();
  });

  test('should create from edges', () {
    final graph = Graph<String, int>.fromEdges({
      'A': {'B': 42},
      'B': {'C': 17},
    });
    check(graph).has((g) => g.edges, 'edges').deepEquals([
      ('A', 'B', 42),
      ('B', 'C', 17),
    ]);
  });

  test('should add an edge', () {
    final graph = Graph<String, int>();
    final previous = graph.addEdge(42, source: 'A', target: 'B');
    check(previous).isNull();
    check(graph).has((g) => g.containsEdge('A', 'B'), 'containsEdge').isTrue();
    check(graph).has((g) => g.getEdge('A', 'B'), 'getEdge').equals(42);
  });

  test('should replace an edge', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    final previous = graph.addEdge(43, source: 'A', target: 'B');
    check(previous).equals(42);
    check(graph).has((g) => g.containsEdge('A', 'B'), 'containsEdge').isTrue();
    check(graph).has((g) => g.getEdge('A', 'B'), 'getEdge').equals(43);
  });

  test('should remove an edge', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    final previous = graph.removeEdge('A', 'B');
    check(previous).equals(42);
    check(graph).has((g) => g.containsEdge('A', 'B'), 'containsEdge').isFalse();
    check(graph).has((g) => g.getEdge('A', 'B'), 'getEdge').isNull();
  });

  test('should add and remove vertices implicitly', () {
    final graph = Graph<String, int>();

    graph.addEdge(42, source: 'A', target: 'B');
    check(graph).has((g) => g.containsVertex('A'), 'containsVertex').isTrue();
    check(graph).has((g) => g.containsVertex('B'), 'containsVertex').isTrue();

    graph.removeEdge('A', 'B');
    check(graph).has((g) => g.containsVertex('A'), 'containsVertex').isFalse();
    check(graph).has((g) => g.containsVertex('B'), 'containsVertex').isFalse();
  });

  test('should return all edges', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    check(graph).has((g) => g.edges, 'edges').deepEquals([
      ('A', 'B', 42),
      ('B', 'C', 43),
    ]);
  });

  test('should return all vertices', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    check(graph).has((g) => g.vertices, 'vertices').deepEquals(['A', 'B', 'C']);
  });

  test('should clear all edges and vertices', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    graph.clear();
    check(graph).has((g) => g.edges, 'edges').isEmpty();
    check(graph).has((g) => g.vertices, 'vertices').isEmpty();
  });

  test('should return edges from a source', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'A', target: 'C');
    check(graph).has((g) => g.edgesFrom('A'), 'edgesFrom').deepEquals([
      ('B', 42),
      ('C', 43),
    ]);
  });

  test('should return edges to a target', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'C', target: 'B');
    check(graph).has((g) => g.edgesTo('B'), 'edgesTo').deepEquals([
      ('A', 42),
      ('C', 43),
    ]);
  });

  test('should map edges to a new type', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    final mapped = graph.map((edge) => edge.toString());
    check(mapped).has((g) => g.edges, 'edges').deepEquals([
      ('A', 'B', '42'),
      ('B', 'C', '43'),
    ]);
  });

  test('should copy an adjacency list graph', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    final copy = Graph.fromGraph(graph);
    check(copy).has((g) => g.edges, 'edges').deepEquals([
      ('A', 'B', 42),
      ('B', 'C', 43),
    ]);
  });

  test('should copy another graph', () {
    final grid = ListGrid<String>.filled(2, 2, ' ');
    final graph = Graph.withGrid(grid);
    final copy = Graph.fromGraph(graph);

    check(copy).has((g) => g.edges, 'edges').unorderedEquals([
      (Pos(0, 0), Pos(1, 0), (' ', ' ')),
      (Pos(0, 0), Pos(0, 1), (' ', ' ')),
      (Pos(1, 0), Pos(0, 0), (' ', ' ')),
      (Pos(1, 0), Pos(1, 1), (' ', ' ')),
      (Pos(0, 1), Pos(0, 0), (' ', ' ')),
      (Pos(0, 1), Pos(1, 1), (' ', ' ')),
      (Pos(1, 1), Pos(0, 1), (' ', ' ')),
      (Pos(1, 1), Pos(1, 0), (' ', ' ')),
    ]);
  });
}

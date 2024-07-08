import '../prelude.dart';

void main() {
  test('should be empty with no edges', () {
    final graph = Graph<String, int>();
    check(graph.map(_identity)).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('should be non-empty with edges', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');

    check(graph.map(_identity)).has((g) => g.isNotEmpty, 'isNotEmpty').isTrue();
  });

  test('should return vertices', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');

    check(graph.map(_identity))
        .has((g) => g.containsVertex('A'), 'containsVertex')
        .isTrue();
    check(graph.map(_identity))
        .has((g) => g.vertices, 'vertices')
        .unorderedEquals(['A', 'B']);
  });

  test('should return edges', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');

    check(graph.map(_identity))
        .has((g) => g.containsEdge('A', 'B'), 'containsEdge')
        .isTrue();
    check(graph.map(_identity))
        .has((g) => g.getEdge('A', 'B'), 'getEdge')
        .equals(42);
    check(graph.map(_identity))
        .has((g) => g.edges, 'edges')
        .unorderedEquals([('A', 'B', 42)]);
  });

  test('should return null if an edge is missing', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');

    check(graph.map(_identity))
        .has((g) => g.getEdge('B', 'A'), 'getEdge')
        .isNull();
  });

  test('should map `null` if a valid value', () {
    final graph = Graph<String, int?>();
    graph.addEdge(null, source: 'A', target: 'B');

    check(graph.map(_nullIs0))
        .has((g) => g.getEdge('A', 'B'), 'getEdge')
        .equals(0);
  });

  test('should return edgesFrom', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'A', target: 'C');

    check(graph.map(_identity))
        .has((g) => g.edgesFrom('A'), 'edgesFrom')
        .unorderedEquals([
      ('B', 42),
      ('C', 43),
    ]);
  });

  test('should return edgesTo', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'C', target: 'B');

    check(graph.map(_identity))
        .has((g) => g.edgesTo('B'), 'edgesTo')
        .unorderedEquals([
      ('A', 42),
      ('C', 43),
    ]);
  });

  test('should throw on addEdge', () {
    final graph = Graph<String, int>();
    final view = UnmodifiableGraph.withGraph(graph);

    check(
      () => view.addEdge(42, source: 'A', target: 'B'),
    ).throws<UnsupportedError>();
  });

  test('should throw on removeEdge', () {
    final graph = Graph<String, int>();
    final view = UnmodifiableGraph.withGraph(graph);

    check(
      () => view.removeEdge('A', 'B'),
    ).throws<UnsupportedError>();
  });

  test('should throw on clear', () {
    final graph = Graph<String, int>();
    final view = UnmodifiableGraph.withGraph(graph);

    check(
      view.clear,
    ).throws<UnsupportedError>();
  });

  test('should be a pass through for UnmodifiableGraph.withGraph', () {
    final graph = Graph.fromEdges({
      'A': {
        'B': 42,
      },
    });
    final view = UnmodifiableGraph.withGraph(graph);

    check(view).has((g) => g.edges, 'edges').unorderedEquals([
      ('A', 'B', 42),
    ]);
  });
}

E _identity<E>(E edge) => edge;
int _nullIs0(int? edge) => edge ?? 0;

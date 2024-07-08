import '../prelude.dart';

void main() {
  test('should be empty with no edges', () {
    final graph = AdjacencyListGraph<String, int>();
    check(graph).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('should not be empty with edges', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    check(graph).has((g) => g.isNotEmpty, 'isNotEmpty').isTrue();
  });

  test('should add an edge', () {
    final graph = AdjacencyListGraph<String, int>();
    final previous = graph.addEdge(42, source: 'A', target: 'B');
    check(previous).isNull();
    check(graph).has((g) => g.containsEdge('A', 'B'), 'containsEdge').isTrue();
    check(graph).has((g) => g.getEdge('A', 'B'), 'getEdge').equals(42);
  });

  test('should replace an edge', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    final previous = graph.addEdge(43, source: 'A', target: 'B');
    check(previous).equals(42);
    check(graph).has((g) => g.containsEdge('A', 'B'), 'containsEdge').isTrue();
    check(graph).has((g) => g.getEdge('A', 'B'), 'getEdge').equals(43);
  });

  test('should remove an edge', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    final previous = graph.removeEdge('A', 'B');
    check(previous).equals(42);
    check(graph).has((g) => g.containsEdge('A', 'B'), 'containsEdge').isFalse();
    check(graph).has((g) => g.getEdge('A', 'B'), 'getEdge').isNull();
  });

  test('should return all edges', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    check(graph).has((g) => g.edges, 'edges').deepEquals([
      ('A', 'B', 42),
      ('B', 'C', 43),
    ]);
  });

  test('should return all vertices', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    check(graph).has((g) => g.vertices, 'vertices').deepEquals(['A', 'B', 'C']);
  });

  test('should clear all edges and vertices', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'B', target: 'C');
    graph.clear();
    check(graph).has((g) => g.edges, 'edges').isEmpty();
    check(graph).has((g) => g.vertices, 'vertices').isEmpty();
  });

  test('should return edges from a source', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'A', target: 'C');
    check(graph).has((g) => g.edgesFrom('A'), 'edgesFrom').deepEquals([
      ('B', 42),
      ('C', 43),
    ]);
  });

  test('should return edges to a target', () {
    final graph = AdjacencyListGraph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');
    graph.addEdge(43, source: 'C', target: 'B');
    check(graph).has((g) => g.edgesTo('B'), 'edgesTo').deepEquals([
      ('A', 42),
      ('C', 43),
    ]);
  });
}

import '../prelude.dart';

void main() {
  // Ensures that the function matches the `Traversal` signature.
  // ignore: unnecessary_cast
  const traversal = depthFirst;

  test('should visit an empty graph', () {
    final graph = Graph<String, int>();

    final visited = graph.traverse('A', using: traversal).toList();
    check(visited).isEmpty();
  });

  test('should visit a single edge', () {
    final graph = Graph<String, int>();
    graph.addEdge(42, source: 'A', target: 'B');

    final visited = graph.traverse('A', using: traversal).toList();
    check(visited).deepEquals([
      TraversedNode('B', edge: 42, origin: 'A'),
      OriginNode<String, int>(target: 'A'),
    ]);
  });

  test('should visit a simple graph', () {
    // A -> B -> C
    final graph = Graph<String, int>();
    graph.addEdge(1, source: 'A', target: 'B');
    graph.addEdge(2, source: 'B', target: 'C');

    final visited = graph.traverse('A', using: traversal).toList();
    check(visited).deepEquals([
      TraversedNode('C', edge: 2, origin: 'B'),
      TraversedNode('B', edge: 1, origin: 'A'),
      OriginNode<String, int>(target: 'A'),
    ]);
  });

  test('should visit a graph with multiple inbound edges to a vertex', () {
    // A -> B
    // |    |
    // v    v
    // C -> D
    final graph = Graph<String, int>();
    graph.addEdge(1, source: 'A', target: 'B');
    graph.addEdge(2, source: 'A', target: 'C');
    graph.addEdge(3, source: 'B', target: 'D');
    graph.addEdge(4, source: 'C', target: 'D');

    final visited = graph.traverse('A', using: traversal).toList();
    check(visited).deepEquals([
      TraversedNode('D', edge: 3, origin: 'B'),
      TraversedNode('B', edge: 1, origin: 'A'),
      TraversedNode('D', edge: 4, origin: 'C'),
      TraversedNode('C', edge: 2, origin: 'A'),
      OriginNode<String, int>(target: 'A'),
    ]);
  });

  test('should visit a graph with multiple inbound edges, distinct', () {
    // A -> B
    // |    |
    // v    v
    // C -> D
    final graph = Graph<String, int>();
    graph.addEdge(1, source: 'A', target: 'B');
    graph.addEdge(2, source: 'A', target: 'C');
    graph.addEdge(3, source: 'B', target: 'D');
    graph.addEdge(4, source: 'C', target: 'D');

    final visited = graph.traverse('A', using: traversal.distinct).toList();
    check(visited).deepEquals([
      TraversedNode('D', edge: 3, origin: 'B'),
      TraversedNode('B', edge: 1, origin: 'A'),
      TraversedNode('C', edge: 2, origin: 'A'),
      OriginNode<String, int>(target: 'A'),
    ]);
  });

  test('should visit a graph with loops', () {
    // A -> B
    // ^    |
    // |    v
    // D <- C
    final graph = Graph<String, int>();
    graph.addEdge(1, source: 'A', target: 'B');
    graph.addEdge(2, source: 'B', target: 'C');
    graph.addEdge(3, source: 'C', target: 'D');
    graph.addEdge(4, source: 'D', target: 'A');

    // Must use distinct to prevent infinite loop.
    final visited = graph.traverse('A', using: traversal.distinct).toList();
    check(visited).deepEquals([
      TraversedNode('A', edge: 4, origin: 'D'),
      TraversedNode('D', edge: 3, origin: 'C'),
      TraversedNode('C', edge: 2, origin: 'B'),
      TraversedNode('B', edge: 1, origin: 'A'),
    ]);
  });

  test('should visit a graph with bi-directional edges', () {
    // A <-> B
    final graph = Graph<String, int>();
    graph.addEdge(1, source: 'A', target: 'B');
    graph.addEdge(2, source: 'B', target: 'A');

    // Must use distinct to prevent infinite loop.
    final visited = graph.traverse('A', using: traversal.distinct).toList();
    check(visited).deepEquals([
      TraversedNode('A', edge: 2, origin: 'B'),
      TraversedNode('B', edge: 1, origin: 'A'),
    ]);
  });
}

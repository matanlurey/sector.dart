import 'package:sector/sector.dart';

/// A depth-first [GraphTraversal] that visits vertices and edges in a graph.
///
/// Depth first means that the algorithm will visit the start vertex, then
/// recursively visit the neighbors of the vertex, and so on until no more
/// vertices can be visited. The algorithm will backtrack to the previous
/// vertex and continue visiting other neighbors until all vertices have been
/// visited or the visit function returns false.
///
/// See [DepthFirst] for more information.
const depthFirst = DepthFirst._();

/// A depth-first [GraphTraversal] that visits vertices and edges in a graph.
///
/// Depth first means that the algorithm will visit the start vertex, then
/// recursively visit the neighbors of the vertex, and so on until no more
/// vertices can be visited. The algorithm will backtrack to the previous
/// vertex and continue visiting other neighbors until all vertices have been
/// visited or the visit function returns false.
///
/// The singleton instance of this class is [depthFirst].
///
/// ## Example
///
/// ```dart
/// final graph = Graph<String, int>();
/// graph.addEdge(1, source: 'A', target: 'B');
/// graph.addEdge(2, source: 'B', target: 'C');
/// graph.addEdge(3, source: 'A', target: 'D');
///
/// final traversal = depthFirst(graph, 'A', visit: (v, e) {
///   print('Visiting $v with edge $e');
///   return true;
/// });
///
/// for (final tuple in traversal) {}
/// ```
///
/// Produces the following output:
///
/// ```txt
/// Visiting A with edge null
/// Visiting D with edge 3
/// Visiting B with edge 1
/// Visiting C with edge 2
/// ```
///
/// {@category Graphs}
final class DepthFirst with GraphTraversal, PathFinder {
  const DepthFirst._();

  @override
  Iterable<VisitedNode<V, E>> traverse<V, E>(
    Graph<V, E> graph,
    V start, {
    bool Function(VisitedNode<V, E>)? visit,
  }) sync* {
    // Perform a depth-first traversal without tracking visited vertices.
    Iterable<VisitedNode<V, E>> depthFirst(V start) sync* {
      final edges = graph.edgesFrom(start);
      for (final (target, edge) in edges) {
        final newNode = TraversedNode(target, edge: edge, origin: start);
        if (visit == null || visit(newNode)) {
          yield* depthFirst(target);
          yield newNode;
        }
      }
    }

    // Start the depth-first traversal from the start vertex.
    yield* depthFirst(start);
    final originNode = OriginNode<V, E>(target: start);
    if (graph.containsVertex(start) && (visit == null || visit(originNode))) {
      yield originNode;
    }
  }
}

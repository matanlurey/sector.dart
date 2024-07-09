import 'dart:collection';

import 'package:sector/sector.dart';
import 'package:sector/src/graph/path_finder.dart';

/// A breadth-first [GraphTraversal] that visits vertices and edges in a graph.
///
/// Breadth first means that the algorithm will visit the start vertex, then
/// recursively visit the neighbors of the vertex, and so on until no more
/// vertices can be visited. The algorithm will visit all neighbors of the
/// current vertex before visiting the neighbors of the neighbors.
///
/// See [BreadthFirst] for more information.
const breadthFirst = BreadthFirst._();

/// A breadth-first [GraphTraversal] that visits vertices and edges in a graph.
///
/// Breadth first means that the algorithm will visit the start vertex, then
/// recursively visit the neighbors of the vertex, and so on until no more
/// vertices can be visited. The algorithm will visit all neighbors of the
/// current vertex before visiting the neighbors of the neighbors.
///
/// The singleton instance of this class is [breadthFirst].
///
/// ## Example
///
/// ```dart
/// final graph = Graph<String, int>();
/// graph.addEdge(1, source: 'A', target: 'B');
/// graph.addEdge(2, source: 'B', target: 'C');
/// graph.addEdge(3, source: 'A', target: 'D');
///
/// final traversal = breadthFirst.traverse(graph, 'A', visit: (n) {
///   print('Visiting $n');
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
/// Visiting A->D
/// Visiting A->B
/// Visiting B->C
/// ```
///
/// {@category Graphs}
final class BreadthFirst with GraphTraversal, PathFinder {
  const BreadthFirst._();

  @override
  Iterable<VisitedNode<V, E>> traverse<V, E>(
    Graph<V, E> graph,
    V start, {
    bool Function(VisitedNode<V, E>)? visit,
  }) sync* {
    final visited = HashSet<V>();
    final queue = Queue<V>()..add(start);

    if (graph.containsVertex(start)) {
      yield OriginNode(target: start);
    }

    while (queue.isNotEmpty) {
      final vertex = queue.removeFirst();
      if (visited.contains(vertex)) {
        continue;
      }

      visited.add(vertex);
      final edges = graph.edgesFrom(vertex);
      for (final (target, edge) in edges) {
        final newNode = TraversedNode(target, edge: edge, origin: start);
        if (visit == null || visit(newNode)) {
          queue.add(target);
        }
        yield newNode;
      }
    }
  }
}

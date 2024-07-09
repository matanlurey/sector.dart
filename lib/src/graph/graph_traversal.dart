import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sector/sector.dart';
import 'package:sector/src/graph/path_finder.dart';

/// Named properties describing a node along a graph traversal path.
///
/// {@category Graphs}
@immutable
sealed class VisitedNode<V, E> {
  const VisitedNode(this.target);

  /// The vertex visited.
  final V target;

  @override
  String toString() => '$target';
}

/// The original node which starts a [GraphTraversal.traverse] operation.
///
/// This node does not have an origin, as it is the origin of the traversal.
///
/// ## Equality
///
/// Two [OriginNode] instances are equal if their targets are equal.
///
/// {@category Graphs}
final class OriginNode<V, E> extends VisitedNode<V, E> {
  /// Creates a new node with the given [target].
  const OriginNode({required V target}) : super(target);

  @override
  bool operator ==(Object other) {
    if (other is OriginNode<V, E>) {
      return target == other.target;
    }
    return false;
  }

  @override
  int get hashCode => target.hashCode;
}

/// A node that has been traversed during a [GraphTraversal.traverse] operation.
///
/// This node has an [edge] that was crossed to reach the vertex, and an
/// [origin] that is the vertex that originated the traversal, as well as the
/// [target] vertex.
///
/// ## Equality
///
/// Two [TraversedNode] instances are equal if their targets, edges, and origins
/// are equal according to [Object.==] and [Object.hashCode] respectively.
final class TraversedNode<V, E> extends VisitedNode<V, E> {
  /// Creates a new node with the given [target], [edge], and [origin].
  const TraversedNode(
    super.target, {
    required this.edge,
    required this.origin,
  });

  /// The edge crossed to reach the vertex.
  final E edge;

  /// The originator of the node.
  final V origin;

  @override
  bool operator ==(Object other) {
    if (other is TraversedNode<V, E>) {
      return target == other.target &&
          origin == other.origin &&
          edge == other.edge;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(target, origin, edge);

  @override
  String toString() => '$origin -> $target ($edge)';
}

/// A graph traversal algorithm that visits vertices and edges in a graph.
///
/// Traversal algorithms produce a lazy iterable that only visits vertices and
/// edges when iterated over. The algorithm can be used to find paths, count
/// paths, or perform other operations on a graph.
///
/// See [traverse], [findPaths], and [findShortestPaths] for details.
///
/// ## Implementing
///
/// By mixing-in [GraphTraversal], a class can implement just the [traverse]
/// method and have the other traversal methods automatically implemented,
/// though they can be overridden if necessary.
///
/// ```dart
/// final class DepthFirst with GraphTraversal {
///   @override
///   Iterable<(V entered, E? crossed)> traverse<V, E>(
///     Graph<V, E> graph,
///     V start, {
///     bool Function(V entered, E? crossed)? visit,
///   }) sync* {
///     // Implementation here.
///   }
/// }
/// ```
///
/// {@category Graphs}
@immutable
mixin GraphTraversal implements PathFinder {
  /// Returns the results of the traversing vertices and edges in a graph.
  ///
  /// Traversal algorithms produce a lazy iterable that only visits vertices and
  /// edges when iterated over. The algorithm can be used to find paths, count
  /// paths, or perform other operations on a graph.
  ///
  /// The algorithm takes a [graph], a [start] vertex, and a [visit] function
  /// that determines whether to visit a vertex and edge. The function returns
  /// an iterable of tuples that contain the entered vertex and the edge crossed
  /// to reach the vertex.
  ///
  /// It is unsupported to modify the graph while traversing it.
  ///
  /// ## Configuration
  ///
  /// If [visit] is omitted, the traversal will visit all vertices and edges in
  /// the graph, **including vertices that have already been visited**. As such,
  /// graphs with loops or cycles may cause the traversal to run indefinitely
  /// unless a visit function is provided with a mechanism to prevent revisiting
  /// vertices:
  ///
  /// ```dart
  /// final visited = <V>{};
  /// final traversal = depthFirst.traverse(graph, 'A', visit: (v, e) {
  ///   if (!visited.add(v)) {
  ///     return false;
  ///   }
  ///   return true;
  /// });
  /// ```
  ///
  /// See also [distinct] for a convenience method:
  ///
  /// ```dart
  /// // Similar to the above, with more edge cases handled.
  /// final traversal = depthFirst.distinct(graph, 'A');
  /// ```
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge(42, source: 'A', target: 'B');
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
  /// Visiting B with edge 42
  /// ```
  Iterable<VisitedNode<V, E>> traverse<V, E>(
    Graph<V, E> graph,
    V start, {
    bool Function(VisitedNode<V, E>)? visit,
  });

  @override
  Iterable<List<VisitedNode<V, E>>> findPaths<V, E>(
    Graph<V, E> graph,
    V start, {
    required bool Function(VisitedNode<V, E>) success,
    bool Function(VisitedNode<V, E>)? visit,
  }) {
    return _findPaths<V, E>(
      graph,
      start,
      success: success,
      visited: {},
      path: [],
      visit: visit,
    );
  }

  Iterable<List<VisitedNode<V, E>>> _findPaths<V, E>(
    Graph<V, E> graph,
    V start, {
    required bool Function(VisitedNode<V, E>) success,
    required Set<V> visited,
    required List<VisitedNode<V, E>> path,
    bool Function(VisitedNode<V, E>)? visit,
  }) sync* {
    for (final node in traverse(graph, start, visit: visit)) {
      path.add(node);
      visited.add(node.target);

      if (success(node)) {
        yield List.of(path);
      }

      // Continue traversal only if the current node is not a dead-end.
      final neighbors = List.of(graph.edgesFrom(node.target));
      if (neighbors.isNotEmpty) {
        for (final (neighbor, _) in neighbors) {
          if (!visited.contains(neighbor)) {
            yield* _findPaths(
              graph,
              neighbor,
              success: success,
              visit: visit,
              visited: visited,
              path: path,
            );
          }
        }
      }

      // Backtrack to the previous node.
      path.removeLast();

      // Remove the current node from the visited set.
      visited.remove(node.target);
    }
  }

  /// Returns the results of the traversal by visiting each vertex at most once.
  ///
  /// The method implicitly provides a visit function that tracks visited edges
  /// and and prevents revisiting them, and further filters out vertices that
  /// have already been visited.
  ///
  /// For graphs with cycles, including bi-directional edges, this method may be
  /// required to prevent infinite loops in the traversal algorithm. The method
  /// uses a [HashSet] to track visited edges and vertices and only visits edges
  /// and vertices that have not been visited.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge(1, source: 'A', target: 'B');
  /// graph.addEdge(2, source: 'B', target: 'A');
  ///
  /// final traversal = depthFirst.distinct.traverse(graph, 'A');
  /// for (final tuple in traversal) {
  ///   print(tuple);
  /// }
  /// ```
  ///
  /// Produces the following output:
  ///
  /// ```txt
  /// (B, 1)
  /// (A, 2)
  /// ```
  GraphTraversal get distinct => _DistinctGraphTraversal(this);
}

final class _DistinctGraphTraversal with GraphTraversal, PathFinder {
  const _DistinctGraphTraversal(this._traversal);
  final GraphTraversal _traversal;

  @override
  Iterable<VisitedNode<V, E>> traverse<V, E>(
    Graph<V, E> graph,
    V start, {
    bool Function(VisitedNode<V, E>)? visit,
  }) {
    final edges = HashSet<E?>();
    final vertices = HashSet<V>();
    return _traversal.traverse(
      graph,
      start,
      visit: (n) {
        if (n is TraversedNode<V, E>) {
          return edges.add(n.edge) && (visit == null || visit(n));
        }
        return visit == null || visit(n);
      },
    ).where((node) {
      return vertices.add(node.target);
    });
  }

  @override
  GraphTraversal get distinct => this;
}

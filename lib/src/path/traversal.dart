import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

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

/// A pathfinding algorithm that finds paths between two points in a graph.
///
/// Pathfinding algorithms produce a lazy iterable that only visits vertices and
/// edges when iterated over. The algorithm can be used to find all, some, or
/// the shortest path between two points in a graph.
///
/// Any [GraphTraversal] algorithm can be used to find paths:
///
/// ```dart
/// final paths = depthFirst.findPaths(
///   graph,
///   'A',
///   success: (n) => n.target == 'C',
/// );
/// ```
///
/// But, some algorithms are better suited for finding paths than others. For
/// example, [astar] and [dijkstra] are guaranteed to find the shortest path
/// as the first path found without needing to sort the paths:
///
/// ```dart
/// final shortestPath = astar(graph, 'A', success: (v, e) => v == 'C').first;
/// ```
///
/// See [findPaths] for more information about configuring a search algorithm.
///
/// ## Implementing
///
/// By mixing-in [PathFinder], a class can implement just the [findPaths] method
/// and have the other pathfinding methods automatically implemented, though
/// they can be overridden if necessary, i.e. for performance reasons.
///
/// ```dart
/// final class AStar with PathFinder {
///   @override
///   Iterable<List<VisitedNode<V, E>>> findPaths<V, E>(
///     Graph<V, E> graph,
///     V start, {
///     required bool Function(V entered, E? crossed) success,
///     bool Function(V entered, E? crossed)? visit,
///     Comparable<E> Function(E)? weight,
///   ) sync* {
///     // Implementation here.
///   }
/// }
/// ```
///
/// {@category Graphs}
@immutable
mixin PathFinder {
  /// Returns each path in the graph that satisfies the [success] function.
  ///
  /// The algorithm takes a [graph], a [start] vertex, and a [success] function
  /// that determines whether a path is successful. The function returns an
  /// iterable of lists that contain the entered vertex and the edge crossed to
  /// reach the success condition.
  ///
  /// The resulting list of paths are not necessarily ordered by length, and
  /// may contain paths that are not the shortest path. To find the shortest
  /// path, use [findShortestPaths], which orders the paths by length (if
  /// necessary, some algorithms return the shortest path first).
  ///
  /// Some algorithims return a maximum of one path.
  ///
  /// ## Configuration
  ///
  /// ### Success Condition
  ///
  /// The [success] function determines whether a path is successful.
  ///
  /// For example, to find all paths that reach a vertex named `'C'`:
  ///
  /// ```dart
  /// final paths = astar.findPaths(
  ///   graph,
  ///   'A',
  ///   success: (n) => n.target == 'C',
  /// );
  /// ```
  ///
  /// A more complex condition can be used to stop for another reason:
  ///
  /// ```dart
  /// // Stop when we first cross a river or reach the vertex 'C'.
  /// final paths = astar.findPaths(
  ///   graph,
  ///   'A',
  ///   success: (n) => n.target == 'C',
  /// );
  /// ```
  ///
  /// A default success condition can be created by using [findPathsTo]:
  ///
  /// ```dart
  /// final paths = astar.findPathsTo(graph, 'A', 'C');
  /// ```
  ///
  /// ## Pattern Matching
  ///
  /// You can use pattern matching to determine if a path was found:
  ///
  /// ```dart
  /// final path = astar.findPaths(
  ///   graph,
  ///   star,
  ///   success: (n) => n.target == 'C',
  /// );
  ///
  /// switch (path) {
  ///   case []:
  ///     print('No path found.');
  ///   case [...paths]:
  ///     print('Paths found: $paths');
  /// }
  /// ```
  Iterable<List<VisitedNode<V, E>>> findPaths<V, E>(
    Graph<V, E> graph,
    V start, {
    required bool Function(VisitedNode<V, E>) success,
    bool Function(VisitedNode<V, E>)? visit,
  }) sync* {
    final visited = HashSet<V>();
    final queue = Queue<List<VisitedNode<V, E>>>();

    // Start the traversal from the start vertex.
    queue.add([OriginNode(target: start)]);

    while (queue.isNotEmpty) {
      final path = queue.removeFirst();
      final node = path.last;

      if (!visited.add(node.target)) {
        continue;
      }

      final edges = graph.edgesFrom(node.target);
      for (final (target, edge) in edges) {
        final newNode = TraversedNode(target, edge: edge, origin: node.target);
        final newPath = [...path, newNode];
        if (success(newNode)) {
          yield newPath;
        } else if (visit == null || visit(newNode)) {
          queue.add(newPath);
        }
      }
    }
  }

  /// Returns the each path in the graph that finds the [end] vertex.
  ///
  /// The algorithm takes a [graph], a [start] vertex, and an [end] vertex. The
  /// function returns an iterable of lists that contain the entered vertex and
  /// the edge crossed to reach the end vertex.
  ///
  /// The resulting list of paths are not necessarily ordered by length, and
  /// may contain paths that are not the shortest path. To find the shortest
  /// path, use [findShortestPathsTo], which orders the paths by length (if
  /// necessary, some algorithms return the shortest path first).
  ///
  /// Some algorithims return a maximum of one path.
  ///
  /// See also: [findPaths].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge(1, source: 'A', target: 'B');
  /// graph.addEdge(2, source: 'B', target: 'C');
  /// graph.addEdge(3, source: 'A', target: 'C');
  ///
  /// final paths = astar.findPathsTo(graph, 'A', 'C');
  /// for (final path in paths) {
  ///   print(path);
  /// }
  /// ```
  ///
  /// Produces the following output:
  ///
  /// ```txt
  /// [(A, null), (C, 3)]
  /// [(A, null), (B, 1), (C, 2)]
  /// ```
  @nonVirtual
  Iterable<List<VisitedNode<V, E>>> findPathsTo<V, E>(
    Graph<V, E> graph,
    V start,
    V end,
  ) {
    return findPaths(
      graph,
      start,
      success: (n) => n.target == end,
    );
  }

  /// Returns paths, orderd by length, that satisfy the [success] function.
  ///
  /// The algorithm takes a [graph], a [start] vertex, and a [success] function
  /// that determines whether a path is successful. The function returns a list
  /// of lists that contain the entered vertex and the edge crossed to reach the
  /// success condition, ordered by length (or [weight] if applicable).
  ///
  /// The performance of this method is dependent on the pathfinding algorithm
  /// used. Some algorithms, like [astar] and [dijkstra], return the shortest
  /// path first, while others, like [depthFirst], require sorting the paths.
  ///
  /// Using `.first` with [astar] and [dijkstra] will return the shortest path
  /// without needing to sort the paths, or even compute all paths in the graph:
  ///
  /// ```dart
  /// final shortestPath = astar.findShortestPaths(
  ///   graph,
  ///   'A',
  ///   success: (v, e) => v == 'C',
  /// ).first;
  /// ```
  ///
  /// ## Weights
  ///
  /// By default, the algorithm will consider the shortest path in terms of the
  /// number of edges crossed. A [weight] function can be provided to determine
  /// the weight of an edge using the edge itself:
  ///
  /// ```dart
  /// final graph = Graph<String, Tile>();
  /// final paths = astar.findPaths(
  ///   graph,
  ///   'A',
  ///   success: (v, e) => /* ... */,
  ///   weight: (e) => e == Tile.river ? 2 : 1,
  /// );
  /// ```
  ///
  /// Weights can be combined with [visit] to make certain edges impassable:
  ///
  /// ```dart
  /// final graph = Graph<String, Tile>();
  /// final paths = astar.findPaths(
  ///   graph,
  ///   'A',
  ///   success: (v, e) => /* ... */,
  ///   visit: (v, e) => e != Tile.wall,
  ///   weight: (e) => e.cost,
  /// );
  /// ```
  ///
  /// > [!TIP]
  /// > Creating edges that are impassable is potentially wasteful, as the
  /// > algorithm will still visit the edge and determine that it is impassable.
  /// >
  /// > If possible (i.e. if the graph is static), consider omitting the edges
  /// > entirely (not using [Graph.addEdge]) or by creating a copy of a filtered
  /// > graph using [Graph.where] and [Graph.fromGraph].
  /// >
  /// > ```dart
  /// > final filtered = other.where((v, e) => e != Tile.wall);
  /// > final graph = Graph.fromGraph(filtered);
  /// > final paths = astar.findPaths(graph, 'A', success: (v, e) => /* ... */);
  /// > ```
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge(1, source: 'A', target: 'B');
  /// graph.addEdge(2, source: 'B', target: 'C');
  /// graph.addEdge(3, source: 'A', target: 'C');
  ///
  /// final paths = astar.findShortestPaths(
  ///   graph,
  ///   'A',
  ///   success: (v, e) => v == 'C',
  /// );
  /// for (final path in paths) {
  ///   print(path);
  /// }
  /// ```
  ///
  /// Produces the following output:
  ///
  /// ```txt
  /// [(A, null), (C, 3)]
  /// [(A, null), (B, 1), (C, 2)]
  /// ```
  Iterable<List<VisitedNode<V, E>>> findShortestPaths<V, E>(
    Graph<V, E> graph,
    V start, {
    required bool Function(VisitedNode<V, E>) success,
    bool Function(VisitedNode<V, E>)? visit,
    double Function(E) weight = _defaultWeight,
  }) {
    final paths = List.of(
      findPaths(
        graph,
        start,
        success: success,
        visit: visit,
      ),
    );

    paths.sort((a, b) {
      final weightA = _foldWeight(a, weight);
      final weightB = _foldWeight(b, weight);
      return weightA.compareTo(weightB);
    });

    return paths;
  }

  static double _defaultWeight(void _) {
    return 1.0;
  }

  static double _foldWeight<E>(
    Iterable<VisitedNode<void, E>> path,
    double Function(E) weight,
  ) {
    return path.fold(0, (previousValue, element) {
      return previousValue + _weightOf(element, weight);
    });
  }

  static double _weightOf<E>(
    VisitedNode<void, E> node,
    double Function(E) weight,
  ) {
    if (node is TraversedNode<void, E>) {
      return weight(node.edge);
    }
    return 0;
  }

  /// Returns paths, orderd by length, that find the [end] vertex.
  ///
  /// The algorithm takes a [graph], a [start] vertex, and an [end] vertex. The
  /// function returns a list of lists that contain the entered vertex and the
  /// edge crossed to reach the end vertex, ordered by length (or [weight] if
  /// applicable).
  ///
  /// The performance of this method is dependent on the pathfinding algorithm
  /// used. Some algorithms, like [astar] and [dijkstra], return the shortest
  /// path first, while others, like [depthFirst], require sorting the paths.
  ///
  /// Using `.first` with [astar] and [dijkstra] will return the shortest path
  /// without needing to sort the paths, or even compute all paths in the graph.
  ///
  /// See also: [findShortestPaths] and [findPathsTo].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge(1, source: 'A', target: 'B');
  /// graph.addEdge(2, source: 'B', target: 'C');
  /// graph.addEdge(3, source: 'A', target: 'C');
  ///
  /// final paths = astar.findShortestPathsTo(graph, 'A', 'C');
  /// for (final path in paths) {
  ///   print(path);
  /// }
  /// ```
  ///
  /// Produces the following output:
  ///
  /// ```txt
  /// [(A, null), (C, 3)]
  /// [(A, null), (B, 1), (C, 2)]
  /// ```
  Iterable<List<VisitedNode<V, E>>> findShortestPathsTo<V, E>(
    Graph<V, E> graph,
    V start,
    V end,
    double Function(E) weight,
  ) {
    return findShortestPaths(
      graph,
      start,
      success: (n) => n.target == end,
      weight: weight,
    );
  }
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

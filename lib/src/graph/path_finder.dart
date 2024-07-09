import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

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
  });

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

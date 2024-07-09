import 'package:sector/sector.dart';
import 'package:sector/src/graph/mapped_graph.dart';
import 'package:sector/src/graph/path_finder.dart';
import 'package:sector/src/graph/where_graph.dart';

/// A collection of vertices of type [V] and edges of type [E].
///
/// Graphs describe connections, called [edges], between vertices, where each
/// edge has a source and a target vertex, and optionally data describing the
/// edge, such as a weight or a label.
///
/// Vertices are ephemerally created when adding an edge, and are not stored
/// separately from the edges. This means that vertices are not always
/// explicitly removed when removing an edge, and that vertices are not stored
/// in any particular order.
///
/// ## Performance
///
/// A graph is a potentially complex data structure, and the performance of
/// operations can vary depending on the implementation. For example, an
/// [AdjacencyListGraph], backed by a map of vertices to their outgoing edges,
/// will have `O(1)` edge lookup time, but `O(n)` vertex lookup time.
///
/// Most methods are provided for convenience; prefer using [edgesFrom] to
/// discover edges from a known vertex, rather than using [edges] or [vertices]
/// to iterate over all edges or vertices.
///
/// ## Implementing
///
/// Most users will not need to implement interface, and will instead use the
/// factory methods provided by [Graph], such as [Graph.new], [Graph.fromEdges],
/// which are implemented by [AdjacencyListGraph], or [Graph.withGrid], which is
/// implemented by [LatticeGraph].
///
/// If you do need to implement this interface, you should consider _mixing in_
/// this interface to receive a default implementation of most methods, and then
/// implement the remaining methods, optimizing as necessary.
///
/// ## Example
///
/// ```dart
/// final graph = Graph<String, int>();
/// graph.addEdge('A', 'B', 42);
/// graph.addEdge('B', 'C', 17);
/// print(graph.edges); // => (('A', 'B', 42), ('B', 'C', 17))
/// ```
///
/// {@category Graphs}
abstract mixin class Graph<V, E> {
  /// Creates a new empty graph.
  factory Graph() = AdjacencyListGraph<V, E>;

  /// Creates a graph from an initial mapping of [edges].
  ///
  /// The [edges] is a map of vertices to their outgoing edges, where each edge
  /// is a tuple of the target vertex and the edge value. The graph is created
  /// with the given edges, but any vertices without outgoing edges are omitted.
  ///
  /// This is the inverse of [Graph.toMap].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>.fromEdges({
  ///   'A': {'B': 42},
  ///   'B': {'C': 17},
  /// });
  /// print(graph.edges); // => (('A', 'B', 42), ('B', 'C', 17))
  /// ```
  factory Graph.fromEdges(
    Map<V, Map<V, E>> edges,
  ) = AdjacencyListGraph<V, E>.fromEdges;

  /// Creates a graph from an existing graph.
  ///
  /// The new graph is a shallow copy of the existing graph, where the vertices
  /// and edges are the same as the existing graph. The vertices and edges are
  /// shallow copies, and the new graph is modifiable.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// final copy = Graph.fromGraph(graph);
  /// print(copy.edges); // => (('A', 'B', 42))
  /// ```
  factory Graph.fromGraph(
    Graph<V, E> other,
  ) = AdjacencyListGraph<V, E>.fromGraph;

  /// Creates a new graph viewing the given [grid].
  ///
  /// An implicit edge is created between all [adjacent] positions in the grid
  /// for each position in the grid, with the edge value being a tuple of the
  /// elements at the source and target positions respectively. If an [isEdge]
  /// function is provided, it is used to filter out edges that should not be
  /// included in the graph based on the source and target elements [T]:
  ///
  /// ```dart
  /// final graph = Graph.withGrid(
  ///   grid,
  ///   isEdge: (from, to) => from != Tile.wall && to != Tile.wall,
  /// );
  /// ```
  ///
  /// May optionally provide a set of position offsets to use to automatically
  /// generate edges between positions, which must be non-empty to resolve with
  /// any edges:
  ///
  /// ```dart
  /// final graph = Graph.withGrid(
  ///   grid,
  ///   adjacent: Direction.all,
  /// );
  /// ```
  ///
  /// If not provided, the default is the cardinal directions (up, down, left,
  /// right).
  static Graph<Pos, (T source, T target)> withGrid<T>(
    Grid<T> grid, {
    Iterable<Pos>? adjacent,
    bool Function(T from, T to)? isEdge,
  }) {
    return LatticeGraph.withGrid(
      grid,
      adjacent: adjacent,
      isEdge: isEdge,
    );
  }

  /// Returns `true` if the graph contains no edges or vertices.
  bool get isEmpty;

  /// Returns `true` if the graph contains edges or vertices.
  bool get isNotEmpty;

  /// Returns the current edges of this graph modified to by [toEdge].
  ///
  /// The resulting graph is a lazy view of the original graph, where each edge
  /// is transformed by the given [toEdge] function. The vertices are not
  /// modified, the graph is not copied, and the view is unmodifiable.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// final mapped = graph.map((edge) => edge.toString());
  /// print(mapped.edges); // => (('A', 'B', '42'))
  /// ```
  Graph<V, T> map<T>(T Function(E edge) toEdge) {
    return MappedGraph(this, toEdge);
  }

  /// Returns the current edges of this graph filtered by [predicate].
  ///
  /// The resulting graph is a lazy view of the original graph, where each edge
  /// is filtered by the given [predicate] function. The vertices are not
  /// modified, the graph is not copied, and the view is unmodifiable.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('B', 'C', 17);
  /// final filtered = graph.where((edge) => edge > 40);
  /// print(filtered.edges); // => (('A', 'B', 42))
  /// ```
  Graph<V, E> where(bool Function(E edge) predicate) {
    return WhereGraph(this, predicate);
  }

  /// An iterable of all edges and their source and target vertices.
  ///
  /// Each element is a tuple of three values: the source vertex, the target
  /// vertex, and the edge data, or `(source, target, edge)`. The source and
  /// target vertices are of type [V], and the edge data is of type [E].
  ///
  /// The order of the edges is not guaranteed.
  ///
  /// ## Performance
  ///
  /// This method is typically provided for convenience, but not optimized for
  /// performance. Prefer using [edgesFrom] and [edgesTo] to iterate over edges
  /// from an existing known vertex, rather than using [edges] to iterate over
  /// all edges.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('B', 'C', 17);
  /// print(graph.edges); // => (('A', 'B', 42), ('B', 'C', 17))
  /// ```
  Iterable<(V source, V target, E edge)> get edges {
    return vertices.expand((source) {
      return edgesFrom(source).map((edge) => (source, edge.$1, edge.$2));
    });
  }

  /// An iterable of all vertices in the graph.
  ///
  /// The order of the vertices is not guaranteed. Some implementations,
  /// including the default [AdjacencyListGraph], may not store vertices that
  /// have no edges.
  ///
  /// ## Performance
  ///
  /// This method is typically provided for convenience, but not optimized for
  /// performance. Prefer using [edgesFrom] and [edgesTo] to iterate over edges
  /// from an existing known vertex, rather than using [edges] to iterate over
  /// all edges.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('B', 'C', 17);
  /// print(graph.vertices); // => ('A', 'B', 'C')
  /// ```
  Iterable<V> get vertices;

  /// Adds an edge between different source and target vertices.
  ///
  /// If the source or target vertex does not exist, it is created.
  ///
  /// Adding an edge is unidirectional, meaning that the edge is only added
  /// from the source to the target vertex. To add an edge in the opposite
  /// direction, use [addEdge] with the source and target vertices swapped.
  ///
  /// Returns the previous edge data between the source and target vertices,
  /// or `null` if no edge existed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// print(graph.edges); // => (('A', 'B', 42))
  /// ```
  E? addEdge(E edge, {required V source, required V target});

  /// Removes and returns the edge between the source and target vertices.
  ///
  /// If the source or target vertex has no other edges, it may be removed.
  ///
  /// Returns `null` if no edge existed between the source and target vertices.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// print(graph.addEdge('A', 'B', 42)); // => null
  /// graph.removeEdge('A', 'B');
  /// print(graph.edges); // => {}
  /// ```
  E? removeEdge(V source, V target);

  /// Whether the graph contains the given vertex.
  ///
  /// Returns `true` if the graph contains the vertex, and `false` otherwise.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// print(graph.containsVertex('A')); // => true
  /// print(graph.containsVertex('C')); // => false
  /// ```
  bool containsVertex(V vertex);

  /// Whether the graph contains an edge between the source and target vertices.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// print(graph.containsEdge('A', 'B')); // => true
  /// print(graph.containsEdge('B', 'A')); // => false
  /// ```
  bool containsEdge(V source, V target);

  /// Returns the edge data between the source and target vertices.
  ///
  /// If the edge does not exist, returns `null`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// print(graph.getEdge('A', 'B')); // => 42
  /// print(graph.getEdge('B', 'A')); // => null
  /// ```
  E? getEdge(V source, V target);

  /// Removes all edges and vertices from the graph.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.clear();
  /// print(graph.edges); // => ()
  /// print(graph.vertices); // => ()
  /// ```
  void clear();

  /// Returns an iterable of all target vertices and edge data from [source].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('A', 'C', 17);
  /// print(graph.edgesFrom('A')); // => (('B', 42), ('C', 17))
  /// ```
  Iterable<(V, E)> edgesFrom(V source);

  /// Returns an iterable of all source vertices and edge data to [target].
  ///
  /// This is the inverse of [edgesFrom].
  ///
  /// ## Performance
  ///
  /// This method is provided for convenience, but not typically optimized for
  /// performance. Prefer using [edgesFrom] to iterate over edges from a known
  /// source, rather than [edgesTo] to iterate over all edges to a target.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('C', 'B', 17);
  /// print(graph.edgesTo('B')); // => (('A', 42), ('C', 17))
  /// ```
  Iterable<(V, E)> edgesTo(V target);

  /// Returns the results of the traversing vertices and edges in a graph.
  ///
  /// Traversal algorithms produce a lazy iterable that only visits vertices and
  /// edges when iterated over. The algorithm can be used to find paths, count
  /// paths, or perform other operations on a graph.
  ///
  /// The algorithm takes a [start] vertex, and a [visit] function that
  /// determines whether to visit a vertex and edge. The function returns an
  /// iterable of tuples that contain the entered vertex and the edge crossed to
  /// reach the vertex.
  ///
  /// It is unsupported to modify the graph while traversing it.
  ///
  /// See also [GraphTraversal.traverse] and [GraphTraversal.distinct].
  ///
  /// ## Configuring
  ///
  /// The [using] parameter determines the traversal algorithm to use, and
  /// defaults to [breadthFirst]. A custom traversal algorithm can be provided
  /// by implementing the [GraphTraversal] interface.
  ///
  /// ```dart
  /// graph.traverse('A', using: myTraversal);
  /// ```
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  ///
  /// final traversal = graph.traverse('A');
  /// for (final tuple in traversal) {
  ///   print('Visiting ${tuple.$1} with edge ${tuple.$2}');
  /// }
  /// ```
  ///
  /// Produces the following output:
  ///
  /// ```txt
  /// Visiting A with edge null
  /// Visiting B with edge 42
  /// ```
  Iterable<VisitedNode<V, E>> traverse(
    V start, {
    GraphTraversal using = breadthFirst,
    bool Function(VisitedNode<V, E>)? visit,
  }) {
    return using.traverse(this, start, visit: visit);
  }

  /// Finds all paths starting from [start] that satisfy the [success] function.
  ///
  /// The algorithm takes a [start] vertex, and a [success] function that
  /// determines whether a path is successful. The function returns an iterable
  /// if lists that contain the entered vertex and the edge crossed to reach the
  /// success condition.
  ///
  /// The resulting list of paths are not necessarily ordered by length, and
  /// may contain paths that are not the shortest path. To find the shortest
  /// path, use [findShortestPaths], which orders the paths by length (if
  /// necessary, some algorithms return the shortest path first).
  ///
  /// Some algorithims return a maximum of one path.
  ///
  /// See also [PathFinder.findPaths].
  ///
  /// ## Configuring
  ///
  /// The [using] parameter determines the path finding algorithm to use, and
  /// defaults to [breadthFirst]. A custom path finding algorithm can be
  /// provided by implementing the [PathFinder] interface.
  ///
  /// ```dart
  /// graph.findPaths('A', using: myPathFinder);
  /// ```
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('B', 'C', 17);
  ///
  /// final paths = graph.findPaths('A', 'C', success: (n) => n.target == 'C');
  /// for (final path in paths) {
  ///   print('Found path: $path');
  /// }
  /// ```
  ///
  /// Produces the following output:
  ///
  /// ```txt
  /// [A->B, B->C]
  /// ```
  Iterable<List<VisitedNode<V, E>>> findPaths(
    V start, {
    required bool Function(VisitedNode<V, E>) success,
    PathFinder using = breadthFirst,
    bool Function(VisitedNode<V, E>)? visit,
  }) {
    return using.findPaths(this, start, success: success, visit: visit);
  }

  /// Returns a representation of the graph as a map of vertices to their edges.
  ///
  /// The resulting map is a shallow copy of the graph, where each vertex is
  /// mapped to a map of target vertices to edge data. The vertices and edges
  /// are shallow copies, and the map is disconnected from the original graph.
  ///
  /// This is the inverse of [Graph.fromEdges].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// final edges = graph.toEdgesMap();
  /// print(edges); // => {'A': {'B': 42}}
  /// ```
  Map<V, Map<V, E>> toMap() {
    return {
      for (final source in vertices)
        source: {
          for (final (target, edge) in edgesFrom(source)) target: edge,
        },
    };
  }
}

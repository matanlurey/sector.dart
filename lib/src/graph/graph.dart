import 'package:sector/sector.dart';

/// A collection of vertices of type [V] and edges of type [E].
///
/// Graphs describe connections, called [edges], between vertices, where each
/// edge has a source and a target vertex, and optionally data describing the
/// edge, such as a weight or a label.
///
/// Vertices are ephemerally created when adding an edge, and are not stored
/// separately from the edges. This means that vertices are not explicitly
/// removed when removing an edge, and that vertices are not stored in any
/// particular order.
///
/// ## Performance
///
/// A graph is a potentially complex data structure, and the performance of
/// operations can vary depending on the implementation. For example, an
/// [AdjacencyListGraph], backed by a map of vertices to their outgoing edges,
/// will have `O(1)` edge lookup time, but `O(n)` vertex lookup time.
///
/// ## Example
///
/// TODO: ...
abstract mixin class Graph<V, E> {
  /// Returns `true` if the graph contains no edges or vertices.
  bool get isEmpty;

  /// Returns `true` if the graph contains edges or vertices.
  bool get isNotEmpty;

  /// An iterable of all edges and their source and target vertices.
  ///
  /// Each element is a tuple of three values: the source vertex, the target
  /// vertex, and the edge data, or `(source, target, edge)`. The source and
  /// target vertices are of type [V], and the edge data is of type [E].
  ///
  /// The order of the edges is not guaranteed.
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
  /// The order of the vertices is not guaranteed.
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

  /// Adds an edge between the source and target vertices.
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
  /// If the source or target vertex has no other edges, it is removed.
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
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// graph.addEdge('C', 'B', 17);
  /// print(graph.edgesTo('B')); // => (('A', 42), ('C', 17))
  /// ```
  Iterable<(V, E)> edgesTo(V target);
}

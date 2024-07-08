import 'package:sector/sector.dart';

/// A graph data structure that uses an adjacency list to represent edges.
///
/// An adjacency list graph is useful for sparse graphs, where the number of
/// edges is much smaller than the number of vertices. It is less efficient
/// for dense graphs, where the number of edges is close to the number of
/// vertices.
///
/// {@category Graphs}
final class AdjacencyListGraph<V, E> with Graph<V, E> {
  /// Creates a new graph from an initial mapping of [edges].
  ///
  /// The [edges] is a map of vertices to their outgoing edges, where each edge
  /// is a tuple of the target vertex and the edge value. The graph is created
  /// with the given edges, but any vertices without outgoing edges are omitted.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = AdjacencyListGraph.fromEdges({
  ///   'A': {'B': 42},
  ///   'B': {'C': 17},
  /// });
  /// print(graph.edges); // => (('A', 'B', 42), ('B', 'C', 17))
  /// ```
  factory AdjacencyListGraph.fromEdges(Map<V, Map<V, E>> edges) {
    final graph = AdjacencyListGraph<V, E>();
    for (final MapEntry(key: source, value: targets) in edges.entries) {
      for (final MapEntry(key: target, value: edge) in targets.entries) {
        graph.addEdge(edge, source: source, target: target);
      }
    }
    return graph;
  }

  /// Creates a graph from an existing graph.
  ///
  /// The new graph is a shallow copy of the existing graph, where the vertices
  /// and edges are the same as the existing graph. The vertices and edges are
  /// shallow copies, and the new graph is modifiable.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = AdjacencyListGraph<String, int>();
  /// graph.addEdge(42, source: 'A', target: 'B');
  /// final copy = AdjacencyListGraph.fromGraph(graph);
  /// print(copy.edges); // => (('A', 'B', 42))
  /// ```
  factory AdjacencyListGraph.fromGraph(Graph<V, E> other) {
    if (other is AdjacencyListGraph<V, E>) {
      final map = other._adjacencyList.map((key, value) {
        return MapEntry(key, List.of(value));
      });
      return AdjacencyListGraph._(map);
    }

    final graph = AdjacencyListGraph<V, E>();
    for (final edges in other.edges) {
      graph.addEdge(edges.$3, source: edges.$1, target: edges.$2);
    }

    return graph;
  }

  /// Creates an empty adjacency list graph.
  ///
  /// The graph is initially empty, with no vertices or edges.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = AdjacencyListGraph<String, int>();
  /// print(graph.isEmpty); // => true
  ///
  /// graph.addEdge(42, source: 'A', target: 'B');
  /// print(graph.isEmpty); // => false
  /// ```
  AdjacencyListGraph() : this._({});

  /// A map of vertices to their outgoing edges.
  ///
  /// Every vertex, regardless of outgoing edges, is stored in the map.
  final Map<V, List<(V, E)>> _adjacencyList;
  const AdjacencyListGraph._(this._adjacencyList);

  @override
  bool get isEmpty => _adjacencyList.isEmpty;

  @override
  bool get isNotEmpty => _adjacencyList.isNotEmpty;

  /// An iterable of all vertices in the graph.
  ///
  /// The order of the vertices is not guaranteed.
  @override
  Iterable<V> get vertices => _adjacencyList.keys;

  @override
  E? addEdge(E edge, {required V source, required V target}) {
    // Check that the vertices are not equal.
    if (source == target) {
      throw ArgumentError.value(
        target,
        'target',
        'The source and target vertices must be different.',
      );
    }

    // Get the list of edges for the source vertex.
    final edges = _adjacencyList.putIfAbsent(source, () => []);

    // If the edge already exists, update the value.
    E? existing;
    var found = false;
    for (var i = 0; i < edges.length; i++) {
      final (v, e) = edges[i];
      if (v == target) {
        existing = e;
        edges[i] = (target, edge);
        found = true;
        break;
      }
    }

    // If the edge does not exist, add it.
    if (!found) {
      edges.add((target, edge));
    }

    // Ensure the target vertex is in the graph as well.
    _adjacencyList.putIfAbsent(target, () => []);

    return existing;
  }

  @override
  E? removeEdge(V source, V target) {
    // Get the list of edges for the source vertex.
    final edges = _adjacencyList[source];

    // If the source vertex does not exist, return null.
    if (edges == null) {
      return null;
    }

    // Find the edge and remove it.
    E? existing;
    for (var i = 0; i < edges.length; i++) {
      final (v, e) = edges[i];
      if (v == target) {
        existing = e;
        edges.removeAt(i);
        break;
      }
    }

    // If the source vertex has no other edges, remove it.
    if (edges.isEmpty) {
      _adjacencyList.remove(source);
    }

    // Check the target vertex and remove it if it has no other edges.
    final targetEdges = _adjacencyList[target];
    if (targetEdges != null && targetEdges.isEmpty) {
      _adjacencyList.remove(target);
    }

    return existing;
  }

  @override
  bool containsVertex(V vertex) => _adjacencyList.containsKey(vertex);

  @override
  bool containsEdge(V source, V target) {
    final edges = _adjacencyList[source];
    if (edges == null) {
      return false;
    }
    for (final edge in edges) {
      if (edge.$1 == target) {
        return true;
      }
    }
    return false;
  }

  @override
  E? getEdge(V source, V target) {
    final edges = _adjacencyList[source];
    if (edges == null) {
      return null;
    }
    for (final edge in edges) {
      if (edge.$1 == target) {
        return edge.$2;
      }
    }
    return null;
  }

  @override
  void clear() {
    _adjacencyList.clear();
  }

  @override
  Iterable<(V, E)> edgesFrom(V source) => _adjacencyList[source]!;

  @override
  Iterable<(V, E)> edgesTo(V target) {
    // Check if the target vertex is in the graph.
    if (!_adjacencyList.containsKey(target)) {
      return const Iterable.empty();
    }

    // Find all edges that point to the target vertex.
    return _adjacencyList.entries.expand((entry) {
      final MapEntry(key: vertex, value: edges) = entry;

      // Find all edges that point to the target vertex.
      return edges.where((edge) => edge.$1 == target).map((edge) {
        return (vertex, edge.$2);
      });
    });
  }
}

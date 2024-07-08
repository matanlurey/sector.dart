import 'dart:collection';

import 'package:sector/sector.dart';

/// A graph data structure that uses an adjacency list to represent edges.
///
/// An adjacency list graph is useful for sparse graphs, where the number of
/// edges is much smaller than the number of vertices. It is less efficient
/// for dense graphs, where the number of edges is close to the number of
/// vertices.
final class AdjacencyListGraph<V, E> with Graph<V, E> {
  /// Creates an empty adjacency list graph.
  ///
  /// The graph is initially empty, with no vertices or edges.
  AdjacencyListGraph() : this._({});

  /// A map of vertices to their outgoing edges.
  final Map<V, List<(V, E)>> _adjacencyList;
  const AdjacencyListGraph._(this._adjacencyList);

  @override
  bool get isEmpty => _adjacencyList.isEmpty;

  @override
  bool get isNotEmpty => _adjacencyList.isNotEmpty;

  /// An iterable of all vertices in the graph.
  ///
  /// The order of the vertices is not guaranteed.
  ///
  /// This property is lazy but has memory overhead as the number of visited
  /// vertices increases. Prefer lazily iterating over [edges] for large graphs.
  @override
  Iterable<V> get vertices sync* {
    final visited = HashSet<V>();
    for (final source in _adjacencyList.keys) {
      if (visited.add(source)) {
        yield source;
      }
      for (final edge in _adjacencyList[source]!) {
        final target = edge.$1;
        if (visited.add(target)) {
          yield target;
        }
      }
    }
  }

  @override
  E? addEdge(E edge, {required V source, required V target}) {
    final edges = _adjacencyList.putIfAbsent(source, () => []);
    for (var i = 0; i < edges.length; i++) {
      final option = edges[i];
      if (option.$1 == target) {
        final previous = option.$2;
        edges[i] = (target, edge);
        return previous;
      }
    }
    edges.add((target, edge));
    return null;
  }

  @override
  E? removeEdge(V source, V target) {
    final edges = _adjacencyList[source];
    if (edges == null) {
      return null;
    }
    for (final edge in edges) {
      if (edge.$1 == target) {
        edges.remove(edge);
        return edge.$2;
      }
    }
    return null;
  }

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
  Iterable<(V, E)> edgesFrom(V source) {
    return _adjacencyList[source] ?? const Iterable.empty();
  }

  @override
  Iterable<(V, E)> edgesTo(V target) {
    return _adjacencyList.entries.expand((entry) {
      final source = entry.key;
      return entry.value
          .where((edge) => edge.$1 == target)
          .map((edge) => (source, edge.$2));
    });
  }
}

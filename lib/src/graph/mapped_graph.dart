import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

/// A collection of vertices of type [V] and edges [S] mapped to type [T].
///
/// This graph is an unmodifiable view of a graph with vertices of type [V] and
/// edges of type [S], where the edges are mapped to type [T]. The graph is
/// read-only, and does not allow modifications.
@internal
final class MappedGraph<V, S, T> with Graph<V, T>, UnmodifiableGraph<V, T> {
  const MappedGraph(this._graph, this._mapper);
  final Graph<V, S> _graph;
  final T Function(S) _mapper;

  @override
  bool get isEmpty => _graph.isEmpty;

  @override
  bool get isNotEmpty => _graph.isNotEmpty;

  @override
  Iterable<(V source, V target, T edge)> get edges {
    return _graph.edges.map((edge) {
      return (edge.$1, edge.$2, _mapper(edge.$3));
    });
  }

  @override
  Iterable<V> get vertices {
    return _graph.vertices;
  }

  @override
  bool containsVertex(V vertex) {
    return _graph.containsVertex(vertex);
  }

  @override
  bool containsEdge(V source, V target) {
    return _graph.containsEdge(source, target);
  }

  @override
  T? getEdge(V source, V target) {
    final edge = _graph.getEdge(source, target);
    if (edge == null) {
      if (edge is S && _graph.containsEdge(source, target)) {
        return _mapper(edge);
      }
      return null;
    }
    return _mapper(edge);
  }

  @override
  Iterable<(V, T)> edgesFrom(V source) {
    return _graph.edgesFrom(source).map((edge) {
      return (edge.$1, _mapper(edge.$2));
    });
  }

  @override
  Iterable<(V, T)> edgesTo(V target) {
    return _graph.edgesTo(target).map((edge) {
      return (edge.$1, _mapper(edge.$2));
    });
  }
}

import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

/// A collection of vertices of type [V] and edges [S].
///
/// This graph is an unmodifiable view of a graph where certain edges are
/// filtered out. The graph is read-only, and does not allow modifications.
@internal
final class WhereGraph<V, S> with Graph<V, S>, UnmodifiableGraph<V, S> {
  const WhereGraph(this._graph, this._predicate);
  final Graph<V, S> _graph;
  final bool Function(S) _predicate;

  @override
  bool get isEmpty => _graph.isEmpty;

  @override
  bool get isNotEmpty => _graph.isNotEmpty;

  @override
  Iterable<(V source, V target, S edge)> get edges {
    return _graph.edges.where((edge) => _predicate(edge.$3));
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
  S? getEdge(V source, V target) {
    final edge = _graph.getEdge(source, target);
    if (edge == null) {
      return null;
    }
    return _predicate(edge) ? edge : null;
  }

  @override
  Iterable<(V, S)> edgesFrom(V source) {
    return _graph.edgesFrom(source).where((edge) => _predicate(edge.$2));
  }

  @override
  Iterable<(V, S)> edgesTo(V target) {
    return _graph.edgesTo(target).where((edge) => _predicate(edge.$2));
  }
}

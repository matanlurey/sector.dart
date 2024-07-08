import 'package:sector/sector.dart';
import 'package:sector/src/graph/mapped_graph.dart';

/// A read-only collection of vertices of type [V] and edges of type [E].
///
/// This mixin has a basic implementation of the [Graph] interface, where all
/// methods that modify the graph throw [UnsupportedError], leaving the rest
/// unimplemented.
///
/// To create a _view_ of an existing graph, use [UnmodifiableGraph.withGraph].
///
/// {@category Graphs}
abstract mixin class UnmodifiableGraph<V, E> implements Graph<V, E> {
  /// Creates a a view of a [Graph] that disallows modifications.
  ///
  /// A wrapper around a [Graph] that forwards all read-only operations to the
  /// underlying graph, but throws an [UnsupportedError] when attempting to
  /// modify the graph.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final graph = Graph<String, int>();
  /// graph.addEdge('A', 'B', 42);
  /// final view = UnmodifiableGraphView(graph);
  /// print(view.edges); // => (('A', 'B', 42))
  /// view.addEdge(42, source: 'B', target: 'C'); // => throws UnsupportedError
  /// ```
  factory UnmodifiableGraph.withGraph(Graph<V, E> graph) {
    return MappedGraph(graph, _identity);
  }

  static T _identity<T>(T value) => value;

  static Never _unsupported() {
    throw UnsupportedError('Cannot modify unmodifiable graph');
  }

  @override
  E? addEdge(E edge, {required V source, required V target}) {
    return _unsupported();
  }

  @override
  E? removeEdge(V source, V target) {
    return _unsupported();
  }

  @override
  void clear() {
    _unsupported();
  }
}

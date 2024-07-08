import 'package:sector/sector.dart';

/// A graph data structure that uses a [Grid] to represent vertices and edges.
///
/// A latice graph implicitly creates edges between _all_ adjacent vertices in
/// the grid. This is useful for grid-based games, such as chess, checkers, or
/// roguelikes, but has a high memory overhead for sparse graphs or graphs where
/// significantly fewer edges are needed.
///
/// Each vertice in the grid is a position within the grid, and each edge is a
/// tuple of two elements: the element at the source position, and the element
/// at the target position, using a provided adjacency function.
///
/// Edges cannot not be explicitly added or removed from the graph at runtime.
final class LatticeGraph<T> with Graph<Pos, (T source, T target)> {
  /// Creates a new lattice graph viewing the given [grid].
  ///
  /// An implicit edge is created between all [adjacent] positions in the grid
  /// for each position in the grid, with the edge value being a tuple of the
  /// elements at the source and target positions respectively.
  ///
  /// May optionally provide a set of position offsets to use to automatically
  /// generate edges between positions, which must be non-empty to resolve with
  /// any edges. If not provided, the default is the cardinal directions (up,
  /// down, left, right).
  factory LatticeGraph.view(
    Grid<T> grid, {
    Iterable<Pos>? adjacent,
  }) {
    return LatticeGraph._(
      grid,
      adjacent != null ? List.of(adjacent) : Direction.cardinal,
    );
  }

  LatticeGraph._(this._grid, this._adjacent);
  final Grid<T> _grid;
  final List<Pos> _adjacent;

  @override
  bool get isEmpty => !isNotEmpty;

  @override
  bool get isNotEmpty => _grid.width > 1 || _grid.height > 1;

  @override
  Iterable<(Pos source, Pos target, (T source, T target))> get edges {
    return _EdgesIterable(this);
  }

  @override
  Iterable<Pos> get vertices {
    return Iterable.generate(_grid.width * _grid.height, (index) {
      return Pos(index % _grid.width, index ~/ _grid.width);
    });
  }

  @override
  (T, T)? addEdge((T, T) edge, {required Pos source, required Pos target}) {
    throw UnsupportedError('Edges cannot be modified in a lattice graph');
  }

  @override
  (T, T)? removeEdge(Pos source, Pos target) {
    throw UnsupportedError('Edges cannot be modified in a lattice graph');
  }

  @override
  bool containsEdge(Pos source, Pos target) {
    if (!_grid.containsPos(source) || !_grid.containsPos(target)) {
      return false;
    }
    for (final pos in _adjacent) {
      if (source + pos == target) {
        return true;
      }
    }
    return false;
  }

  @override
  (T, T)? getEdge(Pos source, Pos target) {
    if (containsEdge(source, target)) {
      return (_grid.getUnchecked(source), _grid.getUnchecked(target));
    }
    return null;
  }

  @override
  void clear() {
    throw UnsupportedError('Edges cannot be modified in a lattice graph');
  }

  @override
  Iterable<(Pos, (T, T))> edgesFrom(Pos source) {
    return _EdgesFromIterable(this, source, _adjacent);
  }

  late final _edgesTo = List.of(_adjacent.map((pos) => -pos));

  @override
  Iterable<(Pos, (T, T))> edgesTo(Pos target) {
    return _EdgesFromIterable(this, target, _edgesTo);
  }
}

final class _EdgesIterable<T> extends Iterable<(Pos, Pos, (T, T))> {
  const _EdgesIterable(this._graph);
  final LatticeGraph<T> _graph;

  @override
  Iterator<(Pos, Pos, (T, T))> get iterator {
    return _EdgesIterator(_graph);
  }
}

final class _EdgesIterator<T> implements Iterator<(Pos, Pos, (T, T))> {
  _EdgesIterator(this._graph);

  final LatticeGraph<T> _graph;

  var _x = 0;
  var _y = 0;
  var _index = 0;

  @override
  late (Pos, Pos, (T, T)) current;

  @override
  bool moveNext() {
    for (; _y < _graph._grid.height; _y++) {
      for (; _x < _graph._grid.width; _x++) {
        final source = Pos(_x, _y);
        for (; _index < _graph._adjacent.length; _index++) {
          final target = source + _graph._adjacent[_index];
          if (_graph._grid.containsPos(target)) {
            current = (
              source,
              target,
              (
                _graph._grid.getUnchecked(source),
                _graph._grid.getUnchecked(target),
              ),
            );
            _index++;
            return true;
          }
        }
        _index = 0;
      }
      _x = 0;
    }
    return false;
  }
}

final class _EdgesFromIterable<T> extends Iterable<(Pos, (T, T))> {
  const _EdgesFromIterable(this._graph, this._source, this._adjacent);
  final LatticeGraph<T> _graph;
  final Pos _source;
  final List<Pos> _adjacent;

  @override
  Iterator<(Pos, (T, T))> get iterator {
    return _EdgesFromIterator(_graph, _source, _adjacent);
  }
}

final class _EdgesFromIterator<T> implements Iterator<(Pos, (T, T))> {
  _EdgesFromIterator(this._graph, this._source, this._adjacent);

  final LatticeGraph<T> _graph;
  final Pos _source;
  final List<Pos> _adjacent;
  var _index = 0;

  @override
  late (Pos, (T, T)) current;

  @override
  bool moveNext() {
    for (; _index < _adjacent.length; _index++) {
      final target = _source + _adjacent[_index];
      if (_graph._grid.containsPos(target)) {
        current = (
          target,
          (
            _graph._grid.getUnchecked(_source),
            _graph._grid.getUnchecked(target),
          ),
        );
        _index++;
        return true;
      }
    }
    return false;
  }
}

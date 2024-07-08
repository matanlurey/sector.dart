import 'package:sector/sector.dart';

/// A graph data structure that uses a [Grid] to represent vertices and edges.
///
/// A latice graph implicitly creates edges between adjacent vertices in the
/// grid. This is useful for grid-based games, such as chess, checkers, or
/// roguelikes, but has a high memory overhead for sparse graphs or graphs where
/// significantly fewer edges are needed.
///
/// Each vertice in the grid is a position within the grid, and each edge is a
/// tuple of two elements: the element at the source position, and the element
/// at the target position, using a provided adjacency function.
///
/// ## Caveats
///
/// Edges **cannot** not be explicitly added or removed from the graph at
/// runtime, and methods such as [addEdge], [removeEdge], and [clear] throw
/// an [UnsupportedError] if called.
///
/// For pathfinding or other graph algorithms where edges are intended to have
/// an order or weight, you may use a sentinel value or an artificially high
/// value (such as [double.infinity]) to represent the edge weight of an
/// impassable edge or provide a custom `isEdge` function to filter out edges:
///
/// ```dart
/// final graph = LatticeGraph.withGrid(
///   grid,
///   isEdge: (fromTile, toTile) => toTile != Tile.wall,
/// );
/// ```
///
/// ## Performance
///
/// The lattice graph is a dense graph, where the number of edges is equal to
/// the number of vertices times the number of adjacent positions. This means
/// that the number of edges is `O(n^2)`, where `n` is the number of vertices.
///
/// For games or simulations where the grid is small, the lattice graph is a
/// simple and efficient way to represent the graph. For larger grids, or grids
/// where the number of edges is significantly less than the number of vertices,
/// consider building up and maintaining an [AdjacencyListGraph] separately.
///
/// ## Example
///
/// ```dart
/// final grid = Grid.fromRows([
///   [Tile.wall, Tile.wall],
///   [Tile.wall, Tile.empty],
/// ]);
/// final graph = LatticeGraph.withGrid(grid);
/// print(graph.edges); // => ((Pos(0, 0), Pos(1, 0), (Tile.wall, Tile.wall)), ...)
/// ```
///
/// {@category Graphs}
abstract final class LatticeGraph<T> with Graph<Pos, (T source, T target)> {
  /// Creates a new lattice graph viewing the given [grid].
  ///
  /// An implicit edge is created between all [adjacent] positions in the grid
  /// for each position in the grid, with the edge value being a tuple of the
  /// elements at the source and target positions respectively. If an [isEdge]
  /// function is provided, it is used to filter out edges that should not be
  /// included in the graph based on the source and target elements [T]:
  ///
  /// ```dart
  /// final graph = LatticeGraph.withGrid(
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
  /// final graph = LatticeGraph.withGrid(
  ///   grid,
  ///   adjacent: Direction.all,
  /// );
  /// ```
  ///
  /// If not provided, the default is the cardinal directions (up, down, left,
  /// right).
  factory LatticeGraph.withGrid(
    Grid<T> grid, {
    Iterable<Pos>? adjacent,
    bool Function(T from, T to)? isEdge,
  }) {
    return _LatticeGraph(
      grid,
      adjacent != null ? List.of(adjacent) : Direction.cardinal,
      isEdge,
    );
  }

  const LatticeGraph._();
}

/// An unmodifiable view of a [LatticeGraph].
typedef _Unmodifiable<T> = UnmodifiableGraph<Pos, (T, T)>;

final class _LatticeGraph<T> extends LatticeGraph<T> with _Unmodifiable<T> {
  _LatticeGraph(this._grid, this._adjacent, this._isEdge) : super._();
  final Grid<T> _grid;
  final List<Pos> _adjacent;
  final bool Function(T from, T to)? _isEdge;

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
  bool containsVertex(Pos vertex) => _grid.containsPos(vertex);

  @override
  bool containsEdge(Pos source, Pos target) {
    if (!containsVertex(source) || !containsVertex(target)) {
      return false;
    }
    for (final pos in _adjacent) {
      if (source + pos == target) {
        // Implicit edge exists between source and target.
        if (_isEdge == null) {
          return true;
        }

        // Check if the edge is valid based on the source and target elements.
        final sourceElement = _grid.getUnchecked(source);
        final targetElement = _grid.getUnchecked(target);
        if (_isEdge(sourceElement, targetElement)) {
          return true;
        }
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
  final _LatticeGraph<T> _graph;

  @override
  Iterator<(Pos, Pos, (T, T))> get iterator {
    return _EdgesIterator(_graph);
  }
}

final class _EdgesIterator<T> implements Iterator<(Pos, Pos, (T, T))> {
  _EdgesIterator(this._graph);

  final _LatticeGraph<T> _graph;

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
          if (!_graph._grid.containsPos(target)) {
            continue;
          }
          if (_graph._isEdge != null) {
            final sourceElement = _graph._grid.getUnchecked(source);
            final targetElement = _graph._grid.getUnchecked(target);
            if (!_graph._isEdge(sourceElement, targetElement)) {
              continue;
            }
          }
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
        _index = 0;
      }
      _x = 0;
    }
    return false;
  }
}

final class _EdgesFromIterable<T> extends Iterable<(Pos, (T, T))> {
  const _EdgesFromIterable(this._graph, this._source, this._adjacent);
  final _LatticeGraph<T> _graph;
  final Pos _source;
  final List<Pos> _adjacent;

  @override
  Iterator<(Pos, (T, T))> get iterator {
    return _EdgesFromIterator(_graph, _source, _adjacent);
  }
}

final class _EdgesFromIterator<T> implements Iterator<(Pos, (T, T))> {
  _EdgesFromIterator(this._graph, this._source, this._adjacent);

  final _LatticeGraph<T> _graph;
  final Pos _source;
  final List<Pos> _adjacent;
  var _index = 0;

  @override
  late (Pos, (T, T)) current;

  @override
  bool moveNext() {
    for (; _index < _adjacent.length; _index++) {
      final target = _source + _adjacent[_index];
      if (!_graph._grid.containsPos(target)) {
        continue;
      }
      if (_graph._isEdge != null) {
        final sourceElement = _graph._grid.getUnchecked(_source);
        final targetElement = _graph._grid.getUnchecked(target);
        if (!_graph._isEdge(sourceElement, targetElement)) {
          continue;
        }
      }
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
    return false;
  }
}

import 'package:sector/sector.dart';

/// A function that finds a path between two points in a graph.
///
/// The function takes a [graph], a [start] position, a [success] function, and
/// returns an iterable of positions that represent the path between the two
/// points, starting with the [start] position and ending with either with the
/// first position that satisfies the [success] function.
///
/// An empty iterable is returned if no path is found, and an iterable with only
/// the [start] position is returned if the success condition is met
/// immediately. No repeated positions are returned.
///
/// ## Success Condition
///
/// Typically, the success condition is when the entered position is equal to
/// an end position, but for flexibility, [success] is provided as a function
/// that takes the entered position and the edge crossed, and returns a boolean.
///
/// For a simple "hit end" condition, the success function can be:
///
/// ```dart
/// final graph = Graph<String, Tile>();
///
/// // Stop when the end is hit.
/// final path = findPath(
///   graph,
///   start,
///   success: (entered, _) => entered == end,
/// );
/// ```
///
/// A more complex condition can be used to stop for another reason:
///
/// ```dart
/// final graph = Graph<String, Tile>();
///
/// // Stop when the end is hit, or we reach a chest.
/// final path = findPath(
///   graph,
///   start,
///   end,
///   success: (entered, edge) => entered == end || edge == Tile.chest,
/// );
/// ```
///
/// ## Weights
///
/// By default, [E] has a uniform weight (i.e. `1`), which means that the
/// algorithm will find the shortest path in terms of the number of edges
/// crossed. If [E] is [Comparable], the algorithm will use the edge itself as
/// the weight:
///
/// ```dart
/// // An example where the edge (double) is already comparable.
/// final graph = Graph<String, double>();
/// final path = findPath(graph, start, success: (v, e) => /* ... */);
/// ```
///
/// If the edge is not comparable, a [weight] function can be provided, which
/// transforms the edge into a comparable value. For example, if the edge is a
/// pair of tiles, the heuristic could be the sum of the costs crossing the
/// edge:
///
/// ```dart
/// enum Tile {
///   grass(1),
///   mud(2);
///
///   const Tile(this.cost);
///   final int cost;
/// }
///
/// final graph = Graph<int, (Tile, Tile)>();
/// final path = findPath(
///   graph,
///   start,
///   success: (v, e) => /* ... */,
///   weight: (tiles) {
///     final (from, to) = tiles;
///     return from.cost + to.cost;
///   },
/// );
/// ```
///
/// ## Pattern Matching
///
/// It is recommended to use pattern matching to determine if a path was found:
///
/// ```dart
/// final path = findPath(graph, start, end);
/// switch (path) {
///   case []:
///     print('No path found.');
///   case [start, ...path, end]:
///     print('Path found from $start->$end: $path');
/// }
/// ```
typedef FindPath = Iterable<Pos> Function<V, E>(
  Graph<V, E> graph,
  Pos start, {
  required bool Function(V entered, E? crossed) success,
  Comparable<void> Function(E)? weight,
});

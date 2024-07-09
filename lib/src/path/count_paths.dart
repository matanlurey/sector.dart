import 'dart:collection';

import 'package:sector/sector.dart';

/// Counts the total number of possible paths to reach a destination.
///
/// ## Example
///
/// On a 8x8 board, find the paths from the top-left corner to the bottom-right:
///
/// ```dart
/// find grid = Grid.filled(8, 8, 0);
/// final graph = Graph.withGrid(grid);
///
/// final paths = countPaths(
///   graph,
///   Pos(0, 0),
///   success: (entered, _) => entered == Pos(7, 7),
/// );
/// print(paths); // 3432
/// ```
int countPaths<V, E>(
  Graph<V, E> graph,
  V start, {
  required bool Function(V entered, E? crossed) success,
}) {
  return _cachedCountPaths<V, E>(
    graph,
    start,
    null,
    cache: HashMap(),
    visited: HashSet(),
    success: success,
  );
}

int _cachedCountPaths<V, E>(
  Graph<V, E> graph,
  V start,
  V? previous, {
  required Map<V, int> cache,
  required Set<V> visited,
  required bool Function(V entered, E? crossed) success,
}) {
  // Existing path count.
  if (cache[start] case final int solution) {
    return solution;
  }

  // Avoid cycles.
  if (visited.contains(start)) {
    return 0;
  }

  // Success condition.
  if (success(
    start,
    previous != null ? graph.getEdge(previous, start) : null,
  )) {
    return 1;
  }

  // Mark the current vertex as visited.
  visited.add(start);

  // Recursively count paths from each neighbor.
  var count = 0;
  for (final (target, _) in graph.edgesFrom(start)) {
    count += _cachedCountPaths(
      graph,
      target,
      start,
      cache: cache,
      visited: visited,
      success: success,
    );
  }

  // Save the result in the cache.
  cache[start] = count;

  // Unmark the current vertex.
  visited.remove(start);

  // Returns the total number of paths from start to a success condition.
  return count;
}

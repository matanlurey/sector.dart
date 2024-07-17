import 'package:lodim/lodim.dart';
import 'package:sector/sector.dart';

/// Visualizes the results of traversing a grid _as_ a grid.
final class DebugGridTracer<E> with Tracer<Pos> {
  DebugGridTracer(
    this.grid, {
    required this.start,
    required this.end,
  }) : _last = start {
    clear();
  }

  final Grid<E> grid;
  final Pos start;
  final Pos end;

  late Grid<String> _render;
  Pos _last;

  @override
  void clear() {
    _render = Grid.filled(grid.width, grid.height, empty: '▓', fill: '░');

    // Set all empty cells to '▓'.
    for (final (pos, cell) in grid.cells) {
      if (cell == grid.empty) {
        _render[pos] = '▓';
      }
    }
  }

  @override
  void onVisit(Pos node) {
    // Update the pos with the previous direction.
    _render[node] = _getDirectionalChar(node - _last, _render[node]);
    _last = node;
  }

  @override
  void onSkip(Pos node) {}

  @override
  void pushScalar(TraceKey key, double value) {}
}

String _getDirectionalChar(Pos direction, [String? existing]) {
  return switch (direction) {
    Direction.left when existing == '→' => '↔',
    Direction.right when existing == '←' => '↔',
    Direction.left => '←',
    Direction.right => '→',
    Direction.up when existing == '↓' => '↕',
    Direction.down when existing == '↑' => '↕',
    Direction.up => '↑',
    Direction.down => '↓',
    _ => throw StateError('Invalid direction: $direction'),
  };
}

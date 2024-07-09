Grids are one of two data structures provided by `package:sector`, providing
a way to store and manipulate data in a tabular format indexed by rows and
columns, or `(x, y)` coordinates, and with a fixed `width` and `height` in
cells.

- [Creating a Grid](#creating-a-grid)
- [Accessing Cells](#accessing-cells)
- [Iteration](#iteration)
- [Advanced Topics](#advanced-topics)
  - [Picking an implementation](#picking-an-implementation)
  - [Using `Pos` effectively](#using-pos-effectively)
  - [Converting to a `Graph`](#converting-to-a-graph)

## Creating a Grid

To create a new grid filled with a default value, use `Grid.filled`. This is
useful when you want to start with an initial state, and then update the
values as needed, such as procedurally generating a map or providing a tile
editor for a game:

```dart
import 'package:sector/sector.dart';

enum Tile {
  empty,
  wall,
  floor,
}

void main() {
  final grid = Grid.filled(10, 10, Tile.empty);

  // Set a tile at (0, 0) to a wall.
  grid.set(0, 0, Tile.wall);

  // Set a tile at (1, 0) to a floor.
  grid.set(1, 0, Tile.floor);

  // ...
}
```

To load a grid from an existing data structure, use one of the following:

- `Grid.fromIterable` to create a grid from a row-major iterable of values.
- `Grid.fromRows` to create a grid from a list-of-lists of values.
- `Grid.generate` to create a grid from a delegate function.

For example, to load from an external data source or delegate function:

```dart
void main() {
  final grid = Grid.generate(10, 10, (pos) {
    return _loadTile(pos.x, pos.y);
  });
}
```

Or to create a quick in-memory representation that is human readable:

```dart
void main() {
  final grid = Grid.fromRows([
    [Tile.empty, Tile.empty, Tile.empty, Tile.empty, Tile.empty],
    [Tile.floor, Tile.floor, Tile.floor, Tile.floor, Tile.floor],
    [Tile.empty, Tile.empty, Tile.empty, Tile.empty, Tile.empty],
  ]);
}
```

## Accessing Cells

To access a cell in a grid, use the `get` method with a `Pos` position object.

For example, to get the value at `(0, 0)`:

```dart
void main() {
  final grid = Grid.filled(10, 10, Tile.empty);

  final tile = grid.get(Pos(0, 0));
}
```

Likewise, to set the value at `(0, 0)`:

```dart
void main() {
  final grid = Grid.filled(10, 10, Tile.empty);

  grid.set(Pos(0, 0), Tile.wall);
}
```

## Iteration

Two built-in methods are provided for iteration, `rows` and `columns`.

For example, to iterate over each row in a grid:

```dart
void main() {
  final grid = Grid.filled(10, 10, Tile.empty);

  for (final row in grid.rows) {
    for (final tile in row) {
      print(tile);
    }
  }
}
```

## Advanced Topics

### Picking an implementation

The default implementation of `Grid` is `ListGrid`, which is backed by a
1-dimensional dense list storing the values in row-major order. This is
efficient for small to medium-sized grids, but can be slow for large grids
or grids with sparse data (e.g. a map with mostly empty tiles).

For large grids or sparse data, consider using `SplayTreeGrid`:

```dart
void main() {
  // Uses no memory until a value is set.
  final grid = SplayTreeGrid.filled(1000, 1000, Tile.empty);
}
```

### Using `Pos` effectively

This pacakge re-exports a few structures from [`package:lodim`][lodim], a
fixed-point 2D geometry library. One of these is `Pos`, which is used to
represent a 2D point with integer coordinates, and has a number of useful
built-in methods, for example `distanceTo` amd `lineTo`:

```dart
import 'package:lodim/lodim.dart';

void main() {
  final pos1 = Pos(0, 0);
  final pos2 = Pos(3, 4);

  print(pos1.distanceTo(pos2, using: euclideanApproximate)); // 5
}
```

```dart
import 'package:lodim/lodim.dart';

void main() {
  final pos1 = Pos(0, 0);
  final pos2 = Pos(3, 4);

  for (final pos in pos1.lineTo(pos2)) {
    print(pos);
  }
}
```

Outputs the following:

```txt
Pos(0, 0)
Pos(1, 1)
Pos(2, 2)
Pos(3, 3)
Pos(3, 4)
```

See [`package:lodim`][lodim] for more information and additional features.

[lodim]: https://pub.dev/packages/lodim

### Converting to a `Graph`

A grid can be converted to a graph using `Graph.withGrid`, which uses a
`LatticeGraph` to represent the grid as a graph with implicit edges between
adjacent cells:

```dart
void main() {
  final grid = Grid.filled(10, 10, Tile.empty);
  final graph = Graph.withGrid(grid);
}
```

See [Pathfinding](Pathfinding-topic.html) for more information on using graphs
for pathfinding.

---

<div style="text-align: center">

[Graphs ►](Graphs-topic.html)

</a>

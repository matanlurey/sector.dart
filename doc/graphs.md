Graphs are the other main data structure in `package:sector`, providing a way
to represent a graph of nodes and edges. This can be used to represent a map,
network, or any other connected data structure that can be represented as a
directed graph.

> [!NOTE]
> Graphs in `package:sector` are directed, meaning that edges have a direction
> from one node to another, and implicitly create nodes as needed to represent
> the graph. In other words, nodes without edges are not explicitly represented
> in the default graph implementations.

- [Creating a Graph](#creating-a-graph)
- [Accessing Nodes and Edges](#accessing-nodes-and-edges)
- [Transforming and filtering edges](#transforming-and-filtering-edges)
- [Traversing a graph](#traversing-a-graph)
- [Advanced Topics](#advanced-topics)
  - [Creating from a `Grid`](#creating-from-a-grid)
  - [Speeding up graph operations with `Graph.fromGraph`](#speeding-up-graph-operations-with-graphfromgraph)

## Creating a Graph

To create a new graph, use `Graph()`, which creates an empty graph. You can
then add edges as needed:

```dart
import 'package:sector/sector.dart';

void main() {
  final graph = Graph<String, String>();

  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('A->C', 'A', 'C');
}
```

Or, from existing edge data:

```dart
void main() {
  final graph = Graph.fromEdges({
    'A->B': ['A', 'B'],
    'A->C': ['A', 'C'],
  });
}
```

To add or remove edges, use the `addEdge` and `removeEdge` methods:

```dart
void main() {
  final graph = Graph<String, String>();

  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('A->C', 'A', 'C');

  graph.removeEdge('A->B');
}
```

Or to check if a vertex or edge exists, use the `containsVertex` and
`containsEdge` methods:

```dart
void main() {
  final graph = Graph<String, String>();

  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('A->C', 'A', 'C');

  print(graph.containsVertex('A')); // true
  print(graph.containsEdge('A->B')); // true
}
```

## Accessing Nodes and Edges

The optimal usage of a graph is using the `edgesFrom` method to get the edges
from a known vertex:

```dart
void main() {
  final graph = Graph.fromEdges({
    'A->B': ['A', 'B'],
    'A->C': ['A', 'C'],
  });

  final edges = graph.edgesFrom('A');
  print(edges); // ['A->B', 'A->C']
}
```

Other methods exist primarily as a convenience, such as `vertices`, `edges`,
and `edgesTo`. Most implementations of `Graph` will have these methods, but
they may not be as efficient as `edgesFrom`, and should be carefully profiled
for performance-critical code.

## Transforming and filtering edges

The `map` method can be used to transform the edges of a graph, for example to
add weights to the edges:

```dart
import 'package:sector/sector.dart';

enum Tile {
  /// Open clear space.
  grass,

  /// Terrain that slows movement by 50%.
  mud;
}

void main() {
  final graph = Graph.fromEdges({
    'A': {
      'B': Tile.grass,
    },
    'B': {
      'C': Tile.mud,
    },
  });

  final weightedGraph = graph.map((data) {
    final (_, edge) = data;
    return edge == Tile.mud ? 2 : 1;
  });

  print(weightedGraph.edges); // ((A->B, 1), (B->C, 2))
}
```

The `where` method can be used to filter the edges of a graph, for example to
remove edges with a certain property:

```dart
void main() {
  final graph = Graph.fromEdges({
    'A': {
      'B': Tile.water,
    },
    'B': {
      'C': Tile.grass,
    },
  });

  final filteredGraph = graph.where((data) {
    final (_, edge) = data;
    return edge != Tile.water;
  });

  print(filteredGraph.edges); // ['A->C']
}
```

See [Pathfinding](Pathfinding-topic.html) for more information on using graphs
for pathfinding.

## Traversing a graph

To traverse a graph, use the `traverse` method, which takes a starting vertex:

```dart
void main() {
  // A -> B -> C
  final graph = Graph();
  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('B->C', 'B', 'C');

  final traversal = graph.traverse('A').toList();
  print(traversal); // [('A', null), ('B', 'A->B'), ('C', 'B->C')]
}
```

It defaults to a breadth-first traversal, but can be customized with the
`using` parameter.

For example using `depthFirst` instead:

```dart
void main() {
  // A -> B -> C
  final graph = Graph();
  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('B->C', 'B', 'C');

  final traversal = graph.traverse('A', using: depthFirst()).toList();
  print(traversal); // [('C', 'B->C'), ('B', 'A->B'), ('A', null)]
}
```

The `visit` parameter can be used to customize _which_ vertices are visited:

```dart
void main() {
  // A -> B -> C
  final graph = Graph();
  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('B->C', 'B', 'C');

  final traversal = graph.traverse('A', visit: (v, _) => v != 'B').toList();
  print(traversal); // [('A', null)]
}
```

In some cases, such as with circular graphs, or bi-directional vertices, it may
be _necessary_ to use a custom `visit` function to avoid infinite loops.
Fortunately, `sector` includes a built-in `.distinct` sub-function that avoids
visiting the same vertex more than once:

```dart
void main() {
  // A -> B -> C -> A
  final graph = Graph();
  graph.addEdge('A->B', 'A', 'B');
  graph.addEdge('B->C', 'B', 'C');
  graph.addEdge('C->A', 'C', 'A');

  final traversal = graph.traverse('A', using: breadthFirst.distinct).toList();
  print(traversal); // [('A', null), ('B', 'A->B'), ('C', 'B->C')]
}
```

## Advanced Topics

### Creating from a `Grid`

A graph can be created from a grid using the `Graph.withGrid` constructor,
which uses a `LatticeGrid` to represent the grid as a graph with implicit
edges between adjacent cells:

```dart
void main() {
  final grid = Grid.filled(10, 10, Tile.empty);
  final graph = Graph.withGrid(grid);
}
```

See [Pathfinding](Pathfinding-topic.html) for more information on using graphs
for pathfinding.

### Speeding up graph operations with `Graph.fromGraph`

Operations that create an ephemeral graph, such as `Graph.withGrid` or `map`,
are doing additional work at runtime to emulate a graph data structure without
explicitly storing the nodes and edges. For performance-critical code, or where
the edges do not change or change rarely, it may be beneficial to convert the
graph to an explicit graph using `Graph.fromGraph`:

```dart
void main() {
  final grid = Grid.filled(10, 10, Tile.empty);
  final graph = Graph.withGrid(grid);

  final explicitGraph = Graph.fromGraph(graph);
}
```

This will create a new graph with the same nodes and edges as the original
graph, but with explicit storage of the nodes and edges, which can be faster
for some operations. Profile your code to determine if this is necessary.

---

<div style="text-align: center">

[◄ Grids](Grids-topic.html) |
[Pathfinding ►](Pathfinding-topic.html)

</div>

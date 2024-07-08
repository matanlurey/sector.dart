/// A 🔥 _fast_ (benchmarked) and 👍🏼 _intuitive_ (idiomatic) 2D Grid API.
///
/// ## Usage
///
/// Most users will only interact directly with the [Grid] interface, which
/// is a 2-dimensional counterpart to the [List] interface with a full featured
/// API:
///
/// ```dart
/// final grid = Grid.fromRows([
///   [Tile.wall, Tile.wall, Tile.wall],
///   [Tile.wall, Tile.empty, Tile.empty],
/// ]);
/// print(grid);
/// // ┌───────┐
/// // │ # # # │
/// // │ # _ _ │
/// // └───────┘
/// ```
///
/// ## Caveats
///
/// This package will always provide _2D_ data structures. If you need three
/// or more dimensions, look elsewhere. A [Grid] is a _container_ for all kinds
/// of data; if you need to perform matrix operations, you are better off with
/// a dedicated linear algebra library, such as [`vector_math`][vector_math].
///
/// [vector_math]: https://pub.dev/packages/vector_math
///
/// ## Performance
///
/// The default [Grid] implementation, [ListGrid], is optimized and benchmarked
/// for similar performance to using a 1-dimensional [List] for a 2-dimensional
/// grid, but with a more intuitive API.
///
/// For better `Grid<int>` or `Grid<double>` performance, use
/// [ListGrid.backedBy] with a backing store of a typed data list, such as
/// [Uint8List] or [Float32List], which can be used to store elements more
/// efficiently:
/// ```dart
/// final buffer = Uint8List(9);
/// final grid = ListGrid.backedBy(buffer, width: 3);
/// print(grid);
/// // ┌───────┐
/// // │ 0 0 0 │
/// // │ 0 0 0 │
/// // │ 0 0 0 │
/// // └───────┘
/// ```
library;

import 'dart:typed_data';

import 'package:sector/sector.dart';

export 'package:lodim/lodim.dart' show Direction, Pos, Rect;

export 'src/graph/adjacency_list_graph.dart';
export 'src/graph/graph.dart';
export 'src/graph/lattice_graph.dart';
export 'src/grid/grid.dart';
export 'src/grid/list_grid.dart';
export 'src/grid/splay_tree_grid.dart';

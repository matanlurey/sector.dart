import 'dart:convert';

import 'package:sector/sector.dart';

enum Tile {
  passableDot,
  passableG,
  outOfBoundsAtSign,
  outOfBoundsO,
  impassableTrees,
  swampPassableFromRegularTerrain,
  waterTraversableButNotPassableFromTerrain;

  factory Tile.parse(String char) {
    return switch (char) {
      '.' => Tile.passableDot,
      'G' => Tile.passableG,
      '@' => Tile.outOfBoundsAtSign,
      'O' => Tile.outOfBoundsO,
      'T' => Tile.impassableTrees,
      'S' => Tile.swampPassableFromRegularTerrain,
      'W' => Tile.waterTraversableButNotPassableFromTerrain,
      _ => throw FormatException('Invalid tile character', char, 0),
    };
  }

  @override
  String toString() {
    return switch (this) {
      Tile.passableDot => '.',
      Tile.passableG => 'G',
      Tile.outOfBoundsAtSign => '@',
      Tile.outOfBoundsO => 'O',
      Tile.impassableTrees => 'T',
      Tile.swampPassableFromRegularTerrain => 'S',
      Tile.waterTraversableButNotPassableFromTerrain => 'W',
    };
  }
}

/// Loads a map from the text content of the map format.
///
/// See `./test/pathfinding/scenarios/README.md` for more information.
Grid<Tile> loadMap(String contents) {
  final lines = const LineSplitter().convert(contents);
  if (lines.length < 4) {
    throw FormatException('Invalid map format', contents, 0);
  }

  // Line 1: "type <type>".
  if (lines[0].split(' ') case ['type', final String type]) {
    if (type != 'octile') {
      throw FormatException('Invalid map type', lines[0], 0);
    }
  } else {
    throw FormatException('Invalid map format', contents, 0);
  }

  // Line 2: "height <height>".
  final int height;
  if (lines[1].split(' ') case ['height', final String size]) {
    final sizeInt = int.tryParse(size);
    if (sizeInt == null || sizeInt < 0) {
      throw FormatException('Invalid map height', lines[1], 0);
    }
    height = sizeInt;
  } else {
    throw FormatException('Invalid map format', contents, 1);
  }

  // Line 3: "width <width>".
  final int width;
  if (lines[2].split(' ') case ['width', final String size]) {
    final sizeInt = int.tryParse(size);
    if (sizeInt == null || sizeInt < 0) {
      throw FormatException('Invalid map width', lines[2], 0);
    }
    width = sizeInt;
  } else {
    throw FormatException('Invalid map format', contents, 2);
  }

  // Line 4: "map".
  if (lines[3] != 'map') {
    throw FormatException('Invalid map format', contents, 3);
  }

  // Parse the remaining lines
  final output = Grid<Tile>.filled(width, height, empty: Tile.passableDot);
  for (var y = 0; y < height; y++) {
    final line = lines[4 + y];
    if (line.length != width) {
      throw FormatException('Invalid map line length', line, 0);
    }
    for (var x = 0; x < width; x++) {
      output[Pos(x, y)] = Tile.parse(line[x]);
    }
  }

  return output;
}

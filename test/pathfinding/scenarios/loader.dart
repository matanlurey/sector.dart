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
  bool get isPassable {
    return this == Tile.passableDot || this == Tile.passableG;
  }

  bool get isOutOfBounds {
    return this == Tile.outOfBoundsAtSign || this == Tile.outOfBoundsO;
  }

  bool get isImpassable => this == Tile.impassableTrees;

  bool get isSwamp => this == Tile.swampPassableFromRegularTerrain;

  bool get isWater => this == Tile.waterTraversableButNotPassableFromTerrain;

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

/// Converts a map to a graph.
WeightedWalkable<Pos> mapAsGraph(Grid<Tile> map) {
  return GridWalkable.all8Directions(
    map,
    weight: (from, to) {
      if (from.isPassable && to.isPassable) {
        return 1;
      } else if (from.isSwamp && to.isPassable) {
        return 2;
      } else if (from.isWater && to.isPassable) {
        return 3;
      } else if (from.isPassable && to.isSwamp) {
        return 2;
      } else if (from.isPassable && to.isWater) {
        return 3;
      } else {
        return double.infinity;
      }
    },
  );
}

final class Scenario {
  const Scenario({
    required this.bucket,
    required this.map,
    required this.width,
    required this.height,
    required this.start,
    required this.goal,
    required this.optimalLength,
  });

  final int bucket;
  final String map;
  final int width;
  final int height;
  final Pos start;
  final Pos goal;
  final double optimalLength;

  @override
  String toString() {
    return 'Scenario(bucket: $bucket, map: $map, width: $width, height: $height, start: $start, goal: $goal, optimalLength: $optimalLength)';
  }
}

final _scenDelim = RegExp(r'\s+');

/// Loads a list of scenarios from the text content of the scenarios format.
///
/// See `./test/pathfinding/scenarios/README.md` for more information.
List<Scenario> loadScenarios(String contents) {
  // Split the contents into lines
  final lines = const LineSplitter().convert(contents);

  // Expect the first line to be "version 1"
  if (lines.isEmpty || lines[0] != 'version 1') {
    throw FormatException('Invalid scenarios format', contents, 0);
  }

  // Parse the remaining lines
  final output = <Scenario>[];
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = line.split(_scenDelim);
    if (parts.length != 9) {
      throw FormatException('Invalid scenario format', line, 0);
    }

    final bucket = int.tryParse(parts[0]);
    final width = int.tryParse(parts[2]);
    final height = int.tryParse(parts[3]);
    final startX = int.tryParse(parts[4]);
    final startY = int.tryParse(parts[5]);
    final goalX = int.tryParse(parts[6]);
    final goalY = int.tryParse(parts[7]);
    final optimalLength = double.tryParse(parts[8]);

    if (bucket == null ||
        width == null ||
        height == null ||
        startX == null ||
        startY == null ||
        goalX == null ||
        goalY == null ||
        optimalLength == null) {
      throw FormatException('Invalid scenario format', line, 0);
    }

    final start = Pos(startX, startY);
    final goal = Pos(goalX, goalY);

    output.add(
      Scenario(
        bucket: bucket,
        map: parts[1],
        width: width,
        height: height,
        start: start,
        goal: goal,
        optimalLength: optimalLength,
      ),
    );
  }

  return output;
}

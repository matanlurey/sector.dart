import 'package:sector/sector.dart';

/// A named [Pos] direction in a 2D space.
sealed class Direction {
  /// Orders directions clockwise, starting at [north].
  static const Comparator<Direction> byClockwise = _clockwise;
  static int _clockwise(Direction a, Direction b) {
    return a.combinedIndex - b.combinedIndex;
  }

  /// Orders directions counter-clockwise, starting at [north].
  static const Comparator<Direction> byCounterClockwise = _counterClockwise;
  static int _counterClockwise(Direction a, Direction b) {
    return b.combinedIndex - a.combinedIndex;
  }

  /// The four cardinal directions.
  ///
  /// The order is `north`, `east`, `south`, and `west`.
  static const List<Direction> cardinal = Cardinal.values;

  /// The four ordinal directions.
  ///
  /// The order is `northEast`, `southEast`, `southWest`, and `northWest`.
  static const List<Direction> ordinals = Ordinal.values;

  /// Combined ordinal and cardinal directions.
  ///
  /// The order is clockwise starting from `north`:
  /// - `[0]`: `north`
  /// - `[1]`: `northEast`
  /// - `[2]`: `east`
  /// - `[3]`: `southEast`
  /// - `[4]`: `south`
  /// - `[5]`: `southWest`
  /// - `[6]`: `west`
  /// - `[7]`: `northWest`
  static const List<Direction> values = [
    north,
    northEast,
    east,
    southEast,
    south,
    southWest,
    west,
    northWest,
  ];

  /// The direction pointing up, or reducing the `y` value by one.
  static const Direction north = Cardinal.north;

  /// The direction pointing right, or increasing the `x` value by one.
  static const Direction east = Cardinal.east;

  /// The direction pointing down, or increasing the `y` value by one.
  static const Direction south = Cardinal.south;

  /// The direction pointing left, or reducing the `x` value by one.
  static const Direction west = Cardinal.west;

  /// The direction pointing up and right, i.e. `x + 1, y - 1`.
  static const Direction northEast = Ordinal.northEast;

  /// The direction pointing down and right, i.e. `x + 1, y + 1`.
  static const Direction southEast = Ordinal.southEast;

  /// The direction pointing down and left, i.e. `x - 1, y + 1`.
  static const Direction southWest = Ordinal.southWest;

  /// The direction pointing up and left, i.e. `x - 1, y - 1`.
  static const Direction northWest = Ordinal.northWest;

  /// The index of this direction within [Direction.values].
  int get combinedIndex;

  /// The index of this direction within its enum declaration.
  ///
  /// For example, the index of [Direction.east] is `2`.
  ///
  /// > [!IMPORTANT]
  /// > For the the index within [Direction.values], use [combinedIndex].
  int get index;

  /// The offset of this direction from the origin.
  Pos get offset;

  /// Returns the direction that is the opposite of this direction.
  ///
  /// For example, the opposite of `north` is `south`.
  Direction get reverse;

  /// Returns the direction rotated by 45 degrees in the clockwise direction.
  ///
  /// Provide a negative [steps] to rotate in the counter-clockwise direction.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(Direction.north.rotate45()); // Direction.northEast
  /// print(Direction.north.rotate45(2)); // Direction.southEast
  /// print(Direction.north.rotate45(-1)); // Direction.northWest
  /// ```
  Direction rotate45([int steps = 1]);

  /// Returns the direction rotated by 90 degrees in the clockwise direction.
  ///
  /// Provide a negative [steps] to rotate in the counter-clockwise direction.
  ///
  /// ## Example
  ///
  /// ```dart
  /// print(Direction.north.rotate90()); // Direction.east
  /// print(Direction.north.rotate90(2)); // Direction.south
  /// print(Direction.north.rotate90(-1)); // Direction.west
  /// ```
  Direction rotate90([int steps = 1]);

  /// Whether this direction is an [Ordinal] direction.
  bool get isOrdinal;

  /// Whether this direction is a [Cardinal] direction.
  bool get isCardinal;

  @pragma('vm:prefer-inline')
  static Direction _rotate45(int steps, {required Direction from}) {
    final newIndex = from.combinedIndex + steps;
    return Direction.values[newIndex % Direction.values.length];
  }
}

/// A cardinal, or main, direction in a 2D space.
///
/// The four cardinal directions are [north], [east], [south], and [west], which
/// can also be accessed as [Cardinal.values], where they are indexed in the
/// same order: `north` (0), `east` (1), `south` (2), and `west` (3).
///
/// ## Example
///
/// ```dart
/// final direction = Cardinal.values[0];
/// print(direction); // Cardinal.north
/// ```
enum Cardinal implements Direction {
  /// The direction pointing up, or reducing the `y` value by one.
  north(Pos.north),

  /// The direction pointing right, or increasing the `x` value by one.
  east(Pos.east),

  /// The direction pointing down, or increasing the `y` value by one.
  south(Pos.south),

  /// The direction pointing left, or reducing the `x` value by one.
  west(Pos.west);

  const Cardinal(this.offset);

  @override
  int get combinedIndex => index * 2;

  @override
  final Pos offset;

  @override
  Direction get reverse {
    return switch (this) {
      Direction.north => Direction.south,
      Direction.east => Direction.west,
      Direction.south => Direction.north,
      Direction.west => Direction.east,
    };
  }

  @override
  Direction rotate45([int steps = 1]) => Direction._rotate45(steps, from: this);

  @override
  Cardinal rotate90([int steps = 1]) {
    var newIndex = index + steps;
    if (newIndex < 0) {
      newIndex += Cardinal.values.length;
    }
    return Cardinal.values[newIndex % Cardinal.values.length];
  }

  @override
  bool get isOrdinal => false;

  @override
  bool get isCardinal => true;
}

/// An ordinal, or intercardinal, direction in a 2D space.
///
/// The four ordinal directions are [northEast], [southEast], [southWest], and
/// [northWest], which can also be accessed as [Ordinal.values], where they are
/// indexed in the same order: `northEast` (0), `southEast` (1), `southWest`
/// (2), and `northWest` (3).
///
/// ## Example
///
/// ```dart
/// final direction = Ordinal.values[0];
/// print(direction); // Ordinal.northEast
/// ```
enum Ordinal implements Direction {
  /// The direction pointing up and right, i.e. `x + 1, y - 1`.
  northEast(Pos.northEast),

  /// The direction pointing down and right, i.e. `x + 1, y + 1`.
  southEast(Pos.southEast),

  /// The direction pointing down and left, i.e. `x - 1, y + 1`.
  southWest(Pos.southWest),

  /// The direction pointing up and left, i.e. `x - 1, y - 1`.
  northWest(Pos.northWest);

  const Ordinal(this.offset);

  @override
  int get combinedIndex => index * 2 + 1;

  @override
  final Pos offset;

  @override
  Direction get reverse {
    return switch (this) {
      Direction.northEast => Direction.southWest,
      Direction.southEast => Direction.northWest,
      Direction.southWest => Direction.northEast,
      Direction.northWest => Direction.southEast,
    };
  }

  @override
  Direction rotate45([int steps = 1]) => Direction._rotate45(steps, from: this);

  @override
  Ordinal rotate90([int steps = 1]) {
    var newIndex = index + steps;
    if (newIndex < 0) {
      newIndex += Ordinal.values.length;
    }
    return Ordinal.values[newIndex % Ordinal.values.length];
  }

  @override
  bool get isOrdinal => true;

  @override
  bool get isCardinal => false;
}

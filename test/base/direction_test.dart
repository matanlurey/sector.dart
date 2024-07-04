import '../_prelude.dart';

void main() {
  for (final direction in Direction.values) {
    test('$direction is only equal to itself', () {
      final allButDirection = Direction.values.where((d) => d != direction);
      check(direction).equals(direction);
      check(allButDirection).not((b) => b.contains(direction));
    });
  }

  test('Direction.north is Cardinal.north', () {
    check(Direction.north).equals(Cardinal.north);
  });

  test('Direction.east is Cardinal.east', () {
    check(Direction.east).equals(Cardinal.east);
  });

  test('Direction.south is Cardinal.south', () {
    check(Direction.south).equals(Cardinal.south);
  });

  test('Direction.west is Cardinal.west', () {
    check(Direction.west).equals(Cardinal.west);
  });

  test('Direction.northEast is Ordinal.northEast', () {
    check(Direction.northEast).equals(Ordinal.northEast);
  });

  test('Direction.southEast is Ordinal.southEast', () {
    check(Direction.southEast).equals(Ordinal.southEast);
  });

  test('Direction.southWest is Ordinal.southWest', () {
    check(Direction.southWest).equals(Ordinal.southWest);
  });

  test('Direction.northWest is Ordinal.northWest', () {
    check(Direction.northWest).equals(Ordinal.northWest);
  });

  test('Direction.byClockwise should sort directions', () {
    final directions = Direction.values.toList();

    // Shuffle 10 times and check if the list is sorted each time.
    for (var i = 0; i < 10; i++) {
      directions.shuffle();
      directions.sort(Direction.byClockwise);
      check(directions).deepEquals(Direction.values);
    }
  });

  test('Direction.byCounterClockwise should sort directions', () {
    final directions = Direction.values.toList().reversed.toList();

    // Shuffle 10 times and check if the list is sorted each time.
    for (var i = 0; i < 10; i++) {
      directions.shuffle();
      directions.sort(Direction.byCounterClockwise);
      check(directions).deepEquals(Direction.values.reversed);
    }
  });

  test('every Direcion.cardinal is cardinal and in the same order', () {
    check(Direction.cardinal).deepEquals(Cardinal.values);
    check(Direction.cardinal).every(
      (b) => b.has((p) => p.isCardinal, 'isCardinal').isTrue(),
    );
    check(Direction.cardinal).every(
      (b) => b.has((p) => p.isOrdinal, 'isOrdinal').isFalse(),
    );
  });

  test('every Direcion.ordinals is ordinals and in the same order', () {
    check(Direction.ordinals).deepEquals(Ordinal.values);
    check(Direction.ordinals).every(
      (b) => b.has((p) => p.isOrdinal, 'isOrdinal').isTrue(),
    );
    check(Direction.ordinals).every(
      (b) => b.has((p) => p.isCardinal, 'isCardinal').isFalse(),
    );
  });

  test('Direction.all is in sorted order', () {
    check(Direction.values).deepEquals([
      Direction.north,
      Direction.northEast,
      Direction.east,
      Direction.southEast,
      Direction.south,
      Direction.southWest,
      Direction.west,
      Direction.northWest,
    ]);
  });

  ({
    Direction.north: (0, -1),
    Direction.northEast: (1, -1),
    Direction.east: (1, 0),
    Direction.southEast: (1, 1),
    Direction.south: (0, 1),
    Direction.southWest: (-1, 1),
    Direction.west: (-1, 0),
    Direction.northWest: (-1, -1),
  }).forEach((direction, expected) {
    final (x, y) = expected;
    test('$direction.offset is $expected', () {
      check(direction.offset).equals(Pos(x, y));
    });
  });

  ({
    Direction.north: Direction.south,
    Direction.northEast: Direction.southWest,
    Direction.east: Direction.west,
    Direction.southEast: Direction.northWest,
    Direction.south: Direction.north,
    Direction.southWest: Direction.northEast,
    Direction.west: Direction.east,
    Direction.northWest: Direction.southEast,
  }).forEach((direction, opposite) {
    test('$direction.reverse is $opposite', () {
      check(direction.reverse).equals(opposite);
    });
  });

  group('rotate90', () {
    ({
      Direction.north: Direction.east,
      Direction.northEast: Direction.southEast,
      Direction.east: Direction.south,
      Direction.southEast: Direction.southWest,
      Direction.south: Direction.west,
      Direction.southWest: Direction.northWest,
      Direction.west: Direction.north,
      Direction.northWest: Direction.northEast,
    }).forEach((direction, rotated) {
      test('$direction.rotate90(1) is $rotated', () {
        check(direction.rotate90()).equals(rotated);
      });
    });

    ({
      Direction.north: Direction.west,
      Direction.northEast: Direction.northWest,
      Direction.east: Direction.north,
      Direction.southEast: Direction.northEast,
      Direction.south: Direction.east,
      Direction.southWest: Direction.southEast,
      Direction.west: Direction.south,
      Direction.northWest: Direction.southWest,
    }).forEach((direction, rotated) {
      test('$direction.rotate90(-1) is $rotated', () {
        check(direction.rotate90(-1)).equals(rotated);
      });
    });
  });

  group('rotate45', () {
    ({
      Direction.north: Direction.northEast,
      Direction.northEast: Direction.east,
      Direction.east: Direction.southEast,
      Direction.southEast: Direction.south,
      Direction.south: Direction.southWest,
      Direction.southWest: Direction.west,
      Direction.west: Direction.northWest,
      Direction.northWest: Direction.north,
    }).forEach((direction, rotated) {
      test('$direction.rotate45(1) is $rotated', () {
        check(direction.rotate45()).equals(rotated);
      });
    });

    ({
      Direction.north: Direction.northWest,
      Direction.northEast: Direction.north,
      Direction.east: Direction.northEast,
      Direction.southEast: Direction.east,
      Direction.south: Direction.southEast,
      Direction.southWest: Direction.south,
      Direction.west: Direction.southWest,
      Direction.northWest: Direction.west,
    }).forEach((direction, rotated) {
      test('$direction.rotate45(-1) is $rotated', () {
        check(direction.rotate45(-1)).equals(rotated);
      });
    });
  });
}

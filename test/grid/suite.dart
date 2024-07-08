import '../prelude.dart';

void runSuiteGridFilled(
  Grid<T> Function<T>(int width, int height, T fill) filled,
) {
  test('should create a grid with the same element', () {
    final grid = filled(3, 2, '#');
    check(grid.rows).deepEquals([
      ['#', '#', '#'],
      ['#', '#', '#'],
    ]);
  });

  test('should create an empty grid if width is 0', () {
    final grid = filled(0, 2, '#');
    check(grid.rows).isEmpty();
  });

  test('should create an empty grid if height is 0', () {
    final grid = filled(3, 0, '#');
    check(grid.rows).isEmpty();
  });

  test('should throw when width is negative', () {
    check(() => filled(-1, 2, '#')).throws<RangeError>();
  });

  test('should throw when height is negative', () {
    check(() => filled(3, -1, '#')).throws<RangeError>();
  });
}

void runSuiteGridGenerate(
  Grid<T> Function<T>(
    int width,
    int height,
    T Function(Pos) generator,
  ) generate,
) {
  test('should create a grid with the generated elements', () {
    final grid = generate(3, 2, (pos) => '(${pos.x}, ${pos.y})');
    check(grid.rows).deepEquals([
      ['(0, 0)', '(1, 0)', '(2, 0)'],
      ['(0, 1)', '(1, 1)', '(2, 1)'],
    ]);
  });

  test('should create an empty grid if width is 0', () {
    final grid = generate(0, 2, (pos) => pos.toString());
    check(grid.rows).isEmpty();
  });

  test('should create an empty grid if height is 0', () {
    final grid = generate(3, 0, (pos) => pos.toString());
    check(grid.rows).isEmpty();
  });

  test('should throw when width is negative', () {
    check(() => generate(-1, 2, (pos) => pos.toString())).throws<RangeError>();
  });

  test('should throw when height is negative', () {
    check(() => generate(3, -1, (pos) => pos.toString())).throws<RangeError>();
  });
}

void runSuiteGridFromGrid(
  Grid<T> Function<T>(Grid<T> other) fromGrid,
) {
  test('should create a grid with the same elements as a ListGrid', () {
    final other = ListGrid.fromRows([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
    final grid = fromGrid(other);
    check(grid.rows).deepEquals([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
  });

  test('should create a grid with the same elements as a NaiveListGrid', () {
    final other = NaiveListGrid.fromRows([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
    final grid = fromGrid(other);
    check(grid.rows).deepEquals([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
  });

  test('should create an empty grid if the other grid is empty', () {
    final grid = fromGrid<String>(Grid.empty());
    check(grid.rows).isEmpty();
  });
}

void runSuiteGridFromRows(
  Grid<T> Function<T>(Iterable<Iterable<T>> rows) fromRows,
) {
  test('should create a grid with the provided rows', () {
    final grid = fromRows([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
    check(grid.rows).deepEquals([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
  });

  test('should create an empty grid if the rows are empty', () {
    final grid = fromRows([]);
    check(grid.rows).isEmpty();
  });

  test('should throw when the rows are not of equal length', () {
    check(
      () => fromRows([
        ['a', 'b'],
        ['d', 'e', 'f'],
      ]),
    ).throws<ArgumentError>();
  });
}

void runSuiteGridFromIterable(
  Grid<T> Function<T>(Iterable<T> elements, {required int width}) fromIterable,
) {
  test('should create a grid with the provided elements', () {
    final grid = fromIterable(['a', 'b', 'c', 'd', 'e', 'f'], width: 3);
    check(grid.rows).deepEquals([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
  });

  test('should create an empty grid if the elements are empty', () {
    final grid = fromIterable([], width: 3);
    check(grid.rows).isEmpty();
  });

  test('should throw when the elements are not a multiple of the width', () {
    check(
      () => fromIterable(['a', 'b', 'c', 'd', 'e'], width: 3),
    ).throws<ArgumentError>();
  });
}

void runSuiteGridEmpty(Grid<T> Function<T>() empty) {
  test('should create an empty grid', () {
    final grid = empty<void>();
    check(grid.rows).isEmpty();
  });
}

void runSuiteGridBody(
  Grid<T> Function<T>(Iterable<Iterable<T>> rows) fromRows,
) {
  test('should reflect the number of columns as "width"', () {
    final grid = fromRows([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
    check(grid.width).equals(3);
  });

  test('should reflect the number of rows as "height"', () {
    final grid = fromRows([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
    check(grid.height).equals(2);
  });

  test('should return isEmpty when empty', () {
    final grid = fromRows([]);
    check(grid.isEmpty).isTrue();
    check(grid.isNotEmpty).isFalse();
  });

  test('should return isNotEmpty when not empty', () {
    final grid = fromRows([
      ['a', 'b', 'c'],
    ]);
    check(grid.isNotEmpty).isTrue();
    check(grid.isEmpty).isFalse();
  });

  test('should return if the grid contains an element', () {
    final grid = fromRows([
      ['a', 'b', 'c'],
      ['d', 'e', 'f'],
    ]);
    check(grid.contains('e')).isTrue();
    check(grid.contains('x')).isFalse();
  });

  test('should return if a grid contains a position in bounds', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.containsPos(Pos(1, 1))).isTrue();
    check(grid.containsPos(Pos(2, 1))).isFalse();
  });

  test('should return if a grid contains a bounding box rectangle', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.containsRect(Rect.fromLTWH(0, 0, 2, 1))).isTrue();
    check(grid.containsRect(Rect.fromLTWH(1, 0, 2, 1))).isFalse();
  });

  test('getUnchecked should return the element at the position', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.getUnchecked(Pos(1, 0))).equals('b');
  });

  test('get should return the element at the position', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.get(Pos(1, 0))).equals('b');
  });

  test('get should throw when the position is out of bounds', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(() => grid.get(Pos(2, 0))).throws<RangeError>();
  });

  test('setUnchecked should set the element at the position', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    grid.setUnchecked(Pos(1, 0), 'x');
    check(grid.rows).deepEquals([
      ['a', 'x'],
      ['c', 'd'],
    ]);
  });

  test('set should set the element at the position', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    grid.set(Pos(1, 0), 'x');
    check(grid.rows).deepEquals([
      ['a', 'x'],
      ['c', 'd'],
    ]);
  });

  test('set should throw when the position is out of bounds', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(() => grid.set(Pos(2, 0), 'x')).throws<RangeError>();
  });

  test('rows should return the rows of the grid', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.rows).deepEquals([
      ['a', 'b'],
      ['c', 'd'],
    ]);
  });

  test('columns should return the columns of the grid', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.columns).deepEquals([
      ['a', 'c'],
      ['b', 'd'],
    ]);
  });

  test('toRect should return the bounding box of the grid', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.toRect()).equals(Rect.fromLTWH(0, 0, 2, 2));
  });

  test('toRect should return the bounding box with an offset', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.toRect(topLeft: Pos(2, 3))).equals(Rect.fromLTWH(2, 3, 2, 2));
  });

  test('toString()', () {
    final grid = fromRows([
      ['a', 'b'],
      ['c', 'd'],
    ]);
    check(grid.toString()).equals(
      '┌─────┐\n'
      '│ a b │\n'
      '│ c d │\n'
      '└─────┘',
    );
  });
}

final class NaiveListGrid<T> with Grid<T> {
  factory NaiveListGrid.fromRows(Iterable<Iterable<T>> rows) {
    if (rows.isEmpty) {
      return NaiveListGrid(const []);
    }
    final rowsList = rows.map((r) => List.of(r, growable: false));
    final width = rowsList.first.length;
    if (rowsList.any((row) => row.length != width)) {
      throw ArgumentError('Rows must have equal length.');
    }
    return NaiveListGrid(List.of(rowsList, growable: false));
  }

  NaiveListGrid(this._elements);
  final List<List<T>> _elements;

  @override
  int get width => _elements.isEmpty ? 0 : _elements.first.length;

  @override
  int get height => _elements.length;

  @override
  T getUnchecked(Pos pos) {
    return _elements[pos.y][pos.x];
  }

  @override
  void setUnchecked(Pos pos, T element) {
    _elements[pos.y][pos.x] = element;
  }
}

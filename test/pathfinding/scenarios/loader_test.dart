import '../../prelude.dart';

import 'loader.dart';

void main() {
  test('should parse a valid map', () {
    final map = loadMap('''
type octile
height 5
width 5
map
@@@@@
@...@
@.@@@
@....
@@@..
''');
    check(map).height.equals(5);
    check(map).width.equals(5);

    check(map.rows.map((row) => row.map((tile) => tile.toString()).join()))
        .deepEquals([
      '@@@@@',
      '@...@',
      '@.@@@',
      '@....',
      '@@@..',
    ]);
  });

  test('should fail an invalid map, too few lines', () {
    check(
      () => loadMap('''
type octile
height 512
width 512
'''),
    ).throws<FormatException>();
  });

  test('should fail an invalid map, invalid type', () {
    check(
      () => loadMap('''
type unknown
height 512
width 512
map
'''),
    ).throws<FormatException>();
  });

  test('should fail an invalid map, invalid width', () {
    check(
      () => loadMap('''
type octile
height 512
width -12
map
'''),
    ).throws<FormatException>();
  });

  test('should fail an invalid map, invalid height', () {
    check(
      () => loadMap('''
type octile
height a
width 512
map
'''),
    ).throws<FormatException>();
  });
}

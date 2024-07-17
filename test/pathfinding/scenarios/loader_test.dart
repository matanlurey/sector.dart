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

  test('should load a valid scenario', () {
    final scenarios = loadScenarios('''
version 1
0	BigGameHunters.map	512	512	448	497	449	496	1.41421356
''');
    check(scenarios).first
      ..has((s) => s.bucket, 'bucket').equals(0)
      ..has((s) => s.map, 'map').equals('BigGameHunters.map')
      ..has((s) => s.width, 'width').equals(512)
      ..has((s) => s.height, 'height').equals(512)
      ..has((s) => s.start, 'start').equals(Pos(448, 497))
      ..has((s) => s.goal, 'goal').equals(Pos(449, 496))
      ..has((s) => s.optimalLength, 'optimalLength').equals(1.41421356);
  });

  test('should fail an invalid scenario, too few fields', () {
    check(
      () => loadScenarios('''
version 1
0	BigGameHunters.map	512	512	448	497	449	496
'''),
    ).throws<FormatException>();
  });

  test('should fail an invalid scenario, invalid version', () {
    check(
      () => loadScenarios('''
version 2
0	BigGameHunters.map	512	512	448	497	449	496	1.41421356
'''),
    ).throws<FormatException>();
  });
}

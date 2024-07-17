@TestOn('vm')
@Tags(['e2e'])
library;

import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import '../../prelude.dart';

import 'loader.dart';

void main() {
  late final List<io.File> scenarios;

  try {
    final dir = io.Directory(p.join('test', 'pathfinding', 'scenarios'));
    scenarios = dir
        .listSync()
        .whereType<io.File>()
        .where((file) => file.path.endsWith('.map.scen'))
        .toList();
  } on io.FileSystemException catch (e) {
    fail('Failed to list scenarios: $e');
  }

  setUpAll(() {
    check(scenarios, because: 'Sanity check we are loading a map').isNotEmpty();
  });

  for (final scenario in scenarios) {
    group('should parse and run scenario: ${p.basename(scenario.path)}', () {
      _runTest(scenario);
    });
  }
}

void _runTest(io.File scenarioFile) {
  // Load scenario.
  final content = scenarioFile.readAsStringSync();
  final scenarios = loadScenarios(content);
  final map = loadMap(
    io.File(
      p.join(
        'test',
        'pathfinding',
        'scenarios',
        scenarios.first.map,
      ),
    ).readAsStringSync(),
  );
  final graph = mapAsGraph(map);

  for (final scenario in scenarios) {
    test('should run scenario: $scenario', () {
      final (path, _) = astar.findBestPath(
        graph,
        scenario.start,
        Goal.node(scenario.goal),
        GridHeuristic.chebyshev(scenario.goal),
      );

      check(path).nodesBetween(scenario.start, scenario.goal);
    });
  }
}

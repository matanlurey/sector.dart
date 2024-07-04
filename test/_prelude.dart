import 'package:checks/checks.dart';
import 'package:sector/sector.dart';

export 'package:checks/checks.dart';
export 'package:sector/sector.dart';
export 'package:test/test.dart' show group, test;

/// Convenience methods for testing [Grid] implementations.
extension GridSubject<T> on Subject<Grid<T>> {
  Subject<int> get width => has((it) => it.width, 'width');

  Subject<int> get height => has((it) => it.height, 'height');

  Subject<bool> get isEmpty => has((it) => it.isEmpty, 'isEmpty');

  Subject<GridAxis<T>> get rows => has((it) => it.rows, 'rows');

  Subject<GridAxis<T>> get columns => has((it) => it.columns, 'columns');

  Subject<bool> get isEmptyRows => rows.has((it) => it.isEmpty, 'isEmpty');
}

/// Internal-only shared code across the package.
///
/// This code is intentionally not exported as part of the public API, and is
/// not intended to be used outside of the package, i.e. it and and will change
/// unpredictably without respecting semantic versioning.
///
/// If you could use this code, [file an issue][issue] or [create a PR][pr].
///
/// [issue]: https://github.com/matanlurey/sector/issues/new
/// [pr]: https://github.com/matanlurey/sector/fork
@internal
library;

import 'dart:collection';
import 'dart:math' as math;

import 'package:lodim/lodim.dart';
import 'package:meta/meta.dart';

part 'internal/iterables.dart';

/// Returns the index of a 1-dimensional list that corresponds to a 2D [Pos].
@pragma('vm:prefer-inline')
int rowMajor1D(Pos pos, {required int width}) => pos.y * width + pos.x;

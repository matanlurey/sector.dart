import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

/// An immutable class that represents a position or offset in a 2D space.
///
/// ## Equality
///
/// Two positions are considered equal if their `x` and `y` values are equal:
///
/// ```dart
/// final a = Pos(1, 2);
/// final b = Pos(1, 2);
/// print(a == b); // true
/// ```
///
/// ## Why `Pos` and not `(int, int)`?
///
/// Earlier versions of this library used `(int, int)` to represent positions.
///
/// However this approach had a few drawbacks:
///
/// - It was not self-documenting; what is a (`int, int, T`) tuple?
/// - Common methods were needed, and extension methods apply too broadly.
@immutable
final class Pos {
  /// Orders positions by their euclidean distance from the origin.
  ///
  /// See [distance] for the formula used to calculate the distance.
  static const Comparator<Pos> byDistance = _byDistance;
  static int _byDistance(Pos a, Pos b) {
    return a.distanceSquared().compareTo(b.distanceSquared());
  }

  /// Orders positions by their manhattan distance from the origin.
  ///
  /// See [distanceManhattan] for the formula used to calculate the distance.
  static const Comparator<Pos> byDistanceManhattan = _byDistanceManhattan;
  static int _byDistanceManhattan(Pos a, Pos b) {
    return a.distanceManhattan().compareTo(b.distanceManhattan());
  }

  /// Orders positions by their chebyshev distance from the origin.
  ///
  /// See [distanceChebyshev] for the formula used to calculate the distance.
  static const Comparator<Pos> byDistanceChebyshev = _byDistanceChebyshev;
  static int _byDistanceChebyshev(Pos a, Pos b) {
    return a.distanceChebyshev().compareTo(b.distanceChebyshev());
  }

  /// Orders positions in row-major order.
  ///
  /// Given two positions `a` and `b`, it returns:
  /// - `-1` if `a` comes before `b` in row-major order.
  /// - `0` if `a` and `b` are equal.
  /// - `1` if `a` comes after `b` in row-major order.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final positions = [Pos(1, 2), Pos(2, 1), Pos(1, 1)];
  /// positions.sort(Pos.rowMajor);
  /// print(positions); // [Pos(1, 1), Pos(1, 2), Pos(2, 1)]
  /// ```
  static const Comparator<Pos> byRowMajor = _byRowMajor;
  static int _byRowMajor(Pos a, Pos b) => a.y == b.y ? a.x - b.x : a.y - b.y;

  /// The zero-th or default position for most 2D spaces, `(0, 0)`.
  static const zero = Pos(0, 0);

  /// Creates a new position with the given `x` and `y` values.
  ///
  /// It is valid to have _any_ integer value for `x` and `y`; for example a
  /// negative value could represent an offset from the bottom or right edge,
  /// or a direction to move in.
  const Pos(this.x, this.y);

  /// Creates a new position by flooring the `x` and `y` values of a tuple.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final tuple = (1.5, 2.5);
  /// final pos = Pos.floor(tuple);
  /// print(pos); // Pos(1, 2)
  /// ```
  Pos.floor(double x, double y) : this(x.floor(), y.floor());

  /// Creates a new position by rounding the `x` and `y` values of a tuple.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final tuple = (1.5, 2.5);
  /// final pos = Pos.round(tuple);
  /// print(pos); // Pos(2, 3)
  /// ```
  Pos.round(double x, double y) : this(x.round(), y.round());

  /// Creates a new position by ceiling the `x` and `y` values of a tuple.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final tuple = (1.5, 2.5);
  /// final pos = Pos.ceil(tuple);
  /// print(pos); // Pos(2, 3)
  /// ```
  Pos.ceil(double x, double y) : this(x.ceil(), y.ceil());

  /// Creates a new position from [degrees] and [distance] from [zero].
  ///
  /// [degrees] represents a direction (angle) in degrees, and [distance] is
  /// the magnitude from the origin. The resulting position is the point on the
  /// unit circle at the given angle, scaled by the distance, rounded to the
  /// nearest integer.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos.fromDegrees(45, 1);
  /// print(pos); // Pos(1, 1)
  /// ```
  @pragma('vm:prefer-inline')
  factory Pos.fromDegrees(int degrees, [int distance = 1]) {
    return Pos.fromRadians(math.pi * degrees / 180, distance);
  }

  /// Creates a new position from [radians] and [distance] from [zero].
  ///
  /// [radians] represents a direction (angle) in radians, and [distance] is
  /// the magnitude from the origin. The resulting position is the point on the
  /// unit circle at the given angle, scaled by the distance, rounded to the
  /// nearest integer.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos.fromRadians(math.pi / 4, 1);
  /// print(pos); // Pos(1, 1)
  /// ```
  factory Pos.fromRadians(double radians, [int distance = 1]) {
    final x = (distance * math.cos(radians)).round();
    final y = (distance * math.sin(radians)).round();
    return Pos(x, y);
  }

  /// The x-coordinate of this position, or the horizontal offset.
  final int x;

  /// The y-coordinate of this position, or the vertical offset.
  final int y;

  /// Returns a tuple `(x, y)` of this position.
  ///
  /// This is useful for destructuring assignments, for example:
  ///
  /// ```dart
  /// final pos = Pos(1, 2);
  ///
  /// // Using Pos directly.
  /// final Pos(:x, :y) = pos;
  ///
  /// // Using tuple destructuring.
  /// final (x, y) = pos.xy;
  /// ```
  (int, int) get xy => (x, y);

  /// Adds the `other` position to this position.
  ///
  /// This is equivalent to `Pos(x + other.x, y + other.y)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a + b); // Pos(4, 6)
  /// ```
  Pos operator +(Pos other) => Pos(x + other.x, y + other.y);

  /// Subtracts the `other` position from this position.
  ///
  /// This is equivalent to `Pos(x - other.x, y - other.y)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a - b); // Pos(-2, -2)
  /// ```
  Pos operator -(Pos other) => Pos(x - other.x, y - other.y);

  /// Multiplies this position by the `other` scalar.
  ///
  /// This is equivalent to `Pos(x * other, y * other)`.
  ///
  /// See [scaleBy] to scale each component independently.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// print(a * 3); // Pos(3, 6)
  /// ```
  Pos operator *(int other) => Pos(x * other, y * other);

  /// Scales this position by the `x` and `y` values independently.
  ///
  /// This is equivalent to `Pos(x1 * x2, y1 * y2)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a.scale(b)); // Pos(3, 8)
  /// ```
  Pos scaleBy(Pos other) => Pos(x * other.x, y * other.y);

  /// Divides (with floor) this position by the `other` scalar.
  ///
  /// This is equivalent to `Pos(x ~/ other, y ~/ other)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(3, 6);
  /// print(a ~/ 3); // Pos(1, 2)
  /// ```
  Pos operator ~/(int other) => Pos(x ~/ other, y ~/ other);

  /// Divides this position by the `other` scalar.
  ///
  /// The result cannot be safely represented as an integer, so it is returned
  /// as a tuple of floating point numbers. Consider [operator ~/] for integer
  /// safe division.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(3, 6);
  /// print(a / 1.5); // (2.0, 4.0)
  /// ```
  (double, double) operator /(num other) => (x / other, y / other);

  /// Negates this position.
  ///
  /// This is equivalent to `Pos(-x, -y)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 2);
  /// print(-pos); // Pos(-1, -2)
  /// ```
  Pos operator -() => Pos(-x, -y);

  /// Returns this position with the `x` and `y` values flipped.
  ///
  /// This is equivalent to `Pos(pos.y, pos.x)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 2);
  /// print(pos.flipped); // Pos(2, 1)
  /// ```
  Pos flip() => Pos(y, x);

  /// Returns the absolute value of this position from the origin.
  ///
  /// This is equivalent to `Pos(x.abs(), y.abs())`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(-1, 2);
  /// print(pos.abs()); // Pos(1, 2)
  /// ```
  Pos abs() => Pos(x.abs(), y.abs());

  /// Returns the euclidean distance between this position and [other].
  ///
  /// By default, the distance is calculated from the origin.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(3, 4);
  /// print(pos.distance()); // 5.0
  ///
  /// final other = Pos(6, 8);
  /// print(pos.distance(other)); // 5.0
  /// ```
  ///
  /// ## Formula
  ///
  /// `√((x₂ - x₁)² + (y₂ - y₁)²)`.
  @pragma('vm:prefer-inline')
  double distance([Pos other = Pos.zero]) => math.sqrt(distanceSquared(other));

  /// Returns the squared euclidean distance between this position and [other].
  ///
  /// By default, the distance is calculated from the origin.
  ///
  /// This method is useful when _comparing_ distances, as it avoids the square
  /// root operation. For example, see it's use in the [byDistance] comparator.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(3, 4);
  /// print(pos.distanceSquared()); // 25.0
  ///
  /// final other = Pos(6, 8);
  /// print(pos.distanceSquared(other)); // 25.0
  /// ```
  ///
  /// ## Formula
  ///
  /// `(x₂ - x₁)² + (y₂ - y₁)²`.
  int distanceSquared([Pos other = Pos.zero]) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }

  /// Returns the manhattan distance between this position and [other].
  ///
  /// By default, the distance is calculated from the origin.
  ///
  /// Manhattan distance is the sum of the absolute differences between the `x`
  /// and `y` values, and is useful for calculating distances in a grid where
  /// only [Ordinal] (horizontal and vertical) moves are allowed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(3, 4);
  /// print(pos.distanceManhattan()); // 7
  ///
  /// final other = Pos(6, 8);
  /// print(pos.distanceManhattan(other)); // 7
  /// ```
  ///
  /// ## Formula
  ///
  /// `|x₂ - x₁| + |y₂ - y₁|`.
  @pragma('vm:prefer-inline')
  int distanceManhattan([Pos other = Pos.zero]) {
    return (x - other.x).abs() + (y - other.y).abs();
  }

  /// Returns the chebyshev distance between this position and [other].
  ///
  /// By default, the distance is calculated from the origin.
  ///
  /// Chebyshev distance is the maximum of the absolute differences between the
  /// `x` and `y` values, and is useful for calculating distances in a grid
  /// where both [Cardinal] (diagonal) and [Ordinal] (horizontal and vertical)
  /// moves are allowed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(3, 4);
  /// print(pos.distanceChebyshev()); // 4
  ///
  /// final other = Pos(6, 8);
  /// print(pos.distanceChebyshev(other)); // 4
  /// ```
  ///
  /// ## Formula
  ///
  /// `max(|x₂ - x₁|, |y₂ - y₁|)`.
  @pragma('vm:prefer-inline')
  int distanceChebyshev([Pos other = Pos.zero]) {
    return math.max((x - other.x).abs(), (y - other.y).abs());
  }

  /// Linearly interpolates between this position and [other] by [ratio].
  ///
  /// The [ratio] is a value between `0.0` and `1.0`, where `0.0` returns this
  /// position, `1.0` returns [other], and `0.5` returns the midpoint. If a
  /// value outside this range is provided, the result is extrapolated.
  ///
  /// Returns a tuple `(x, y)` of the interpolated position.
  ///
  /// To return a [Pos], use [lerpFloor], [lerpRound], or [lerpCeil].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a.lerp(b, 0.5)); // (2.0, 3.0)
  /// ```
  (double x, double y) lerp(Pos other, double ratio) {
    final dx = other.x - x;
    final dy = other.y - y;
    return (x + dx * ratio, y + dy * ratio);
  }

  /// Linearly interpolates between this position and [other] by [ratio].
  ///
  /// The [ratio] is a value between `0.0` and `1.0`, where `0.0` returns this
  /// position, `1.0` returns [other], and `0.5` returns the midpoint. If a
  /// value outside this range is provided, the result is extrapolated.
  ///
  /// Returns the interpolated position, with the `x` and `y` values floored.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a.lerpFloor(b, 0.5)); // Pos(2, 3)
  /// ```
  Pos lerpFloor(Pos other, double ratio) {
    final (x, y) = lerp(other, ratio);
    return Pos.floor(x, y);
  }

  /// Linearly interpolates between this position and [other] by [ratio].
  ///
  /// The [ratio] is a value between `0.0` and `1.0`, where `0.0` returns this
  /// position, `1.0` returns [other], and `0.5` returns the midpoint. If a
  /// value outside this range is provided, the result is extrapolated.
  ///
  /// Returns the interpolated position, with the `x` and `y` values rounded.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a.lerpRound(b, 0.5)); // Pos(2, 3)
  /// ```
  Pos lerpRound(Pos other, double ratio) {
    final (x, y) = lerp(other, ratio);
    return Pos.round(x, y);
  }

  /// Linearly interpolates between this position and [other] by [ratio].
  ///
  /// The [ratio] is a value between `0.0` and `1.0`, where `0.0` returns this
  /// position, `1.0` returns [other], and `0.5` returns the midpoint. If a
  /// value outside this range is provided, the result is extrapolated.
  ///
  /// Returns the interpolated position, with the `x` and `y` values ceiled.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final a = Pos(1, 2);
  /// final b = Pos(3, 4);
  /// print(a.lerpCeil(b, 0.5)); // Pos(2, 3)
  /// ```
  Pos lerpCeil(Pos other, double ratio) {
    final (x, y) = lerp(other, ratio);
    return Pos.ceil(x, y);
  }

  /// Returns a position in range `[min, max]` for both `x` and `y`.
  ///
  /// If [min] is not provided, it defaults to [zero].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(3, 2);
  /// print(pos.clamped(Pos(1, 1), max: Pos(2, 3))); // Pos(2, 2)
  /// print(pos.clamped(Pos(-1, -1))); // Pos(0, 0)
  /// ```
  Pos clamp(Pos max, {Pos min = Pos.zero}) {
    final x = this.x.clamp(min.x, max.x);
    final y = this.y.clamp(min.y, max.y);
    return Pos(x, y);
  }

  /// Returns this position rotated by 180 degrees.
  ///
  /// This operation is always the same as negating ([-operator]) the position.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 2);
  /// print(pos.rotate180()); // Pos(-1, -2)
  /// ```
  Pos rotate180() => -this;

  /// Returns this position rotated by 90 degrees [steps] times clockwise.
  ///
  /// By default, it rotates the position by 90 degrees once.
  ///
  /// Provide a negative [steps] to rotate in the counter-clockwise direction.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 0);
  /// print(pos.rotate90()); // Pos(0, 1)
  /// print(pos.rotate90(2)); // Pos(-1, 0)
  /// print(pos.rotate90(-1)); // Pos(0, -1)
  /// ```
  Pos rotate90([int steps = 1]) {
    final x = this.x;
    final y = this.y;
    switch (steps % 4) {
      case 0:
        return this;
      case 1:
        return Pos(-y, x);
      case 2:
        return Pos(-x, -y);
      default:
        assert(steps % 4 == 3, 'This should never happen');
        return Pos(y, -x);
    }
  }

  /// Returns this position rotated by 45 degrees [steps] times clockwise.
  ///
  /// By default, it rotates the position by 45 degrees once.
  ///
  /// Provide a negative [steps] to rotate in the counter-clockwise direction.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 0);
  /// print(pos.rotate45()); // Pos(1, 1)
  /// print(pos.rotate45(2)); // Pos(0, 1)
  /// print(pos.rotate45(-1)); // Pos(1, -1)
  /// ```
  Pos rotate45([int steps = 1]) {
    final x = this.x;
    final y = this.y;
    switch (steps % 8) {
      case 0:
        return this;
      case 1:
        return Pos(x - y, x + y);
      case 2:
        return Pos(-y, x);
      case 3:
        return Pos(-x - y, x - y);
      case 4:
        return Pos(-x, -y);
      case 5:
        return Pos(-x + y, -x - y);
      case 6:
        return Pos(y, -x);
      default:
        assert(steps % 8 == 7, 'This should never happen');
        return Pos(x + y, -x);
    }
  }

  /// Returns this position moved in the given [direction], optionally [times].
  ///
  /// If [times] is not provided, it defaults to `1`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 2);
  /// print(pos.move(Direction.north)); // Pos(1, 1)
  /// print(pos.move(Direction.east, 2)); // Pos(3, 2)
  /// ```
  Pos move(Direction direction, [int times = 1]) {
    return this + direction.offset * times;
  }

  /// Returns whether this position is in bounds of the given region.
  ///
  /// By default, the region is the entire 2D space, where `left` and `top` are
  /// `0`, and `width` and `height` are the maximum values. If the region is
  /// smaller, provide the `left` and `top` values.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final pos = Pos(1, 2);
  /// print(pos.isInBounds(3, 3)); // true
  /// print(pos.isInBounds(1, 1)); // false
  /// print(pos.isInBounds(3, 3, left: 1, top: 1)); // true
  /// ```
  bool isInBounds(int width, int height, {int left = 0, int top = 0}) {
    return x >= left && x < left + width && y >= top && y < top + height;
  }

  /// Returns an iterable of positions from this position to [other].
  ///
  /// "Draws" a line from this position to [other], including both positions,
  /// unless [exclusive] is `true`, in which case [other] is excluded.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final start = Pos(0, 0);
  /// final end = Pos(2, 2);
  /// for (final pos in start.lineTo(end)) {
  ///   print(pos);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// Pos(0, 0)
  /// Pos(1, 1)
  /// Pos(2, 2)
  /// ```
  Iterable<Pos> lineTo(Pos other, {bool exclusive = false}) {
    var start = this;
    var end = other;

    final octant = Octant.between(start, end);
    start = octant.toOctant1(start);
    end = octant.toOctant1(end);

    final delta = end - start;
    final diff = delta.y - delta.x;
    final endX = exclusive ? end.x : end.x + 1;

    return _LineIterable(octant, delta, start, diff, endX);
  }

  @override
  bool operator ==(Object other) {
    return other is Pos && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Pos($x, $y)';
}

final class _LineIterable extends Iterable<Pos> {
  _LineIterable(
    this._octant,
    this._delta,
    this._start,
    this._diff,
    this._endX,
  );

  final Octant _octant;
  final Pos _delta;
  final Pos _start;
  final int _diff;
  final int _endX;

  @override
  Iterator<Pos> get iterator {
    return _LineIterator(
      _octant,
      _delta,
      _start,
      _diff,
      _endX,
    );
  }
}

final class _LineIterator implements Iterator<Pos> {
  _LineIterator(
    this._octant,
    this._delta,
    this._start,
    this._diff,
    this._endX,
  );

  final Octant _octant;
  final Pos _delta;
  final int _endX;

  Pos _start;
  int _diff;

  @override
  late Pos current;

  @override
  bool moveNext() {
    var Pos(:x, :y) = _start;
    if (x >= _endX) {
      return false;
    }

    current = _octant.fromOctant1(_start);
    if (_diff >= 0) {
      y += 1;
      _diff -= _delta.x;
    }

    x += 1;
    _diff += _delta.y;
    _start = Pos(x, y);
    return true;
  }
}

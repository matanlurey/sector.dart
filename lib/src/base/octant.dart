import 'package:sector/sector.dart';

/// An arc of a circle equal to one-eigh of its circumference.
///
/// The octants are arranged as follows, with the origin `(0, 0)` at the center
/// of the diagram, where the x-axis and y-axis intersect; each quadrant is
/// further divided into two octants, resulting in a total of eight setions, and
/// numbered counter-clockwise from the top-right corner (`I`):
///
/// ```txt
///       ^ y-axis
///  \  3 | 2  /
///    \  |  /
///   4  \|/  1
/// -------------+ x-axis
///   5  /|\  8
///    /  |  \
///  /  6 | 7  \
/// ```
///
/// See also <https://en.wikipedia.org/wiki/Circular_sector>.
///
/// ## Usage
///
/// This class is provided as a utility for converting points between octants,
/// which is useful when traversing a grid or drawing lines. For example, when
/// drawing a line from `(0, 0)` to `(2, 2)`, the line will pass through the
/// first octant, and the points `(1, 1)` and `(2, 2)` will be visited. When
/// drawing a line from `(0, 0)` to `(2, 2)` in the second octant, the points
/// `(1, 1)` and `(2, 2)` will be visited, but the order of the points will be
/// reversed.
///
/// See [GridTraversal.line] for an example of using octants to draw lines.
///
/// ## Examples
///
/// ```dart
/// final octant = Octant.fromPoints(0, 0, 2, 2);
/// print(octant); // Octant.first
///
/// final point = octant.toOctant1(2, 2);
/// print(point); // (2, 2)
/// ```
enum Octant {
  /// The first octant, where `x > 0, y > 0`.
  ///
  /// The angle is between `0` and `π/4`.
  first,

  /// The second octant, where `x < 0, y > 0`.
  ///
  /// The angle is between `π/4` and `π/2`.
  second,

  /// The third octant, where `x < 0, y < 0`.
  ///
  /// The angle is between `π/2` and `3π/4`.
  third,

  /// The fourth octant, where `x > 0, y < 0`.
  ///
  /// The angle is between `3π/4` and `π`.
  fourth,

  /// The fifth octant, where `x > 0, y > 0` (the same as [first]).
  ///
  /// The angle is between `π` and `5π/4`.
  fifth,

  /// The sixth octant, where `x < 0, y > 0` (the same as [second]).
  ///
  /// The angle is between `5π/4` and `3π/2`.
  sixth,

  /// The seventh octant, where `x < 0, y < 0` (the same as [third]).
  ///
  /// The angle is between `3π/2` and `7π/4`.
  seventh,

  /// The eighth octant, where `x > 0, y < 0` (the same as [fourth]).
  ///
  /// The angle is between `7π/4` and `2π`.
  eighth;

  /// Creates an octant from the provided start and end positions.
  ///
  /// The octant is determined by the angle between the two points, where the
  /// angle is measured from the positive x-axis in the counter-clockwise
  /// direction.
  factory Octant.between(Pos a, Pos b) {
    var delta = b - a;
    var octant = 0;

    // Rotate by 180 degeres.
    if (delta.y < 0) {
      delta = delta.rotate180();
      octant += 4;
    }

    // Rotate clockwise by 90 degrees.
    if (delta.x < 0) {
      delta = delta.rotate90();
      octant += 2;
    }

    // No need to rotate.
    if (delta.x < delta.y) {
      octant += 1;
    }

    return Octant.values[octant];
  }

  /// Converts the provided [position] to the octant's equivalent.
  ///
  /// Given a point `(x, y)` in the first octant, this method will return the
  /// equivalent point in the octant. For example, the point `(2, 3)` in the
  /// first octant is `(3, 2)` in the second octant.
  ///
  /// This method is the inverse of [toOctant1].
  Pos toOctant1(Pos position) {
    final Pos(:x, :y) = position;
    return switch (this) {
      Octant.first => Pos(x, y),
      Octant.second => Pos(y, x),
      Octant.third => Pos(y, -x),
      Octant.fourth => Pos(-x, y),
      Octant.fifth => Pos(-x, -y),
      Octant.sixth => Pos(-y, -x),
      Octant.seventh => Pos(-y, x),
      Octant.eighth => Pos(x, -y),
    };
  }

  /// Converts the provided [position] from the octant's equivalent.
  ///
  /// Given a point `(x, y)` in the octant, this method will return the
  /// equivalent point in the first octant. For example, the point `(3, 2)` in
  /// the second octant is `(2, 3)` in the first octant.
  ///
  /// This method is the inverse of [toOctant1].
  Pos fromOctant1(Pos position) {
    final Pos(:x, :y) = position;
    return switch (this) {
      Octant.first => Pos(x, y),
      Octant.second => Pos(y, x),
      Octant.third => Pos(-y, x),
      Octant.fourth => Pos(-x, y),
      Octant.fifth => Pos(-x, -y),
      Octant.sixth => Pos(-y, -x),
      Octant.seventh => Pos(y, -x),
      Octant.eighth => Pos(x, -y),
    };
  }
}

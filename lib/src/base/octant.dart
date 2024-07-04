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
  ///
  /// > [!TIP]
  /// > Prefer [Pos.octant] when working with [Pos] objects.
  factory Octant.fromXYXY(int x1, int y1, int x2, int y2) {
    var dx = x2 - x1;
    var dy = y2 - y1;
    var octant = 0;

    // Rotate by 180 degeres.
    if (dy < 0) {
      (dx, dy) = (-dx, -dy);
      octant += 4;
    }

    // Rotate clockwise by 90 degrees.
    if (dx < 0) {
      (dx, dy) = (-dy, dx);
      octant += 2;
    }

    // No need to rotate.
    if (dx < dy) {
      octant += 1;
    }

    return Octant.values[octant];
  }

  /// Converts the provided position to the octant's equivalent.
  ///
  /// Given a point `(x, y)` in the first octant, this method will return the
  /// equivalent point in the octant. For example, the point `(2, 3)` in the
  /// first octant is `(3, 2)` in the second octant.
  ///
  /// This method is the inverse of [toOctant1].
  (int x, int y) toOctant1(int x, int y) {
    return switch (this) {
      Octant.first => (x, y),
      Octant.second => (y, x),
      Octant.third => (y, -x),
      Octant.fourth => (-x, y),
      Octant.fifth => (-x, -y),
      Octant.sixth => (-y, -x),
      Octant.seventh => (-y, x),
      Octant.eighth => (x, -y),
    };
  }

  /// Converts the provided position from the octant's equivalent.
  ///
  /// Given a point `(x, y)` in the octant, this method will return the
  /// equivalent point in the first octant. For example, the point `(3, 2)` in
  /// the second octant is `(2, 3)` in the first octant.
  ///
  /// This method is the inverse of [toOctant1].
  (int x, int y) fromOctant1(int x, int y) {
    return switch (this) {
      Octant.first => (x, y),
      Octant.second => (y, x),
      Octant.third => (-y, x),
      Octant.fourth => (-x, y),
      Octant.fifth => (-x, -y),
      Octant.sixth => (-y, -x),
      Octant.seventh => (y, -x),
      Octant.eighth => (x, -y),
    };
  }
}
import 'package:meta/meta.dart';
import 'package:sector/sector.dart';

/// An immutable class that represents a 2D rectangle with integer coordinates.
///
/// > [!NOTE]
/// > It is valid to have _any_ integer value for any of the edges.
/// >
/// > It is up to its consumers to ensure that the rectangle is valid for their
/// > use case. For example, [right] can be less than [left], or [bottom] can be
/// > negative.
///
/// ## Equality
///
/// Two rectangles are considered equal if they have the same:
/// - [left]
/// - [top]
/// - [right]
/// - [bottom]
///
/// ## Example
///
/// ```dart
/// final rect = Rect.fromLTRB(10, 20, 30, 40);
/// print(rect.bottomRight); // Pos(30, 40)
/// print(rect.width); // 20
/// ```
@immutable
final class Rect {
  /// A rectangle with all edges at 0.
  static const zero = Rect.fromLTRB(0, 0, 0, 0);

  /// Creates a rectangle from its left, top, right, and bottom edges.
  const Rect.fromLTRB(
    this.left,
    this.top,
    this.right,
    this.bottom,
  );

  /// Creates a rectangle from its left and top edges, and its width and height.
  const Rect.fromLTWH(
    int left,
    int top,
    int width,
    int height,
  ) : this.fromLTRB(left, top, left + width, top + height);

  /// The left, or x-coordinate of the left edge.
  final int left;

  /// The top, or y-coordinate of the top edge.
  final int top;

  /// The right, or x-coordinate of the right edge.
  final int right;

  /// The bottom, or y-coordinate of the bottom edge.
  final int bottom;

  /// The top-left corner of the rectangle.
  Pos get topLeft => Pos(left, top);

  /// The top-right corner of the rectangle.
  Pos get topRight => Pos(right, top);

  /// The bottom-left corner of the rectangle.
  Pos get bottomLeft => Pos(left, bottom);

  /// The bottom-right corner of the rectangle.
  Pos get bottomRight => Pos(right, bottom);

  /// The width of the rectangle.
  int get width => right - left;

  /// The height of the rectangle.
  int get height => bottom - top;

  /// Returns whether the rectangle is empty.
  ///
  /// A rectangle is considered empty if its width or height is <= 0.
  bool get isEmpty => width <= 0 || height <= 0;

  /// Returns whether the rectangle is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Returns whether the provided [position] is within the rectangle.
  ///
  /// Rectangles exclude their [right] and [bottom] edges.
  bool contains(Pos position) {
    final Pos(:x, :y) = position;
    return x >= left && x < right && y >= top && y < bottom;
  }

  @override
  bool operator ==(Object other) {
    return other is Rect &&
        left == other.left &&
        top == other.top &&
        right == other.right &&
        bottom == other.bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'Rect.fromLTRB($left, $top, $right, $bottom)';
}

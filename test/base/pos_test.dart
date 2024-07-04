import 'dart:math' as math;

import '../_prelude.dart';

void main() {
  test('should order by euclidean distance from the origin', () {
    final positions = [
      Pos(1, 1),
      Pos(2, 2),
      Pos(0, 0),
      Pos(3, 3),
      Pos(1, 0),
      Pos(0, 1),
      Pos(2, 0),
      Pos(0, 2),
      Pos(3, 0),
      Pos(0, 3),
    ]..sort(Pos.byDistance);

    check(positions).deepEquals([
      Pos(0, 0),
      Pos(1, 0),
      Pos(0, 1),
      Pos(1, 1),
      Pos(2, 0),
      Pos(0, 2),
      Pos(2, 2),
      Pos(3, 0),
      Pos(0, 3),
      Pos(3, 3),
    ]);
  });

  test('should order by manhattan distance from the origin', () {
    final positions = [
      Pos(1, 1),
      Pos(2, 2),
      Pos(0, 0),
      Pos(3, 3),
      Pos(1, 0),
      Pos(0, 1),
      Pos(2, 0),
      Pos(0, 2),
      Pos(3, 0),
      Pos(0, 3),
    ]..sort(Pos.byDistanceManhattan);

    check(positions).deepEquals([
      Pos(0, 0),
      Pos(1, 0),
      Pos(0, 1),
      Pos(1, 1),
      Pos(2, 0),
      Pos(0, 2),
      Pos(3, 0),
      Pos(0, 3),
      Pos(2, 2),
      Pos(3, 3),
    ]);
  });

  test('should order by chebyshev distance from the origin', () {
    final positions = [
      Pos(1, 1),
      Pos(2, 2),
      Pos(0, 0),
      Pos(3, 3),
      Pos(1, 0),
      Pos(0, 1),
      Pos(2, 0),
      Pos(0, 2),
      Pos(3, 0),
      Pos(0, 3),
    ]..sort(Pos.byDistanceChebyshev);

    check(positions).deepEquals([
      Pos(0, 0),
      Pos(1, 1),
      Pos(1, 0),
      Pos(0, 1),
      Pos(2, 2),
      Pos(2, 0),
      Pos(0, 2),
      Pos(3, 3),
      Pos(3, 0),
      Pos(0, 3),
    ]);
  });

  test('should order by row-major order', () {
    final positions = [
      Pos(1, 1),
      Pos(2, 2),
      Pos(0, 0),
      Pos(3, 3),
      Pos(1, 0),
      Pos(0, 1),
      Pos(2, 0),
      Pos(0, 2),
      Pos(3, 0),
      Pos(0, 3),
    ]..sort(Pos.byRowMajor);

    check(positions).deepEquals([
      Pos(0, 0),
      Pos(1, 0),
      Pos(2, 0),
      Pos(3, 0),
      Pos(0, 1),
      Pos(1, 1),
      Pos(0, 2),
      Pos(2, 2),
      Pos(0, 3),
      Pos(3, 3),
    ]);
  });

  test('should floor two doubles (x, y)', () {
    check(Pos.floor(1.5, 2.5)).equals(Pos(1, 2));
  });

  test('should ceil two doubles (x, y)', () {
    check(Pos.ceil(1.5, 2.5)).equals(Pos(2, 3));
  });

  test('should round two doubles (x, y)', () {
    check(Pos.round(1.5, 2.5)).equals(Pos(2, 3));
  });

  test('should create a position from degrees and distance', () {
    check(Pos.fromDegrees(45)).equals(Pos(1, 1));
  });

  test('should create a position from radians and distance', () {
    check(Pos.fromRadians(math.pi / 4)).equals(Pos(1, 1));
  });

  test('should return a (x, y) tuple', () {
    check(Pos(1, 2).xy).equals((1, 2));
  });

  test('should add two positions', () {
    check(Pos(1, 2) + Pos(3, 4)).equals(Pos(4, 6));
  });

  test('should subtract two positions', () {
    check(Pos(1, 2) - Pos(3, 4)).equals(Pos(-2, -2));
  });

  test('should multiply a position by a scalar', () {
    check(Pos(1, 2) * 3).equals(Pos(3, 6));
  });

  test('should scale a position by another position', () {
    check(Pos(1, 2).scaleBy(Pos(3, 4))).equals(Pos(3, 8));
  });

  test('should divide a position by a scalar', () {
    check(Pos(3, 6) ~/ 3).equals(Pos(1, 2));
  });

  test('should divide a position and return a tuple of doubles', () {
    check(Pos(3, 6) / 3).equals((1.0, 2.0));
  });

  test('should negate a position', () {
    check(-Pos(1, 2)).equals(Pos(-1, -2));
  });

  test('should flip a position', () {
    check(Pos(1, 2).flip()).equals(Pos(2, 1));
  });

  test('should return the absolute position', () {
    check(Pos(-1, -2).abs()).equals(Pos(1, 2));
  });

  test('should return the euclidean distance between two positions', () {
    check(Pos(1, 2).distance(Pos(4, 6))).equals(5.0);
  });

  test('should return the manhattan distance between two positions', () {
    check(Pos(1, 2).distanceManhattan(Pos(4, 6))).equals(7);
  });

  test('should return the chebyshev distance between two positions', () {
    check(Pos(1, 2).distanceChebyshev(Pos(4, 6))).equals(4);
  });

  test('should return the lerped position as an (x, y) double tuple', () {
    check(Pos(1, 2).lerp(Pos(4, 6), 0.5)).equals((2.5, 4.0));
  });

  test('should return the lerped position floored into a position', () {
    check(Pos(1, 2).lerpFloor(Pos(4, 6), 0.5)).equals(Pos(2, 4));
  });

  test('should return the lerped position ceiled into a position', () {
    check(Pos(1, 2).lerpCeil(Pos(4, 6), 0.5)).equals(Pos(3, 4));
  });

  test('should return the lerped position rounded into a position', () {
    check(Pos(1, 2).lerpRound(Pos(4, 6), 0.5)).equals(Pos(3, 4));
  });

  test('should return the octant of a position from the origin', () {
    check(Pos(1, 2).octant()).equals(Octant.sixth);
  });

  test('should clamp a position to a maximum', () {
    check(Pos(1, 2).clamp(Pos(2, 2))).equals(Pos(1, 2));
  });

  test('should clamp a position to a minimum', () {
    check(Pos(0, 4).clamp(Pos(3, 3), min: Pos(1, 1))).equals(Pos(1, 3));
  });

  test('should rotate a position 90 degrees forward == 270 degrees back', () {
    check(Pos(1, 2).rotate90()).equals(Pos(-2, 1));
    check(Pos(1, 2).rotate90(-3)).equals(Pos(-2, 1));
  });

  test('should rotate a position 180 degrees forward == 180 degrees back', () {
    check(Pos(1, 2).rotate90(2)).equals(Pos(-1, -2));
    check(Pos(1, 2).rotate90(-2)).equals(Pos(-1, -2));
  });

  test('should rotate a position 270 degrees forward == 90 degrees back', () {
    check(Pos(1, 2).rotate90(3)).equals(Pos(2, -1));
    check(Pos(1, 2).rotate90(-1)).equals(Pos(2, -1));
  });

  test('should rotate a position 45 degrees forward == 315 degrees back', () {
    check(Pos(1, 2).rotate45()).equals(Pos(-1, 3));
    check(Pos(1, 2).rotate45(-7)).equals(Pos(-1, 3));
  });

  test('should rotate a position 90 degrees forward == 270 degrees back', () {
    check(Pos(1, 2).rotate45(2)).equals(Pos(-2, 1));
    check(Pos(1, 2).rotate45(-6)).equals(Pos(-2, 1));
  });

  test('should rotate a position 135 degrees forward == 225 degrees back', () {
    check(Pos(1, 2).rotate45(3)).equals(Pos(-3, -1));
    check(Pos(1, 2).rotate45(-5)).equals(Pos(-3, -1));
  });

  test('should rotate a position 180 degrees forward == 180 degrees back', () {
    check(Pos(1, 2).rotate45(4)).equals(Pos(-1, -2));
    check(Pos(1, 2).rotate45(-4)).equals(Pos(-1, -2));
  });

  test('should rotate a position 225 degrees forward == 135 degrees back', () {
    check(Pos(1, 2).rotate45(5)).equals(Pos(1, -3));
    check(Pos(1, 2).rotate45(-3)).equals(Pos(1, -3));
  });

  test('should rotate a position 270 degrees forward == 90 degrees back', () {
    check(Pos(1, 2).rotate45(6)).equals(Pos(2, -1));
    check(Pos(1, 2).rotate45(-2)).equals(Pos(2, -1));
  });

  test('should rotate a position 315 degrees forward == 45 degrees back', () {
    check(Pos(1, 2).rotate45(7)).equals(Pos(3, -1));
    check(Pos(1, 2).rotate45(-1)).equals(Pos(3, -1));
  });

  test('should rotate a position 360 degrees forward == 0 degrees back', () {
    check(Pos(1, 2).rotate45(8)).equals(Pos(1, 2));
    check(Pos(1, 2).rotate45(-8)).equals(Pos(1, 2));
  });

  test('should move a position in a direction', () {
    check(Pos(1, 2).move(Direction.north)).equals(Pos(1, 1));
  });

  test('should have a hashCode', () {
    check(Pos(1, 2).hashCode).equals(Pos(1, 2).hashCode);
  });

  test('should have a toString', () {
    check(Pos(1, 2).toString()).equals('Pos(1, 2)');
  });
}

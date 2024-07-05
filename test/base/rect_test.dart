import '../_prelude.dart';

void main() {
  test('Rect.fromLTRB == Rect.fromLTWH', () {
    check(Rect.fromLTRB(0, 0, 10, 10)).equals(Rect.fromLTWH(0, 0, 10, 10));
    check(Rect.fromLTRB(10, 20, 30, 40)).equals(Rect.fromLTWH(10, 20, 20, 20));
  });

  test('topLeft', () {
    check(Rect.fromLTRB(10, 20, 30, 40).topLeft).equals(Pos(10, 20));
  });

  test('topRight', () {
    check(Rect.fromLTRB(10, 20, 30, 40).topRight).equals(Pos(30, 20));
  });

  test('bottomLeft', () {
    check(Rect.fromLTRB(10, 20, 30, 40).bottomLeft).equals(Pos(10, 40));
  });

  test('bottomRight', () {
    check(Rect.fromLTRB(10, 20, 30, 40).bottomRight).equals(Pos(30, 40));
  });

  test('width', () {
    check(Rect.fromLTRB(10, 20, 30, 40).width).equals(20);
  });

  test('height', () {
    check(Rect.fromLTRB(10, 20, 30, 40).height).equals(20);
  });

  test('isEmpty', () {
    check(Rect.zero.isEmpty).isTrue();
    check(Rect.fromLTRB(10, 20, 30, 40).isEmpty).isFalse();
    check(Rect.fromLTRB(10, 20, -10, -20).isEmpty).isTrue();
  });

  test('isNotEmpty', () {
    check(Rect.zero.isNotEmpty).isFalse();
    check(Rect.fromLTRB(10, 20, 30, 40).isNotEmpty).isTrue();
    check(Rect.fromLTRB(10, 20, -10, -20).isNotEmpty).isFalse();
  });

  test('contains', () {
    final rect = Rect.fromLTRB(10, 20, 30, 40);
    check(rect.contains(Pos(10, 20))).isTrue();
    check(rect.contains(Pos(30, 40))).isFalse();
    check(rect.contains(Pos(10, 40))).isFalse();
    check(rect.contains(Pos(30, 20))).isFalse();
    check(rect.contains(Pos(5, 20))).isFalse();
    check(rect.contains(Pos(10, 15))).isFalse();
    check(rect.contains(Pos(35, 40))).isFalse();
    check(rect.contains(Pos(30, 45))).isFalse();
  });

  test('hashCode', () {
    check(Rect.zero.hashCode).equals(Rect.zero.hashCode);
    check(
      Rect.fromLTRB(10, 20, 30, 40).hashCode,
    ).equals(Rect.fromLTRB(10, 20, 30, 40).hashCode);
  });

  test('toString', () {
    check(
      Rect.fromLTRB(10, 20, 30, 40).toString(),
    ).equals('Rect.fromLTRB(10, 20, 30, 40)');
  });
}

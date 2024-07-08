import 'package:sector/src/internal.dart';

import '../prelude.dart';

void main() {
  test('should return the most common element in the list', () {
    final list = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4];
    check(mostCommonElement(list)).equals(4);
  });

  test('should return the first most common element in the list', () {
    final list = [1, 1, 2, 2, 3, 3, 4, 4];
    check(mostCommonElement(list)).equals(1);
  });

  test('should return the first most common element in the list', () {
    final list = [1, 2, 3, 4];
    check(mostCommonElement(list)).equals(1);
  });

  test('should return `null` if valid', () {
    final list = <String?>[];
    check(() => mostCommonElement(list)).returnsNormally().isNull();
  });

  test('should throw if the list is empty', () {
    final list = <int>[];
    check(() => mostCommonElement(list)).throws<StateError>();
  });
}

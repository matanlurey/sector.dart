import 'package:sector/src/internal.dart';

import '../prelude.dart';

void main() {
  test('forEach invokes the action for each element', () {
    final iterable = _ListIterable([1, 2, 3]);
    final elements = <int>[];
    iterable.forEach(elements.add);
    check(elements).deepEquals([1, 2, 3]);
  });

  test('iterator iterates through the elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    final elements = <int>[];
    for (final element in iterable) {
      elements.add(element);
    }
    check(elements).deepEquals([1, 2, 3]);
  });

  test('iterator never yields elements if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    final elements = <int>[];
    for (final element in iterable) {
      elements.add(element);
    }
    check(elements).isEmpty();
  });

  test('isEmpty returns true if the iterable has no elements', () {
    final iterable = _ListIterable([]);
    check(iterable.isEmpty).isTrue();
  });

  test('isEmpty returns false if the iterable has elements', () {
    final iterable = _ListIterable([1]);
    check(iterable.isEmpty).isFalse();
  });

  test('isNotEmpty returns false if the iterable has no elements', () {
    final iterable = _ListIterable([]);
    check(iterable.isNotEmpty).isFalse();
  });

  test('isNotEmpty returns true if the iterable has elements', () {
    final iterable = _ListIterable([1]);
    check(iterable.isNotEmpty).isTrue();
  });

  test('last returns the last element of the iterable', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.last).equals(3);
  });

  test('last throws if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    check(() => iterable.last).throws<StateError>();
  });

  test('single returns the only element of the iterable', () {
    final iterable = _ListIterable([1]);
    check(iterable.single).equals(1);
  });

  test('single throws if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    check(() => iterable.single).throws<StateError>();
  });

  test('single throws if the iterable has more than one element', () {
    final iterable = _ListIterable([1, 2]);
    check(() => iterable.single).throws<StateError>();
  });

  test('first returns the first element of the iterable', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.first).equals(1);
  });

  test('first throws if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    check(() => iterable.first).throws<StateError>();
  });

  test('contains returns true if the element is in the iterable', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.contains(2)).isTrue();
  });

  test('every returns true if all elements satisfy the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.every((element) => element > 0)).isTrue();
  });

  test('every returns false if any element does not satisfy the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.every((element) => element > 1)).isFalse();
  });

  test('any returns true if any element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.any((element) => element > 2)).isTrue();
  });

  test('any returns false if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.any((element) => element > 3)).isFalse();
  });

  test('firstWhere returns the first element that satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.firstWhere((element) => element > 1)).equals(2);
  });

  test('firstWhere returns orElse if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(
      iterable.firstWhere((element) => element > 3, orElse: () => 4),
    ).equals(4);
  });

  test('firstWhere throws if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(
      () => iterable.firstWhere((element) => element > 3),
    ).throws<StateError>();
  });

  test('lastWhere returns the last element that satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.lastWhere((element) => element > 1)).equals(3);
  });

  test('lastWhere returns orElse if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(
      iterable.lastWhere((element) => element > 3, orElse: () => 4),
    ).equals(4);
  });

  test('lastWhere throws if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(
      () => iterable.lastWhere((element) => element > 3),
    ).throws<StateError>();
  });

  test('singleWhere returns the only element that satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.singleWhere((element) => element == 2)).equals(2);
  });

  test('singleWhere returns orElse if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(
      iterable.singleWhere((element) => element > 3, orElse: () => 4),
    ).equals(4);
  });

  test('singleWhere throws if no element satisfies the predicate', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(
      () => iterable.singleWhere((element) => element > 3),
    ).throws<StateError>();
  });

  test(
    'singleWhere throws if more than one element satisfies the predicate',
    () {
      final iterable = _ListIterable([1, 2, 3]);
      check(
        () => iterable.singleWhere((element) => element > 1),
      ).throws<StateError>();
    },
  );

  test('join returns an empty string if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    check(iterable.join()).equals('');
  });

  test('join returns the only element if the iterable has one element', () {
    final iterable = _ListIterable(['a']);
    check(iterable.join(', ')).equals('a');
  });

  test('join returns the elements joined by the separator', () {
    final iterable = _ListIterable(['a', 'b', 'c']);
    check(iterable.join()).equals('abc');
    check(iterable.join(', ')).equals('a, b, c');
  });

  test(
    'reduce throws if the iterable is empty and no initial value is provided',
    () {
      final iterable = _ListIterable<int>([]);
      check(
        () => iterable.reduce((value, element) => value + element),
      ).throws<StateError>();
    },
  );

  test('reduce returns the result of combining all elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.reduce((value, element) => value + element)).equals(6);
  });

  test(
    'reduce throws if the iterable is empty and no initial value is provided',
    () {
      final iterable = _ListIterable<int>([]);
      check(
        () => iterable.reduce((value, element) => value + element),
      ).throws<StateError>();
    },
  );

  test('fold returns the initial value if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    check(iterable.fold(0, (value, element) => value + element)).equals(0);
  });

  test('fold returns the result of combining all elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.fold(0, (value, element) => value + element)).equals(6);
  });

  test('skip returns an empty iterable if count is greater than length', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.skip(3)).isEmpty();
  });

  test('skip returns the remaining elements after skipping count elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.skip(1)).deepEquals([2, 3]);
  });

  test(
    'skip on skip returns the remaining elements after skipping count elements',
    () {
      final iterable = _ListIterable([1, 2, 3]);
      check(iterable.skip(1).skip(1)).deepEquals([3]);
    },
  );

  test('take returns the first count elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.take(2)).deepEquals([1, 2]);
  });

  test('take returns the entire iterable if count is greater than length', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.take(4)).deepEquals([1, 2, 3]);
  });

  test('take on take returns the first count elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.take(2).take(1)).deepEquals([1]);
  });

  test('take on skip returns the first count elements', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.skip(1).take(1)).deepEquals([2]);
  });

  test('toList returns an empty list if the iterable is empty', () {
    final iterable = _ListIterable<int>([]);
    check(iterable.toList()).deepEquals([]);
  });

  test('toList returns a list with the elements of the iterable', () {
    final iterable = _ListIterable([1, 2, 3]);
    check(iterable.toList()).deepEquals([1, 2, 3]);
  });
}

final class _ListIterable<E> extends FixedLengthIterable<E> {
  final List<E> _elements;
  _ListIterable(this._elements);

  @override
  int get length => _elements.length;

  @override
  E elementAt(int index) => _elements[index];
}

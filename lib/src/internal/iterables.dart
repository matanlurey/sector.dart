part of '../internal.dart';

/// Returns a [StateError] with the message 'No elements'.
Error _noElements() => StateError('No elements');

/// Returns a [StateError] with the message 'More than one element'.
Error _moreThanOneElement() => StateError('More than one element');

/// Expands each sub-iterable into a single continuous iterable.
///
/// The resulting iterable runs through the elements returned by [elements]
/// in the same iteration order, similar to `elements.expand((i) => i)`.
///
/// Throws [StateError] if each sub-iterable does not have the same `length`.
///
/// ## Example
///
/// ```dart
/// final elements = [
///   [1, 2, 3],
///   [4, 5, 6],
/// ];
/// final expanded = ListGrid.expandEqualLength(elements);
/// print(List.of(expanded)); // [1, 2, 3, 4, 5, 6]
/// ```
Iterable<T> expandEqualLength<T>(Iterable<Iterable<T>> elements) {
  int? length;
  return elements.expand((subIterable) {
    if (length == null) {
      length = subIterable.length;
    } else if (subIterable.length != length) {
      throw ArgumentError('All sub-iterables must have the same length.');
    }
    return subIterable;
  });
}

/// Returns the most common element in the provided [elements].
///
/// If multiple elements have the same count, the first element is returned.
///
/// If the elements are empty, an error is thrown.
T mostCommonElement<T>(Iterable<T> elements) {
  T? mostCommon;
  var mostCommonCount = 0;
  final counts = HashMap<T, int>();
  for (final element in elements) {
    final count = counts.update(
      element,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    if (count > mostCommonCount) {
      mostCommon = element;
      mostCommonCount = count;
    }
  }

  if (mostCommon is! T) {
    throw _noElements();
  }

  return mostCommon;
}

/// An [Iterable] for classes that have an efficient fixed [length] property.
///
/// All methods are implemented in terms of [length] and [elementAt].
abstract class FixedLengthIterable<E> extends Iterable<E> {
  /// This constructor exists to allow subclasses to have a `const` constructor.
  const FixedLengthIterable();

  /// Returns the number of elements in the iterable.
  @override
  @mustBeOverridden
  int get length;

  @override
  Iterator<E> get iterator => _EfficientFixedLengthIterator(this);

  @override
  void forEach(void Function(E element) action) {
    for (var i = 0; i < length; i++) {
      action(elementAt(i));
    }
  }

  @override
  @mustBeOverridden
  E elementAt(int index);

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  E get first {
    if (isEmpty) {
      throw _noElements();
    }
    return elementAt(0);
  }

  @override
  E get last {
    if (isEmpty) {
      throw _noElements();
    }
    return elementAt(length - 1);
  }

  @override
  E get single {
    if (isEmpty) {
      throw _noElements();
    }
    if (length > 1) {
      throw _moreThanOneElement();
    }
    return elementAt(0);
  }

  @override
  bool every(bool Function(E element) test) {
    for (var i = 0; i < length; i++) {
      if (!test(elementAt(i))) {
        return false;
      }
    }
    return true;
  }

  @override
  bool any(bool Function(E element) test) {
    for (var i = 0; i < length; i++) {
      if (test(elementAt(i))) {
        return true;
      }
    }
    return false;
  }

  @override
  E firstWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (var i = 0; i < length; i++) {
      final element = elementAt(i);
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) {
      return orElse();
    }
    throw _noElements();
  }

  @override
  E lastWhere(bool Function(E element) test, {E Function()? orElse}) {
    for (var i = length - 1; i >= 0; i--) {
      final element = elementAt(i);
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) {
      return orElse();
    }
    throw _noElements();
  }

  @override
  E singleWhere(bool Function(E element) test, {E Function()? orElse}) {
    late E result;
    var match = false;
    for (var i = 0; i < length; i++) {
      final element = elementAt(i);
      if (test(element)) {
        if (match) {
          throw _moreThanOneElement();
        }
        result = element;
        match = true;
      }
    }
    if (!match) {
      if (orElse != null) {
        return orElse();
      }
      throw _noElements();
    }
    return result;
  }

  @override
  String join([String separator = '']) {
    if (isEmpty) {
      return '';
    }
    final buffer = StringBuffer();
    buffer.write(elementAt(0));
    for (var i = 1; i < length; i++) {
      buffer.write(separator);
      buffer.write(elementAt(i));
    }
    return buffer.toString();
  }

  @override
  E reduce(E Function(E value, E element) combine) {
    if (isEmpty) {
      throw _noElements();
    }
    var value = elementAt(0);
    for (var i = 1; i < length; i++) {
      value = combine(value, elementAt(i));
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    var value = initialValue;
    for (var i = 0; i < length; i++) {
      value = combine(value, elementAt(i));
    }
    return value;
  }

  @override
  Iterable<E> skip(int count) {
    if (count >= length) {
      return const Iterable.empty();
    }
    return _SubRangeIterable(this, count);
  }

  @override
  Iterable<E> take(int count) {
    if (count >= length) {
      return this;
    }
    return _SubRangeIterable(this, 0, count);
  }

  @override
  List<E> toList({bool growable = true}) {
    if (isEmpty) {
      return List<E>.empty(growable: growable);
    }
    final list = List<E>.filled(length, elementAt(0), growable: growable);
    for (var i = 1; i < length; i++) {
      list[i] = elementAt(i);
    }
    return list;
  }
}

final class _SubRangeIterable<E> extends FixedLengthIterable<E> {
  _SubRangeIterable(
    this._iterable,
    this._start, [
    int? count,
  ]) : _endOrLength = count == null ? null : _start + count {
    RangeError.checkNotNegative(_start, 'start');
    if (count != null) {
      RangeError.checkValueInInterval(count, _start, _iterable.length, 'count');
    }
  }

  final FixedLengthIterable<E> _iterable;
  final int _start;
  final int? _endOrLength;

  @override
  int get length => (_endOrLength ?? _iterable.length) - _start;

  @override
  E elementAt(int index) {
    RangeError.checkValidIndex(index, this);
    return _iterable.elementAt(_start + index);
  }

  @override
  Iterable<E> skip(int count) {
    final newStart = _start + count;
    if (newStart >= _iterable.length) {
      return const Iterable.empty();
    }
    return _SubRangeIterable(_iterable, newStart, _endOrLength);
  }

  @override
  Iterable<E> take(int count) {
    final oldLength = _endOrLength ?? _iterable.length;
    final newLength = math.min(count, oldLength);
    return _SubRangeIterable(_iterable, _start, newLength);
  }
}

final class _EfficientFixedLengthIterator<E> implements Iterator<E> {
  _EfficientFixedLengthIterator(this._iterable);

  final FixedLengthIterable<E> _iterable;
  var _index = -1;

  @override
  E get current => _iterable.elementAt(_index);

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() => ++_index < _iterable.length;
}

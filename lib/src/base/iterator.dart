import 'package:meta/meta.dart';

/// An interface for getting cells, one at a time, from a grid.
///
/// If a grid is changed during the iteration, the behavior is unspecified.
mixin GridIterator<E> implements Iterator<E> {
  /// The current cell value.
  ///
  /// If the iterator has not yet been moved to the first element ([moveNext]
  /// has not been called yet), or if the iterator has been moved past the last
  /// element of the grid, then [current] is unspecified; a grid iterator may
  /// either throw or return an iterator specific default value.
  ///
  /// The [current] getter should keep its value until the next call to
  /// [moveNext], even if the grid changes. After a successful call to
  /// [moveNext], the user doesn't need to cache the current value, but can keep
  /// reading it from the iterator.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid<String>.generate(2, 2, (x, y) => '($x, $y)');
  /// final iterator = grid.traverse().iterator;
  /// while (iterator.moveNext()) {
  ///   print(iterator.current);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// (0, 0)
  /// (1, 0)
  /// (0, 1)
  /// (1, 1)
  /// ```
  @override
  E get current;

  /// Advances the iterator to the next cell of the iteration.
  ///
  /// Should be called before reading [current].
  ///
  /// If the call to [moveNext] returns `true`, then [current] will contain the
  /// next cell of the iteration, and [position] will contain the offset of
  /// the cell until [moveNext] is called again.
  ///
  /// If the call returns `false`, there are no further cells and [current] and
  /// [position] should not be used any more.
  ///
  /// It is safe to call [moveNext] after it has already returned `false`, but
  /// it must keep returning `false` and not have any other effect.
  ///
  /// A call to [moveNext] may throw for various reasons, including a concurrent
  /// change to an underlying grid. If that happens, the iterator may be in an
  /// inconsistent state, and any further behavior of the iterator is
  /// unspecified, including the effect of reading [current] and
  /// [position].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid<int>.filled(2, 2, 0);
  /// final iterator = grid.traverse().iterator;
  /// print(iterator.moveNext()); // true
  /// print(iterator.moveNext()); // true
  /// print(iterator.moveNext()); // true
  /// print(iterator.moveNext()); // true
  /// print(iterator.moveNext()); // false
  /// ```
  @override
  bool moveNext();

  /// The current offset.
  ///
  /// If the iterator has not yet been moved to the first element ([moveNext]
  /// has not been called yet), or if the iterator has been moved past the last
  /// element of the grid, then [position] is unspecified; a grid iterator
  /// may either throw or return an iterator specific default value.
  ///
  /// The [position] getter should keep its value until the next call to
  /// [moveNext], even if the grid changes. After a successful call to
  /// [moveNext], the user doesn't need to cache the current value, but can keep
  /// reading it from the iterator
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid<int>.filled(2, 2, 0);
  /// final iterator = grid.traverse().iterator;
  /// while (iterator.moveNext()) {
  ///   print(iterator.position);
  /// }
  /// ```
  ///
  /// The output of the example is:
  /// ```txt
  /// (0, 0)
  /// (1, 0)
  /// (0, 1)
  /// (1, 1)
  /// ```
  (int, int) get position;

  /// An iterator over the offsets of the grid instead of the cell values.
  Iterator<(int, int)> get positions {
    return _GridPositionsIterator(this);
  }

  /// An iterator over the cell values, offsets, and offsets of the grid.
  Iterator<(int, int, E)> get positioned {
    return _GridCombinedIterator(this);
  }
}

final class _GridPositionsIterator implements Iterator<(int, int)> {
  const _GridPositionsIterator(this._iterator);
  final GridIterator<void> _iterator;

  @override
  (int, int) get current => _iterator.position;

  @override
  bool moveNext() => _iterator.moveNext();
}

final class _GridCombinedIterator<E> implements Iterator<(int, int, E)> {
  const _GridCombinedIterator(this._iterator);
  final GridIterator<E> _iterator;

  @override
  (int, int, E) get current {
    final (x, y) = _iterator.position;
    return (x, y, _iterator.current);
  }

  @override
  bool moveNext() => _iterator.moveNext();
}

/// An interface for getting cells from a grid, in either direction.
///
/// If a grid is changed during the iteration, the behavior is unspecified.
///
/// A [BidirectionalGridIterator] sometimes allows using [moveNext] and
/// [movePrevious], even when a previous call to [moveNext] or [movePrevious]
/// returned `false`. Read the implementation documentation for more details.
///
/// ## Examples
///
/// For convenience, a [BidirectionalGridIterator] can reverse the iteration
/// direction by calling [reversed] to toggle between moving forwards and
/// backwards:
///
/// ```dart
/// final grid = Grid<int>.filled(2, 2, 0);
/// final iterator = grid.traverse(RowMajorTraversal(start: (1, 1))).iterator;
/// final reversed = iterator.reversed;
/// while (reversed.moveNext()) {
///   print(reversed.position);
/// }
/// ```
///
/// The output of the example is:
///
/// ```txt
/// (1, 1)
/// (0, 1)
/// (1, 0)
/// (0, 0)
/// ```
mixin BidirectionalGridIterator<E> implements GridIterator<E> {
  /// Advances the iterator to the previous cell of the iteration.
  ///
  /// Should be called before reading [current].
  ///
  /// If the call to [movePrevious] returns `true`, then [current] will contain
  /// the previous cell of the iteration, and [position] will contain the
  /// offset of the cell until [movePrevious] is called again.
  ///
  /// If the call returns `false`, there are no further cells and [current] and
  /// [position] should not be used any more. Some implementations may
  /// allow calling [moveNext] after [movePrevious] returns `false`, and
  /// vice-versa, but this is not guaranteed.
  ///
  /// A call to [movePrevious] may throw for various reasons, including a
  /// concurrent change to an underlying grid. If that happens, the iterator may
  /// be in an inconsistent state, and any further behavior of the iterator is
  /// unspecified, including the effect of reading [current] and
  /// [position].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid<int>.filled(2, 2, 0);
  /// final iterator = grid.traverse().iterator;
  /// print(iterator.movePrevious()); // false
  /// print(iterator.moveNext()); // true
  /// print(iterator.moveNext()); // true
  /// print(iterator.movePrevious()); // true
  /// print(iterator.movePrevious()); // true
  /// print(iterator.movePrevious()); // false
  /// ```
  bool movePrevious();

  /// The same iterator, with [moveNext] and [movePrevious] swapped.
  ///
  /// This is useful for providing an iterator where [moveNext] moves in the
  /// opposite direction, such as when moving backwads in a row-major traversal.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid<int>.filled(2, 2, 0);
  /// final iterator = grid.traverse(RowMajorTraversal(start: (1, 1))).iterator;
  /// final reversed = iterator.reversed;
  /// while (reversed.moveNext()) {
  ///   print(reversed.position);
  /// }
  /// ```
  ///
  /// The output of the example is:
  ///
  /// ```txt
  /// (1, 1)
  /// (0, 1)
  /// (1, 0)
  /// (0, 0)
  /// ```
  BidirectionalGridIterator<E> get reversed => _ReversedGridIterator<E>(this);

  @override
  Iterator<(int, int)> get positions {
    return _GridPositionsIterator(this);
  }

  @override
  Iterator<(int, int, E)> get positioned {
    return _GridCombinedIterator(this);
  }
}

final class _ReversedGridIterator<E>
    with GridIterator<E>
    implements BidirectionalGridIterator<E> {
  const _ReversedGridIterator(this._iterator);

  final BidirectionalGridIterator<E> _iterator;

  @override
  E get current => _iterator.current;

  @override
  (int, int) get position => _iterator.position;

  @override
  bool moveNext() => _iterator.movePrevious();

  @override
  bool movePrevious() => _iterator.moveNext();

  @override
  BidirectionalGridIterator<E> get reversed => _iterator;
}

/// An interface for getting cells from a grid with efficient random access.
///
/// If a grid is changed during the iteration, the behavior is unspecified.
///
/// A [SeekableGridIterator] allows seeking to a specific cell in the grid
/// without having to iterate over all the cells in between. This is useful for
/// algorithms that need to jump to specific cells in the grid, such as path
/// finding or flood filling.
///
/// Similar to [BidirectionalGridIterator], a [SeekableGridIterator] may allow
/// calling [moveNext], [movePrevious], or [seek] after a previous call to
/// [moveNext], [movePrevious], or [seek] returned `false`, but this is not
/// guaranteed.
///
/// ## Examples
///
/// ```dart
/// final grid = Grid<int>.filled(2, 2, 0);
/// final iterator = grid.traverse().iterator;
/// print(iterator.seek((1, 1))); // true
/// print(iterator.position); // (1, 1)
/// print(iterator.seek((2, 2)); // false
/// ```
mixin SeekableGridIterator<E> implements BidirectionalGridIterator<E> {
  /// Advances the iterator to the cell at [step] steps from the current cell.
  ///
  /// If the call to [seek] returns `true`, then [current] will contain the cell
  /// at the provided offset, and [position] will contain the offset of the
  /// cell.
  ///
  /// If the call returns `false`, the provided index is out of bounds and
  /// [current] and [position] should not be used any more.
  ///
  /// A call to [seek] may throw for various reasons, including a concurrent
  /// change to an underlying grid. If that happens, the iterator may be in an
  /// inconsistent state, and any further behavior of the iterator is
  /// unspecified, including the effect of reading [current] and
  /// [position].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// final grid = Grid<int>.filled(2, 2, 0);
  /// final iterator = grid.traverse().iterator;
  /// print(iterator.seek(2)); // true
  /// print(iterator.position); // (0, 1)
  /// print(iterator.seek(4)); // false
  /// ```
  bool seek(int step);

  @override
  bool moveNext() => seek(1);

  @override
  bool movePrevious() => seek(-1);

  @override
  BidirectionalGridIterator<E> get reversed => _ReversedGridIterator<E>(this);

  @override
  Iterator<(int, int)> get positions {
    return _GridPositionsIterator(this);
  }

  @override
  Iterator<(int, int, E)> get positioned {
    return _GridCombinedIterator(this);
  }
}

@internal
final class ForwardGridIterable<E> extends Iterable<(int, int, E)> {
  const ForwardGridIterable(this._iterator);
  final GridIterator<E> Function() _iterator;

  @override
  Iterator<(int, int, E)> get iterator => _iterator().positioned;
}

Never _noElement() => throw StateError('No element');

@internal
final class BidirectionalGridIterable<E> extends Iterable<(int, int, E)> {
  const BidirectionalGridIterable({
    required BidirectionalGridIterator<E> Function() start,
    required BidirectionalGridIterator<E> Function() end,
  })  : _start = start,
        _end = end;

  final BidirectionalGridIterator<E> Function() _start;
  final BidirectionalGridIterator<E> Function() _end;

  @override
  Iterator<(int, int, E)> get iterator => _start().positioned;

  @override
  (int, int, E) get last {
    final it = _end();
    if (!it.movePrevious()) {
      _noElement();
    }
    final (x, y) = it.position;
    return (x, y, it.current);
  }

  @override
  (int, int, E) lastWhere(
    bool Function((int, int, E)) test, {
    (int, int, E) Function()? orElse,
  }) {
    final it = _end();
    while (it.movePrevious()) {
      final current = it.current;
      final position = it.position;
      final value = (position.$1, position.$2, current);
      if (test(value)) {
        return value;
      }
    }
    if (orElse != null) {
      return orElse();
    }
    _noElement();
  }
}

@internal
final class SeekableGridIterable<E> extends Iterable<(int, int, E)> {
  const SeekableGridIterable(this._it);

  final SeekableGridIterator<E> Function() _it;

  @override
  Iterator<(int, int, E)> get iterator => _it().positioned;

  @override
  (int, int, E) elementAt(int index) {
    final it = _it();
    if (!it.seek(index)) {
      _noElement();
    }
    final (x, y) = it.position;
    return (x, y, it.current);
  }

  @override
  Iterable<(int, int, E)> skip(int count) {
    return SeekableGridIterable(() => _it()..seek(count));
  }

  @override
  (int, int, E) get last {
    final it = _it();
    if (!it.movePrevious()) {
      _noElement();
    }
    final (x, y) = it.position;
    return (x, y, it.current);
  }

  @override
  (int, int, E) lastWhere(
    bool Function((int, int, E)) test, {
    (int, int, E) Function()? orElse,
  }) {
    final it = _it();
    while (it.movePrevious()) {
      final current = it.current;
      final position = it.position;
      final value = (position.$1, position.$2, current);
      if (test(value)) {
        return value;
      }
    }
    if (orElse != null) {
      return orElse();
    }
    _noElement();
  }
}

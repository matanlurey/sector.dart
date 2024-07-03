# Change Log

## 0.3.0

This is a relatively large release, with a few breaking changes, but also a lot
of new features and improvements. The main focus of this release was to improve
the ergonomics of the API, and to provide more ways to interact with the grid
data structure.

### Bug Fixes

- Fixed a bug in `Grid.fromColumns` (and `ListGrid.fromColumns`) where the
  columns were not copied correctly, and the grid was not initialized with the
  correct dimensions.

- Fixed a bug in `<Grid>.columns.remove*` where, similar to above, the grid was
  not updated correctly.

- Fixed a bug in `<ListGrid>.view` where an empty list of cells was not used as
  the backing storage as documented.

### Breaking Changes

- Moved `<Grid>.layoutHint` and `<Grid>.getByIndexUnchecked` to the optional
  mixin `EfficientIndexGrid`, which only provides these methods. This allows
  users to opt-in to these methods, and not have them clutter the API of the
  main `Grid` class:

  ```dart
  class MyListGrid<T> with Grid<T>, EfficientIndexGrid<T> {
    final List<T> _list;

    /* ... */

    @override
    LayoutHint get layoutHint => LayoutHint.rowMajorContinguous;

    @override
    T getByIndexUnchecked(int index) => _list[index];

    @override
    void setByIndexUnchecked(int index, T value) {
      _list[index] = value;
    }
  }
  ```

  In addition, removed `LayoutHint.private`; it's not possible to have a
  "private" layout, as the point of the layout hint is to provide information
  about the layout of the grid to algorithms that traverse the grid.

- Replaced `Rows` and `Columns` with `GridAxis`; both of these types only
  existed to have a common interface for iterating over rows and columns, but
  ironically the only common base was `Iterable<Iterable<T>>`.

  `GridAxis` is a more general type that can be used to iterate over rows and
  columns, and even allow users to define their own axis. The common way to
  implement those will be `RowsMixin` and `ColumnsMixin`, which replaces the
  types `RowsBase` and `ColumnsBase` accordingly.

  ```diff
  - class MyRows extends Iterable<Iterable<T>> with RowsBase<T> { /* ... */ }
  + class MyRows extends GridAxis<T> with RowsMixin<T> { /* ... */ }
  ```

- Changed `<Grid>.traversal` and `Traversal` to allow arbitrary return types,
  i.e. not strictly a `GridIterable<T>`. This allows users to use the traversal
  API to create custom traversals that return different types of elements, e.g.
  custom transformations, filters, or other types of elements:

  ```diff
  - Traversal<T> rowMajor<T>(...) { ... }
  + Traversal<GridIterable<T>, T> rowMajor<T>(...) { ... }
  ```

  As a result, `.traversal` now _requires_ an argument, versus defaulting to
  `rowMajor()` before:

  ```diff
  - for (final element in grid.traversal) { /* ... */ }
  + for (final element in grid.traversal(rowMajor())) { /* ... */ }
  ```

  An example of benefitting from this change is the `prettyPrint` traversal:

  ```dart
  final string = Grid.fromRows([
    [1, 2, 3],
    [4, 5, 6],
  ]).traversal(prettyPrint());
  print(string);
  // ┌───────┐
  // │ 1 2 3 │
  // │ 4 5 6 │
  // └───────┘
  ```
  
### New Features

- Extending or mixing in `Grid<T>` provides a default implementation of `clear`.

- Added `UnmodifiableGridView`, which wraps a `Grid` and makes it unmodifiable.

- Added `GridImpl.transpose` to create a `List<List<T>>` from an iterable of
  iterables, where the rows are the columns of the original grid and vice versa;
  used as an implementation detail in `ListGrid.fromColumns`.

- Added `SplayTreeGrid`, which is a sparse grid that uses a `SplayTreeMap` to
  store the elements. This grid is useful when the grid is sparse, and the
  elements are typically accessed in a sorted order:

  ```dart
  final grid = SplayTreeGrid.fromRows([
    ['a', ' ', ' '],
    [' ', 'b', ' '],
    [' ', ' ', 'c'],
  ]);
  print(grid.toSparseMap()); // {0: {0: 'a'}, 1: {1: 'b'}, 2: {2: 'c'}}
  ```

- Added `drawRect` as a traveresal that draws a rectangle on the grid:

  ```dart
  for (final cell in grid.traverse(drawRect(0, 0, 10, 10))) {
    // ...
  }
  ```

- Added `<LayoutHint>.toPosition` and `<LayoutHint>.toIndex` to convert between
  positions and indices, and vice versa, based on the layout hint, without
  having to write this code over and over again.

## 0.2.0

- Renamed `<Grid>.contains` to `<Grid>.containsXY`:

  ```diff
  - if (grid.contains(0, 0)) {
  + if (grid.containsXY(0, 0)) {
  ```

- Added `<Grid>.contains` to check if a given element is within the grid,
  similar to `List.contains`:

  ```dart
  if (grid.contains('#')) {
    // ...
  }
  ```

- Removed `Uint8Grid`, in favor of `ListGrid.view(List<T>, {int width})`:

  ```diff
  - final grid = Uint8Grid(3, 3);
  + final grid = ListGrid.view(Uint8List(3 * 3), width: 3);
  ```

  This reducs the API surface, and focuses on the key use-case of creating a
  grid without copying the data: using compact lists as backing storage without
  generics or codegen.

- Added `GridIterator`, `GridIterable` and `Traversal`. These classes provide
  ways to iterate over the elements of a grid, and to traverse the grid in
  different directions.

  For example, a _row-major_ traversal:

  ```dart
  for (final element in grid.traverse(rowMajor())) {
    // ...
  }
  ```

  See also:

  - `rowMajor`
  - `drawLine`

- Added `<Grid>.layoutHint` and `<Grid>.getByIndexUnchecked`; these methods
  allow for more efficient traversal of the grid, by providing a hint about the
  layout of the grid, and by accessing elements by index without extra bounds
  checking.
  
  Most users never need to use these methods.

## 0.1.1

- Added `Uint8Grid`, the first sub-type of `TypedDataGrid`. A `Uint8Grid`, like
  it's counterpart `Uint8List`, is a grid of _unsigned 8-bit integers_, which
  makes it suitable for storing pixel data, tile maps, and other data that can
  be represented as a grid of 8-bit values.

## 0.1.0

🎉 Initial release 🎉
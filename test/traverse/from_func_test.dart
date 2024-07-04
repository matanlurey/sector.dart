import '../_prelude.dart';

void main() {
  final func = GridTraversal.from(<T>(_) => GridIterator.empty());

  test('should technically work', () {
    check(Grid<void>.empty().traverse(func)).isEmpty();
  });
}

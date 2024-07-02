import '../_prelude.dart';
import '../src/suites/unmodifiable.dart';

void main() {
  runUnmodifiableTestSuite(
    () => UnmodifiableGridView(Grid.filled(2, 2, 0)),
    fill: 1,
  );
}

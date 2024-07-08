import '../prelude.dart';
import 'suite.dart';

void main() {
  group('NaiveListGrid.fromRows', () {
    runSuiteGridFromRows(NaiveListGrid.fromRows);
  });

  group('NaiveListGrid', () {
    runSuiteGridBody(NaiveListGrid.fromRows);
  });
}

import 'package:test/test.dart';
import 'package:Timie/usage.dart';

void main() {
  test('check start of day', () {
    var now = new DateTime.now();
    var startOfDay = new DateTime(now.year, now.month, now.day, 0, 0, 1);
    expect(startOfDay, Usage.getStartOfDay(0));
  });
}
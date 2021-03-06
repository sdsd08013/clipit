import 'package:clipit/models/history.dart';
import 'package:test/test.dart';

void main() {
  test('when isSelected true fromMap returns selected History', () {
    final t = History.fromMap({
      'id': 1,
      'text': 'text',
      'count': 100,
      'created_at': "2022-05-28T04:45:39.350741Z",
      'updated_at': "2022-05-28T04:45:39.350810Z"
    }, true);

    expect(t.isSelected, true);
  });
}

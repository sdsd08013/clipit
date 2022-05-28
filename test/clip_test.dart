import 'package:clipit/models/clip.dart';
import 'package:test/test.dart';

void main() {
  test('when isSelected true fromMap returns selected Clip', () {
    final t = Clip.fromMap({
      'id': 1,
      'text': 'text',
      'count': 100,
      'created_at': "2022-05-28T04:45:39.350741Z",
      'updated_at': "2022-05-28T04:45:39.350810Z"
    }, true);

    expect(t.isSelected, true);
  });
}

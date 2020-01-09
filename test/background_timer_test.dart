import 'package:flutter_test/flutter_test.dart';
import 'package:background_timer/background_timer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () async {
    expect(await BackgroundTimer.isActive, false);
  });
}

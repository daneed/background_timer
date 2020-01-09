import 'package:flutter_test/flutter_test.dart';
import 'package:ios_background_timer/ios_background_timer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () async {
    expect(await IosBackgroundTimer.isActive, false);
  });
}

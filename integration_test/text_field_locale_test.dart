import 'package:integration_test/integration_test.dart';
import '../test/support/text_field_locale_regressions.dart';

// Profile mode rejects the test client's -1 text-input ID. Register the test
// input channel so enterText uses the actual client ID rather than silently
// dropping text. The app still runs on the device; this suite simulates its IME.
class _LocaleTestBinding extends IntegrationTestWidgetsFlutterBinding {
  @override
  bool get registerTestTextInput => true;
}

void main() {
  _LocaleTestBinding();
  registerLegacyLocaleControl();
  registerTextFieldLocaleRegressions();
}

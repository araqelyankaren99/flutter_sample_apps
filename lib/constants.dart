/// `flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...`
/// or `--dart-define-from-file=dart_defines.json` (copy from `dart_defines.example.json`).
const String stripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: '',
);

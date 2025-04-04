import 'package:flutter_sample_apps/src/constants.dart' as constants;

class StripePreferences {
  StripePreferences._();

  static const apiVersion = '2020-08-27';

  static const _publicKeyLive =
      'pk_live_51JAUkjH7QXZR8RjlcMijs3WH3mjx2brTwILyH2FnV2p1FCVsEvw4Iv8fvqOqIwKcEkOOFLchgyZL55m24P6Gayj300Mw0tqbby';
  static const _publicKeyTest =
      'pk_test_51JAUkjH7QXZR8Rjlb4f0oUMxIcfQsPiZNwqisH0od4pSSDptWZhCUpFXV9pnBw7u7wsFYYzQpDeP0n3c1vAPMgTp00jYVKOo0c';

  static String publicKey = constants.isTestMode ? _publicKeyTest : _publicKeyLive;
}

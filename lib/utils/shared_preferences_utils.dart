import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static late SharedPreferences sharedPrefsUtils;

  Future<void> init() async {
    sharedPrefsUtils = await SharedPreferences.getInstance();
  }

  String get getStorageToken => sharedPrefsUtils.getString('user_token') ?? '';

  String get getSharedPrefsName =>
      sharedPrefsUtils.getString('user_name') ?? '';

  String get getSharedPrefsEmail =>
      sharedPrefsUtils.getString('user_email') ?? '';

  Future<void> clearSharedPreferences() async {
    await sharedPrefsUtils.clear();
  }

  Future<void> setSharedPrefsToken(String value) async {
    await sharedPrefsUtils.setString('user_token', value);
  }

  Future<void> setSharedPrefsName(String value) async {
    await sharedPrefsUtils.setString('user_name', value);
  }

  Future<void> setSharedPrefsEmail(String value) async {
    await sharedPrefsUtils.setString('user_email', value);
  }
}

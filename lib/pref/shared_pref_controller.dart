import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

enum PrefKeys {email, loggedIn}

class SharedPrefController {

  static final SharedPrefController _instance = SharedPrefController
      ._internal();
  late SharedPreferences _sharedPreferences;

  factory SharedPrefController(){
    return _instance;
  }

  SharedPrefController._internal();

  Future<void> initPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> save({required User user}) async {
    await _sharedPreferences.setBool(PrefKeys.loggedIn.toString(), true);
    await _sharedPreferences.setString(PrefKeys.email.toString(), user.email);
  }

  bool get loggedIn => _sharedPreferences.getBool(PrefKeys.loggedIn.toString()) ?? false;

  Future<bool> clear() async{
    return await _sharedPreferences.clear();
  }
}
import 'package:shared_preferences/shared_preferences.dart';

Future<String> checkAPI() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? api_token = prefs.getString('api_token');
  prefs.remove('user_id');
  prefs.remove('user_pw');
  return '${api_token}';
}
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homepage.dart';
import '../Utility/user_model.dart';
import 'server_disconnect.dart';

String listapi = dotenv.get("API_HOST", fallback: "");
String apikey = dotenv.get("API_KEY", fallback: "");

Future<void> autoSignIn(context) async {
  try {
    if (listapi.isEmpty) {
      disconnected();
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedUserId = prefs.getString('remembered_user_id') ?? '';
    String storedUserPw = prefs.getString('remembered_user_pw') ?? '';
    if (storedUserId.isEmpty || storedUserPw.isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'โปรดใส่รหัสของท่าน',
      );
      return;
    }
    var res = await http.post(Uri.parse('$listapi/login'), body: {
      "user": storedUserId,
      "password": storedUserPw,
    }, headers: {
      'api-key': apikey,
    });
    if (res.statusCode == 200) {
      var response = jsonDecode(res.body);
      var user_data = response;
      if (user_data.containsKey('emp') &&
          user_data.containsKey('name') &&
          user_data.containsKey('api_token') &&
          user_data.containsKey('depid') &&
          user_data.containsKey('line_token') &&
          user_data.containsKey('fcm') &&
          user_data.containsKey('profile_photo_url') &&
          user_data.containsKey('detail')) {
        prefs.setString('user_id', user_data['emp']);
        prefs.setString('name', user_data['name']);
        prefs.setString('api_token', user_data['api_token']);
        prefs.setString('depid', user_data['depid']);
        prefs.setString('line_token', user_data['line_token'] ?? '');
        prefs.setString('fcm', user_data['fcm'] ?? '');
        prefs.setString('user_img', user_data['profile_photo_url']);
        String position = user_data['detail'][0]['position'];
        prefs.setString('position', position);
        User user = User(
          id: user_data['emp'],
          name: user_data['name'],
          api_token: user_data['api_token'],
          depid: user_data['depid'],
          linetoken: user_data['line_token'] ?? '',
          fcm: user_data['fcm'] ?? '',
          position: user_data['detail'][0]['position'],
        );
        user.setprofileimg(user_data['user_img']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home_Page(
              user: user,
            ),
          ),
        );
      }
    } else if (res.statusCode == 401) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: '(${res.statusCode}): โปรดออกจากระบบ',
        text: 'โปรดออกจากระบบและตรวจสอบความถูกต้องของข้อมูล',
      );
    } else {
      Fluttertoast.showToast(
        msg: "${res.statusCode}: ไม่สามารถเข้าสู่ระบบได้ขออภัยในความไม่สะดวก",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_LEFT,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  } catch (e) {
    print(e);
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../loginpage.dart';

String listapi = dotenv.get("API_HOST", fallback: '');
String apikey = dotenv.get("API_KEY", fallback: '');

Future<void> clearSession(context, String user_id, String api_token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    var res = await http.post(Uri.parse('$listapi/logout'), body: {
      "user": user_id,
      "api_token": api_token,
    }, headers: {
      'api-key': apikey,
    });
    if (res.statusCode == 102) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Loading',
        text: 'กำลังนำท่านออกจากระบบ...โปรดรอสักครู่',
      );
    }
    else if (res.statusCode == 200) {
      prefs.remove('user_id');
      prefs.remove('name');
      prefs.remove('plv');
      prefs.remove('api_token');
      prefs.remove('depid');
      prefs.remove('line_token');
      prefs.remove('user_img');
      prefs.remove('fcm');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(skipAutoLogin: true),
        ),
      );
      Fluttertoast.showToast(
        msg: "ได้ออกจากระบบแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_LEFT,
        timeInSecForIosWeb: 15,
        backgroundColor: Colors.white,
        textColor: Colors.green,
        fontSize: 16.0,
      );
    } else if (res.statusCode == 401) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: '',
        text: '(${res.statusCode}): บางอย่างผิดปกติ โปรด ปิด/ปัด แอพออกแล้วเข้าใหม่',
      );
    } 
    else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: '',
        text: '(${res.statusCode}): ระบบเกิดปัญหาขออภัยในความไม่สะดวกโปรดติดต่อแผนกคอมพิวเตอร์',
      );
    }
  } catch (e) {
    print(e);
  }
}

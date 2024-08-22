import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Utility/user_model.dart';
import '../historyleave.dart';
import '../historypage.dart';

String listapi = dotenv.get("API_HOST", fallback: '');
String apikey = dotenv.get("API_KEY", fallback: '');

Future<void> history(
  context,
  User user,
  String user_id,
  String api_token,
) async {
  var res = await http.post(Uri.parse('$listapi/history/'), body: {
    "user": user_id,
    "api_token": api_token,
  }, headers: {
    'api-key': apikey
  });
  var response = jsonDecode(res.body);
  if (res.statusCode == 200) {
    var user_data = response['data'];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => historypage(
          user: user,
          userdata: user_data,
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: const Text('ไม่สามารเปิดดูประวัติได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
    print("API request failed with status code ${res.statusCode}");
  }
}

Future<void> showleaves(
  context,
  User user,
  String id,
  String api_token,
) async {
  try {
    var res = await http.post(Uri.parse('$listapi/leaves/'), body: {
      "user": id,
      "api_token": api_token,
    }, headers: {
      'api-key': apikey,
    });
    var response = jsonDecode(res.body);
    if (res.statusCode == 200) {
      var user_data = response['data'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => historyleave(
            user: user,
            userdata: user_data,
          ),
        ),
      );
    } else {
      print("(status code: ${res.statusCode}) API request failed with");
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: const Text('ไม่สามารเปิดดูประวัติได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}

Future<void> grantInsert(String id, String token, String fCMTokenMyapp, context) async {
    var request = http.MultipartRequest('POST',Uri.parse('$listapi/grant/'));
    request.headers['api-key'] = apikey;
    request.fields['user'] = id;
    request.fields['api_token'] = token;
    request.fields['fcm'] = fCMTokenMyapp;
    var res = await request.send();
    if (res.statusCode == 200) {
      print('fCMToken Insert Successfully!');
    } else {
      print('(status code: ${res.statusCode}) grantInsert API Something went wrong!');
    }
  }

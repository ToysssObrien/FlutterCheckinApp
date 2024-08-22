import 'package:checkin_rubv2/Utility/check_autologin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utility/check_permission.dart';
import 'Utility/colors_font.dart';
import 'Utility/server_disconnect.dart';
import 'homepage.dart';
import 'Utility/user_model.dart';

String listapi = dotenv.get("API_HOST", fallback: "https://mockapi.example.com");
String apikey = dotenv.get("API_KEY", fallback: "your-api-key");

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.skipAutoLogin = false}) : super(key: key);
  final bool skipAutoLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  TextEditingController user_id = TextEditingController();
  TextEditingController user_pw = TextEditingController();
  bool rememberMe = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    PermissionUtil.checkPermission(context);
    loadRememberedCredentials();
    if (!widget.skipAutoLogin) {
      autoSignIn(context);
    }
  }

  void loadRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id.text = prefs.getString('remembered_user_id') ?? '';
      user_pw.text = prefs.getString('remembered_user_pw') ?? '';
      rememberMe = user_id.text.isNotEmpty;
    });
  }

  void toggleRememberMe(bool? value) {
    if (value != null) {
      setState(() {
        rememberMe = value;
      });
    }
  }

  void signin(context) async {
    try {
      if (listapi.isEmpty) {
        disconnected();
        return;
      }
      // Use mock data for testing
      var mockData = {
        "emp": "12345",
        "name": "John Doe",
        "api_token": "abcd1234efgh5678ijkl9012mnop3456qrst7890uvwx1234yzab5678cdef9012",
        "depid": "001",
        "line_token": "abc123",
        "fcm": "def456",
        "profile_photo_url": "https://example.com/images/profile_photo.jpg",
        "detail": [
          {
            "position": "Software Engineer"
          }
        ]
      };

      // Simulate a response for the mock data
      var res = http.Response(jsonEncode(mockData), 200);

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
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('user_id', user_data['emp']);
          prefs.setString('name', user_data['name']);
          prefs.setString('api_token', user_data['api_token']);
          prefs.setString('depid', user_data['depid']);
          prefs.setString('line_token', user_data['line_token'] ?? '');
          prefs.setString('fcm', user_data['fcm'] ?? '');
          prefs.setString('user_img', user_data['profile_photo_url']);
          String position = user_data['detail'][0]['position'];
          prefs.setString('position', position);
          if (rememberMe) {
            prefs.setString('remembered_user_id', user_id.text);
            prefs.setString('remembered_user_pw', user_pw.text);
          } else {
            prefs.remove('remembered_user_id');
            prefs.remove('remembered_user_pw');
          }
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
          Fluttertoast.showToast(
            msg: "เข้าสู่ระบบสำเร็จ",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_LEFT,
            timeInSecForIosWeb: 15,
            backgroundColor: Colors.white,
            textColor: Colors.green,
            fontSize: 16.0,
          );
        }
      } else if (res.statusCode == 401) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: '(${res.statusCode}): ท่านกรอกข้อมูลผิด',
          text: 'โปรดตรวจสอบข้อมูลที่ท่านกรอกด้วยครับ',
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bghospital.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/login_rub_logo.png',
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: const EdgeInsets.only(left: 25, right: 25),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'EmployeeID',
                        hintText: 'โปรดกรอกรหัสพนักงาน',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15.0),
                      ),
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Please Input Your UserID!';
                        }
                        return null;
                      }),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      controller: user_id,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: const EdgeInsets.only(left: 25, right: 25),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'กรุณากรอกรหัสผ่าน',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(15.0),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: ((value) {
                        if (value!.isEmpty) {
                          return 'Please Input Your Password!';
                        }
                        return null;
                      }),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      controller: user_pw,
                      obscureText: _obscureText,
                    ),
                  ),
                ),
                MaterialButton(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  onPressed: () async {
                    bool password = formkey.currentState!.validate();
                    if (password != '') {
                      signin(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: toggleRememberMe,
                    ),
                    Text(
                      'จดจำรหัสของฉันไว้',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

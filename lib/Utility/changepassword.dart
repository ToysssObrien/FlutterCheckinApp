import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import '../homepage.dart';
import 'colors_font.dart';
import 'user_model.dart';

String listapi = dotenv.get("API_HOST", fallback: "");
String apikey = dotenv.get("API_KEY", fallback: "");

class changepassword extends StatefulWidget {
  const changepassword({Key? key, required this.user}) : super(key: key);
  final User user;
  @override
  State<changepassword> createState() => _changepasswordState();
}

class _changepasswordState extends State<changepassword> {
  final formkey = GlobalKey<FormState>();
  TextEditingController user_id = TextEditingController();
  TextEditingController user_pw_old = TextEditingController();
  TextEditingController user_pw_new = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
  }

  void changepassword(String id, String oldPassword, String newPassword, String token, context) async {
    var request = http.MultipartRequest('POST',Uri.parse('$listapi/chenge/'));
    request.headers['api-key'] = apikey;
    request.fields['user'] = widget.user.showid();
    request.fields['api_token'] = token;
    request.fields['password'] = oldPassword;
    request.fields['newpassword'] = newPassword;
    var res = await request.send();
    if (res.statusCode == 201) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: '',
        text: 'ดูเหมือนท่านจะกรอกรหัสผ่านเก่าผิด',
      );
    }
    else if (res.statusCode == 200) {
      QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: 'เปลี่ยนรหัสผ่านสำเร็จ โปรดเข้าสู่ระบบด้วยรหัสใหม่ด้วยครับ',
      onConfirmBtnTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home_Page(
              user: widget.user,
            ),
          ),
        );
      }
    );
    }else{
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('${res.statusCode}: ท่านกรอกข้อมูลผิดพลาด'),
            content: const Text('โปรดพิจารณาข้อมูลของท่านอีกครั้ง...ขออภัยในความไม่สะดวก'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              )
            ],
          );
        },
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    String id = widget.user.showid();
    String token = widget.user.showapi();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('หน้าเปลี่ยนรหัสผ่าน'),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Home_Page(
                    user: widget.user,
                  ),
                ),
              );
            },
          ),
        ),
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
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      controller: TextEditingController(text: id),
                      readOnly: true,
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
                        labelText: 'Password เก่า',
                        hintText: 'กรุณากรอกรหัสผ่านเก่า',
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
                          return 'Please Input Your Old Password!';
                        }
                        return null;
                      }),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      controller: user_pw_old,
                      obscureText: _obscureText,
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
                        labelText: 'Password ใหม่',
                        hintText: 'กรุณากรอกรหัสผ่านใหม่ของท่าน',
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
                          return 'Please Input Your NEW Password!';
                        }
                        return null;
                      }),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      controller: user_pw_new,
                      obscureText: _obscureText,
                    ),
                  ),
                ),
                MaterialButton(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  onPressed: () async {
                  String id = user_id.text;
                  String oldPassword = user_pw_old.text;
                  String newPassword = user_pw_new.text;
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.confirm,
                    title: '',
                    text: 'คุณต้องการเปลี่ยนรหัสผ่าน?',
                    confirmBtnText: 'ใช่',
                    cancelBtnText: 'ไม่',
                    confirmBtnColor: Colors.green,
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                      changepassword(id, oldPassword, newPassword, token, context);
                    },
                  );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "เปลี่ยนรหัสผ่าน",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('ท่านกรอกข้อมูลผิดพลาด'),
          content: const Text('โปรดพิจารณาข้อมูลของท่านอีกครั้ง...ขออภัยในความไม่สะดวก'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}

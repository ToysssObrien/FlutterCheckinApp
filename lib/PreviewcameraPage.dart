// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:camera/camera.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'Utility/colors_font.dart';
import 'Utility/user_model.dart';
import 'checkapi.dart';
import 'homepage.dart';
import 'package:quickalert/quickalert.dart';

class PreviewPage extends StatefulWidget {
  PreviewPage({
    Key? key,
    required this.picture,
    required this.user,
    required this.geo,
  }) : super(key: key);

  final XFile picture;
  final String geo;
  final User user;

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final formkey = GlobalKey<FormState>();
  late TextEditingController pictureController;
  late TextEditingController geoController;

  //func
  late DateTime _myTime;
  late DateTime ntpTime = DateTime.now();

  bool _isLoading = false;
  late String token;
  late String getAPI;
   //getdatentp
  String? dateNow;
  String? timeNow;
  final mark = DateTime.timestamp();
  

  @override
  void initState() {
    token = widget.user.showapi();
    super.initState();
    _getNTPNow();
    pictureController = TextEditingController();
    geoController = TextEditingController();
    checkAPI().then((String api) {
      getAPI = api;
    });
  }

  Future<void> insertRecord(
    File picture,
    String user_id,
    String geo,
    String apitoken,
    String checkTime,
    context,
  )async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Show a quick alert for no internet connection
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'ไม่สามารถส่งได้',
        text: 'กรุณาตรวจสอบเน็ตหรือไวไฟอีกที',
      );
      return;  // Return to exit the function
    }

    // If there is an internet connection, proceed with the data submission
    try {
      setState(() {
        _isLoading = true;
      });
      String listapi = dotenv.get("API_HOST", fallback: '');
      String apikey = dotenv.get("API_KEY", fallback: '');
      var request = http.MultipartRequest('POST', Uri.parse('$listapi/checkin/'));
      request.headers['api-key'] = apikey;
      request.fields['api_token'] = apitoken;
      request.fields['user'] = user_id;
      request.fields['loc'] = geo;
      request.fields['check_time'] = checkTime;
      request.files.add(await http.MultipartFile.fromPath('img', picture.path));
      var res = await request.send();
      if (res.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'บันทึกข้อมูลของท่านสำเร็จ',
          onConfirmBtnTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home_Page(
                  user: widget.user,
                ),
              ),
            );
          },
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: '(${res.statusCode}): เกิดข้อมูลผิดพลาด',
          text: 'ไม่สามารถส่งข้อมูลได้อภัยในความไม่สะดวก',
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    pictureController.dispose();
    geoController.dispose();
    super.dispose();
  }

  //callntp
  void _getNTPNow() async {
  // ntpTime = await NTP.now();
  _myTime = DateTime.now();

  final int offset = await NTP.getNtpOffset(
      localTime: _myTime, lookUpAddress: 'time.google.com');
  ntpTime = _myTime.add(Duration(milliseconds: offset));

  setState(() {
    dateNow = DateFormat('yyyy-MM-dd').format(ntpTime);
    timeNow = DateFormat('HH:mm:ss').format(ntpTime);
  });

}

  @override
Widget build(BuildContext context) {
  String? formattedDate = dateNow;
  String? formattedTime = timeNow;
  String id = widget.user.showid();
 


  return LayoutBuilder(
    builder: (context, constraints) {
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text('$formattedDate'),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
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
            )
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              File(widget.picture.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              bottom: 50,
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Colors.white,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.001),
                  Text(
                    '$formattedTime',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.08,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          insertRecord(
                            File(widget.picture.path),
                            id,
                            widget.geo,
                            getAPI,
                            dateNow!+' '+timeNow!,
                            context,
                          );
                        },
                        color: Colors.white,
                      ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}
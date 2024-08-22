import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:checkin_rubv2/Utility/changepassword.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Utility/clearsession.dart';
import 'Utility/colors_font.dart';
import 'Utility/server_disconnect.dart';
import 'Utility/user_model.dart';
import 'api_request/api_function.dart';
import 'camerapage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:slide_digital_clock/slide_digital_clock.dart';

String apikey = dotenv.get("API_KEY", fallback: '');
String listapi = dotenv.get("API_HOST", fallback: '');

class Home_Page extends StatefulWidget {
  const Home_Page({Key? key, required this.user, this.fCMToken}) : super(key: key);
  final User user;
  final String? fCMToken;

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  DateTime loginTime = DateTime.now();
  bool isLoggedIn = false;
  double? lat, lng;
  late String id;
  late String token;
  late String? fcmToken;
  String showtime = '';
  static const platform = MethodChannel('getfCMTokeniOS');
  Position? _currentPosition; 
  double? targetLatitude;
  double? targetLongitude;
  int? radius;
  Timer? _timeruser;
  String? userId;
  String? userPw;

@override
void initState() {
  super.initState();
  id = widget.user.showid();
  token = widget.user.showapi();
  fcmToken = widget.user.showfcmtoken();
  if (Platform.isAndroid) { 
    FirebaseMessaging.instance.getToken().then((fCMTokenMyapp) {
    print('# AndroidfCM Token from Application => $fCMTokenMyapp');
    print('# fCMToken from Database => $fcmToken');
    _checkAndGrantFCMTokenAndroid();
  });
  } else if (Platform.isIOS) {
    _checkAndGrantFCMTokeniOS();
  }
  Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      DateTime currentTime = DateTime.now().subtract(const Duration(minutes: 1, seconds: 25));
      showtime = DateFormat('HH:mm:ss').format(currentTime);
    });
  });
  _getCurrentLocationAndCheckInArea();
  Timer.periodic(const Duration(seconds: 5), (timer) {
    setState(() {
       _getCurrentLocationAndCheckInArea();
    });
  });
  fetchDatalocation();
  _startTimer();
  loadRememberedCredentials();
}

  void _startTimer()  {
    _timeruser = Timer.periodic(const Duration(minutes: 15), (timer) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        text: 'เซสชั่นหมดอายุ...โปรดเข้าสู่ระบบใหม่',
        confirmBtnText: 'ตกลง',
        onConfirmBtnTap: () async {
          await clearSession(context, id, token);
        },
        barrierDismissible: false,
      );
    });
  }

  Future<void> fetchDatalocation() async {
    var uri = Uri.parse('$listapi/getradius');
    var headers = {'api-key': apikey};
    try {
      var response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        radius = data['radius'];
        targetLatitude = data['lat'];
        targetLongitude = data['long'];
        print('radius ==> $radius');
        print('lat ==> $targetLatitude');
        print('lng ==> $targetLongitude');
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _getCurrentLocationAndCheckInArea() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    if (_currentPosition == null ||
        _currentPosition!.latitude != position.latitude ||
        _currentPosition!.longitude != position.longitude) {
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
        print('# Current Location Updated #');
        print('Latitude ==> $lat');
        print('Longitude ==> $lng');
      });
      _currentPosition = position;
    } else {
      print('Location is the same. No update needed.');
    }
  }

  void _redirectBasedOnLocation() {
    genApikey();
    if (_currentPosition != null &&
        _isUserInCheckInArea(
          _currentPosition!.latitude,
          _currentPosition!.longitude)
        ) {
      _openCamera(context);
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'ไม่อยู่ในขอบเขต',
        text: 'ดูเหมือนท่านจะไม่อยู่ในเขตของโรงพยาบาลโปรดลองใหม่อีกครั้ง...',
      );
    }
  }

  void _openCamera(context) async {
    final cameras = await availableCameras();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraPage(
          cameras: cameras,
          user: widget.user,
        ),
      ),
    );
  }

  bool _isUserInCheckInArea(double latitude, double longitude) {
    if (targetLatitude == null || targetLongitude == null || radius == null) {
      return false;
    }
    final double distance = Geolocator.distanceBetween(
      latitude, longitude, targetLatitude!, targetLongitude!,
    );
    return distance <= radius!;
  }
   
  Future<void> _checkAndGrantFCMTokeniOS() async {
    String fCMTokenMyapp;
    final databasefCMToken = widget.user.showfcmtoken();
    try {
      final String result = await platform.invokeMethod('getFcmToken');
      fCMTokenMyapp = result;
      print(' iOS fCMToken from Application ==> $fCMTokenMyapp');
    } on PlatformException catch (e) {
      fCMTokenMyapp = "Failed to get FCM token iOS : ${e.message}";
    }
    print('### iOS fCMToken Form Database ==> $databasefCMToken');
    if (databasefCMToken == null || databasefCMToken != fCMTokenMyapp) {
      grantInsert(id, token, fCMTokenMyapp, context);
    } else {
      print('Cant\'t insert fCMToken\nOr fCMToken Database already exists #iOS');
    }
  }

  void _checkAndGrantFCMTokenAndroid() async {
    final fCMTokenMyapp = await FirebaseMessaging.instance.getToken();
    final databasefCMToken = widget.user.showfcmtoken();
    final String id = widget.user.showid();
    final String token = widget.user.showapi();
    if (databasefCMToken == null || databasefCMToken != fCMTokenMyapp) {
    grantInsert(id, token, fCMTokenMyapp ?? '', context);
    } else {
      print('Cant\'t insert fCMToken\nOr fCMToken Database already exists #Android');
    }
  }

  void _onHistoryButtonPressed(
      BuildContext context, String user_id, String api_token) {
    history(context, widget.user, user_id, api_token);
  }

  void _onShowLeavesButtonPressed(
      BuildContext context, String id, String api_token) {
    showleaves(context, widget.user, id, api_token);
  }

  void _showErrorDialog(context) {
    final localContext = context;
    showDialog(
      context: localContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: const Text('ไม่สามารถเปิดลิงก์ได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(localContext),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> loadRememberedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('remembered_user_id') ?? '';
      userPw = prefs.getString('remembered_user_pw') ?? '';
    });
  }

  void genApikey() async { 
    try {
      if (listapi.isEmpty) {
        disconnected();
        return;
      }
      var res = await http.post(Uri.parse('$listapi/login'), body: {
        "user": userId,
        "password": userPw,
      }, headers: {
        'api-key': apikey,
      });
      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        var user_data = response;
        if (user_data.containsKey('api_token')) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('api_token', user_data['api_token']);
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
          debugPrint('### 200 PreviewCamera status Code ==> ${res.statusCode}');
        }
      } else {
        debugPrint('### PreviewCamera status Code ==> ${res.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  Color _getStatusColor() {
    if (_isUserInCheckInArea(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0)) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Color _getStatusColorBtn() {
    if (_isUserInCheckInArea(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0)) {
      return primaryColor;
    } else {
      return Colors.grey;
    }
  }

  IconData? _getStatusIconLocation() { 
  if (_isUserInCheckInArea(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0)) {
    return Icons.location_on;
  } else {
    return Icons.location_off;
  }
  }

  @override
  void dispose() {
    _timeruser?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    String name = widget.user.showname();
    String id = widget.user.showid();
    String api_token = widget.user.showapi();
    String? line_token = widget.user.showlinetoken();
    String? position = widget.user.showposition();
    Color statusColor = _getStatusColor();
    Color statusColorBtn =  _getStatusColorBtn();
    IconData? statusIcon = _getStatusIconLocation();
    DateTime now = DateTime.now();
    var getyear = int.parse(DateFormat('yyyy').format(now)) + 543;
    String formattedDate = '${DateFormat('d MMMM').format(now)} $getyear';

    return LayoutBuilder(
    builder: (context, constraints) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: constraints.maxWidth > 600
                      ? MediaQuery.of(context).size.width * 0.06
                      : MediaQuery.of(context).size.width * 0.05,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 12,
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: constraints.maxWidth > 600
                      ? MediaQuery.of(context).size.width * 0.06
                      : MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          position ?? '',
                          style: TextStyle(
                            fontSize: constraints.maxWidth > 600
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width * 0.04,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: id,
                            style: TextStyle(
                            fontSize: constraints.maxWidth > 600
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width * 0.04,
                            color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),     
          ],
        ),
        leading: Align(
          alignment: Alignment.centerRight,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 35,
              color: primaryColor,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 35,
            ),
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'changepassword') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => changepassword(
                      user: widget.user,
                    ),
                  ),
                );
              }  else if (value == 'RevokeLine') {
                // TO DO
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'changepassword',
                  child: Text(
                    'เปลี่ยนรหัสผ่าน',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                if (line_token != '')
                  const PopupMenuItem<String>(
                    value: 'RevokeLine',
                    child: Text(
                      'ยกเลิกแจ้งเตือน',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ];
            },
            elevation: 4,
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Lottie.network(
              'https://lottie.host/4f614e8a-ba42-45ed-a9fc-9ae14377ce7c/wgnH5ObSSA.json',
              repeat: true,
              reverse: false,
              animate: true,
              fit: BoxFit.fill,
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: DigitalClock(
                        hourMinuteDigitTextStyle:
                          TextStyle(
                            fontSize: constraints.maxWidth > 600
                              ? MediaQuery.of(context).size.width * 0.08
                              : MediaQuery.of(context).size.width * 0.07,
                            color: Colors.white
                          ),
                        colon: Text(
                          ":",
                            style:TextStyle(
                            color: Colors.white, 
                            fontSize: constraints.maxWidth > 600
                              ? MediaQuery.of(context).size.width * 0.08
                              : MediaQuery.of(context).size.width * 0.07,
                            ),
                          ),
                        secondDigitTextStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(
                            color:Colors.white, 
                            fontSize: constraints.maxWidth > 600
                              ? MediaQuery.of(context).size.width * 0.06
                              : MediaQuery.of(context).size.width * 0.05,
                          ),
                      )
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        formattedDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: constraints.maxWidth > 600
                              ? MediaQuery.of(context).size.width * 0.09
                              : MediaQuery.of(context).size.width * 0.08,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(25),
                          color: statusColorBtn,
                          child: InkWell(
                            onTap: () {
                              if (statusColorBtn == Colors.red) {
                                Fluttertoast.showToast(
                                  msg: "ไม่พบตำแหน่งของคุณโปรดรอสักครู่",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP_LEFT,
                                  timeInSecForIosWeb: 15,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.red,
                                  fontSize: 16.0,
                                );
                              } else {
                                _redirectBasedOnLocation();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'เช็คอิน',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(25),
                          color: primaryColor,
                          child: InkWell(
                            onTap: () {
                              _onShowLeavesButtonPressed(
                                context,
                                id,
                                api_token,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.document_scanner,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'การลา',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  _onHistoryButtonPressed(
                    context,
                    id,
                    api_token,
                  );
                },
                color: Colors.white, 
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.confirm,
                    title: '',
                    text: 'คุณต้องการออกจากระบบ?',
                    confirmBtnText: 'ใช่',
                    cancelBtnText: 'ไม่',
                    confirmBtnColor: Colors.green,
                    onConfirmBtnTap: () async {
                      await clearSession(context, id, api_token);
                    }
                  );
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: line_token == ''
          ? FloatingActionButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Line Notify'),
                    content: const Text(
                        'ลงทะเบียบเพื่อรับการแจ้งเตือนผ่านไลน์ หากท่านลงทะเบียนสำเร็จแล้ว ให้กลับมายังแอพแล้ว ออกจากระบบแล้วเข้าสู่ระบบใหม่ด้วยครับ ขออภัยในความไม่สะดวก'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'ไม่ต้องการ',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final url =
                              'https://notify-bot.line.me/oauth/authorize?response_type=code&client_id=z8iYsbBHAlZQu9DaoMsjwr&redirect_uri=$listapi/line/auth&scope=notify&state=$api_token&response_mode=form_post';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          } else {
                            _showErrorDialog(context);
                          }
                        },
                        child: const Text(
                          'ลงทะเบียนรับแจ้งเตือน',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.info),
              tooltip: 'รับแจ้งเตือน',
            )
          : null,
          
        );
      },
    );
  }
}

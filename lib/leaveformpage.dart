// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'Utility/colors_font.dart';
import 'Utility/user_model.dart';
import 'api_request/api_function.dart';
import 'homepage.dart';

String listapi = dotenv.get("API_HOST", fallback: '');
String apikey = dotenv.get("API_KEY", fallback: '');

class leaveformpage extends StatefulWidget {
  const leaveformpage({Key? key,
  required this.user, 
  required this.userdata,
  }) : super(key: key);
  final User user;
  final Map<String, dynamic> userdata;

  @override
  State<leaveformpage> createState() => _leaveformpageState();
}

class _leaveformpageState extends State<leaveformpage> {
  String selectedLeaveType = 'โปรดเลือก';
  String? fromDate;
  String? toDate;
  String? note;
  String? selectedTime;
  int? selectedHour = TimeOfDay.now().hour;
  int? selectedMinute = TimeOfDay.now().minute;
  bool checkboxpersonal = false;
  bool checkboxsick = false;
  bool checkboxvacation = false;

  List<String> leaveTypes = [
    'โปรดเลือก',
    'ลากิจ',
    'ลาป่วย',
    'ลาพักร้อน',
  ];

  void _checkboxpersonal(bool? value) {
    if (value != null) {
      setState(() {
        checkboxpersonal = value;
      });
    }
  }

  void _checkboxsick(bool? value) {
    if (value != null) {
      setState(() {
        checkboxsick = value;
      });
    }
  }

  void _checkboxvacation(bool? value) {
    if (value != null) {
      setState(() {
        checkboxvacation = value;
      });
    }
  }

  String convertLeaveTypeTextToCode(String selectedLeaveType) {
    switch (selectedLeaveType) {
      case 'ลากิจ':
        return 'PL';
      case 'ลาป่วย':
        return 'SL';
      case 'ลาพักร้อน':
        return 'VL';
      default:
        return '';
    }
  }

  Future<void> insertRecord(
    String id,
    String name,
    String selectedLeaveType,
    String fromDate,
    String toDate,
    String note,
    String token,
    context,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$listapi/leaves/save/'),
    );
    request.headers['api-key'] = apikey;
    request.fields['user'] = id;
    request.fields['ltype'] = convertLeaveTypeTextToCode(selectedLeaveType);
    request.fields['start_date'] = fromDate;
    request.fields['end_date'] = toDate;
    request.fields['reason'] = note;
    request.fields['api_token'] = token;
    var response = await request.send();
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "ทำการส่งข้อมูล...เรียบร้อย",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_LEFT,
        timeInSecForIosWeb: 30,
        backgroundColor: Colors.red,
        textColor: Colors.green,
        fontSize: 16.0,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'เกิดข้อผิดพลาด',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เกิดบ้างสิ่งผิดปกติไม่สามารถส่งข้อมูลไปได้ โปรดติดต่อทีมงานด้วยครับ',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'ตกลง',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
            backgroundColor: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        },
      );
    }
  }

  void _showIncompleteDataDialog(List<String> emptyFields) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อมูลไม่ครบ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('โปรดกรอกข้อมูลให้ครบทุกช่อง'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: emptyFields.map((field) {
                  return Text('- $field');
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('กรุณาให้ความยินยอม'),
          content: const Text(
            'คุณต้องให้ความยินยอมเพื่อส่งคำขอลานี้หรือคุณไม่ยินยอมกรุณาติดต่อฝ่ายบุคคลด้วยครับ',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDialog() {
    String id = widget.user.showid();
    String name = widget.user.showname();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'ข้อมูลที่ท่านได้กรอกโปรดตรวจสอบก่อนส่ง',
            style: TextStyle(fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ชื่อของท่าน: $name'),
              Text('รหัสพนักงาน: $id'),
              Text('ต้องการลา: $selectedLeaveType'),
              Text('จากวันที่: $fromDate'),
              Text('วันที่สิ้นสุด: $toDate'),
              Text('หมายเหตุ: $note'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sendDatatoServer();
              },
              child: const Text(
                'ต้องการส่งข้อมูล',
                style: TextStyle(color: Colors.green),
              ),
            )
          ],
        );
      },
    );
  }

  void _onShowLeavesButtonPressed(context, String id, String api_token) {
    showleaves(context, widget.user, id, api_token);
  }

  void sendDatatoServer() async {
    String id = widget.user.showid();
    String name = widget.user.showname();
    String token = widget.user.showapi();
    await insertRecord(
      id,
      name,
      selectedLeaveType,
      fromDate!,
      toDate!,
      note!,
      token,
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    String id = widget.user.showid();
    String apitoken = widget.user.showapi();
    Map<String, dynamic> userdata = widget.userdata['info'];
    String pl = userdata['PL'];
    String sl = userdata['SL'];
    String vl = userdata['VL'];
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('หน้าการขอลา'),
          backgroundColor: primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onShowLeavesButtonPressed(context, id, apitoken);
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
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: screenHeight - appBarHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'ชนิดการลา',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedLeaveType,
                    onChanged: (newValue) {
                      setState(() {
                        selectedLeaveType = newValue!;
                        if (selectedLeaveType == 'ลาครึ่งวัน') {
                          selectedTime = null;
                        }
                      });
                    },
                    items: leaveTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'จากวันที่',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
                          context: context,
                          builder: ( context) {
                            return AlertDialog(
                              title: const Text('โปรดเลือกช่วงเวลาที่ต้องการลา'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatefulBuilder(
                                    builder: (BuildContext context,
                                      StateSetter setState) {
                                      return ListTile(
                                        title: const Text('ช่วงเวลา'),
                                        trailing: DropdownButton<int>(
                                          value: selectedHour,
                                          items: List.generate(24, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index,
                                              child: Text('$index'),
                                            );
                                          }),
                                          onChanged: (int? value) {
                                            setState(() {
                                              selectedHour = value;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    selectedMinute = 0;
                                    if (selectedHour != null) {
                                      Navigator.pop(
                                        context,
                                        TimeOfDay(
                                          hour: selectedHour!,
                                          minute: selectedMinute!,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('ยืนยัน'),
                                ),
                              ],
                            );
                          },
                        );
                        if (selectedTime != null) {
                          DateTime combinedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          setState(() {
                            fromDate = DateFormat('yyyy-MM-dd HH:mm')
                                .format(combinedDateTime);
                          });
                        }
                      }
                    },
                    controller: TextEditingController(text: fromDate),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'ถึงวันที่',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () async {
                      DateTime selectedFromDate =
                          DateFormat('yyyy-MM-dd HH:mm').parse(fromDate!);
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedFromDate,
                        firstDate: selectedFromDate,
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        TimeOfDay? selectedTime = await showDialog<TimeOfDay>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('โปรดเลือกช่วงเวลาที่ต้องการลา'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StatefulBuilder(
                                    builder: (BuildContext context,
                                      StateSetter setState) {
                                      return ListTile(
                                        title: const Text('ช่วงเวลา'),
                                        trailing: DropdownButton<int>(
                                          value: selectedHour,
                                          items: List.generate(24, (index) {
                                            return DropdownMenuItem<int>(
                                              value: index,
                                              child: Text('$index'),
                                            );
                                          }),
                                          onChanged: (int? value) {
                                            setState(() {
                                              selectedHour = value;
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    selectedMinute = 0;
                                    if (selectedHour != null) {
                                      Navigator.pop(context,
                                      TimeOfDay(
                                        hour: selectedHour!,
                                        minute: selectedMinute!
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('ยืนยัน'),
                                ),
                              ],
                            );
                          },
                        );
                        if (selectedTime != null) {
                          DateTime combinedDateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          setState(() {
                            toDate = DateFormat('yyyy-MM-dd HH:mm')
                                .format(combinedDateTime);
                          });
                        }
                      }
                    },
                    controller: TextEditingController(text: toDate),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'หมายเหตุ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        note = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (selectedLeaveType == 'ลากิจ' && pl == '0')
                        Row(
                          children: [
                            Checkbox(
                              value: checkboxpersonal,
                              onChanged: _checkboxpersonal,
                            ),
                            const Text('ยินยอม(กรณีลากิจหมด)',
                              style:
                                TextStyle(color: Colors.black, fontSize: 17),
                            ),
                          ],
                        ),
                      if (selectedLeaveType == 'ลาป่วย' && sl == '0')
                        Row(
                          children: [
                            Checkbox(
                              value: checkboxsick,
                              onChanged: _checkboxsick,
                            ),
                            const Text(
                              'ยินยอม(กรณีลาป่วยหมด)',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17),
                            ),
                          ],
                        ),
                      if (selectedLeaveType == 'ลาพักร้อน' && vl == '0')
                        Row(
                          children: [
                            Checkbox(
                              value: checkboxvacation,
                              onChanged: _checkboxvacation,
                            ),
                            const Text(
                              'ยินยอม(กรณีลาพักร้อนหมด)',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30.0),
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    List<String> emptyFields = [];
                    if (selectedLeaveType == 'โปรดเลือก') {
                      emptyFields.add('ชนิดการลา');
                    }
                    if (fromDate == null) {
                      emptyFields.add('จากวันที่');
                    }
                    if (toDate == null) {
                      emptyFields.add('วันที่สิ้นสุด');
                    }
                    if (note == null) {
                      emptyFields.add('หมายเหตุ');
                    }
                    if (emptyFields.isNotEmpty) {
                      _showIncompleteDataDialog(emptyFields);
                    } else if (
                      (selectedLeaveType == 'ลากิจ' && pl == '0' && !checkboxpersonal) ||
                      (selectedLeaveType == 'ลาป่วย' && sl == '0' && !checkboxsick) ||
                      (selectedLeaveType == 'ลาพักร้อน' && vl == '0' && !checkboxvacation)
                    ) {
                      _showPermissionDialog();
                    } else {
                      _showConfirmDialog();
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(
                      Size(MediaQuery.of(context).size.width * 0.75, 50),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      primaryColor,
                    ),
                  ),
                  child: const Text(
                    'ส่งข้อมูล',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

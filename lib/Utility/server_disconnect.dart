import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void disconnected() {
  Fluttertoast.showToast(
    msg: "ไม่สามารถเชื่อมต่อกับ SERVER ได้",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.TOP_LEFT,
    timeInSecForIosWeb: 10,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

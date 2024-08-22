import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Mydialog {
  Future<void> alertLocationService(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const ListTile(
          title: Text("Your Location Service Close!"),
          subtitle: Text("Please Turn on Your Location Service"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}

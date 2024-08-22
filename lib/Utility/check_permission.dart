import 'package:geolocator/geolocator.dart';
import 'my_dialog.dart';

class PermissionUtil {
  static Future<void> checkPermission(context) async {
    bool localService;
    LocationPermission locationPermission;
    localService = await Geolocator.isLocationServiceEnabled();
    if (localService) {
      locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.deniedForever) {
          Mydialog().alertLocationService(context);
        } else {}
      } else {
        if (locationPermission == LocationPermission.deniedForever) {
          Mydialog().alertLocationService(context);
        } else {}
      }
    } else {
      Mydialog().alertLocationService(context);
    }
  }
}

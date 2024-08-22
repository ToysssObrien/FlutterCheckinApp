class User {
  final String id;
  final String name;
  final String depid;
  String? profile_photo_url;
  final String api_token;
  String linetoken;
  int? userlv;
  String? fcm;
  String? position;

  User({
    required this.id,
    required this.name,
    required this.api_token,
    required this.depid,
    required this.linetoken,
    required this.fcm,
    required this.position,
  });

  String showid() {
    return id;
  }


  String showname() {
    return name.toUpperCase();
  }

  String showdepid() {
    return depid;
  }

  String? showprofile() {
    return profile_photo_url;
  }

  String showapi() {
    return api_token;
  }

  String showlinetoken() {
    return linetoken;
  }

  String? showfcmtoken() {
    return fcm;
  }

  String? showposition() {
    return position;
  }

  void setprofileimg(img) {
    profile_photo_url = img;
  }
}

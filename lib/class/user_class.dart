class UserClass {
  String? error;
  String? message;
  String? userID;
  String? mobileNo;
  String? otp;
  String? name;
  String? lastLogin;
  String? active;

  UserClass(
      {this.error,
      this.message,
      this.userID,
      this.mobileNo,
      this.otp,
      this.name,
      this.lastLogin,
      this.active});

  UserClass.fromJson(Map<String, dynamic> json) {
    error = json['error'].toString();
    message = json['message'].toString();
    userID = json['userID'].toString();
    mobileNo = json['mobileNo'].toString();
    otp = json['otp'].toString();
    name = json['name'].toString();
    lastLogin = json['lastLogin'].toString();
    active = json['active'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['userID'] = userID;
    data['mobileNo'] = mobileNo;
    data['otp'] = otp;
    data['name'] = name;
    data['lastLogin'] = lastLogin;
    data['active'] = active;
    return data;
  }
}

class UserClass {
  bool? error;
  String? message;
  int? userID;
  int? mobileNo;
  int? otp;
  String? name;
  String? lastLogin;
  bool? active;

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
    error = json['error'];
    message = json['message'];
    userID = json['userID'];
    mobileNo = json['mobileNo'];
    otp = json['otp'];
    name = json['name'];
    lastLogin = json['lastLogin'];
    active = json['active'];
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

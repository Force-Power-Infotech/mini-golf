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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    data['userID'] = this.userID;
    data['mobileNo'] = this.mobileNo;
    data['otp'] = this.otp;
    data['name'] = this.name;
    data['lastLogin'] = this.lastLogin;
    data['active'] = this.active;
    return data;
  }
}

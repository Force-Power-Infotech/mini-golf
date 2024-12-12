class TeamClass {
  bool? error;
  String? message;
  int? teamId;
  String? createdBy;
  List<Members>? members;
  String? createDateTime;

  TeamClass(
      {this.error,
      this.message,
      this.teamId,
      this.createdBy,
      this.members,
      this.createDateTime});

  TeamClass.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    teamId = json['teamId'];
    createdBy = json['createdBy'];
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(new Members.fromJson(v));
      });
    }
    createDateTime = json['createDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    data['teamId'] = this.teamId;
    data['createdBy'] = this.createdBy;
    if (this.members != null) {
      data['members'] = this.members!.map((v) => v.toJson()).toList();
    }
    data['createDateTime'] = this.createDateTime;
    return data;
  }
}

class Members {
  int? userID;
  String? userName;

  Members({this.userID, this.userName});

  Members.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['userName'] = this.userName;
    return data;
  }
}

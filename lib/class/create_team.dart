class TeamClass {
  String? error;
  String? message;
  String? teamId;
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
    error = json['error'].toString();
    message = json['message'].toString();
    teamId = json['teamId'].toString();
    createdBy = json['createdBy'].toString();
    if (json['members'] != null) {
      members = <Members>[];
      json['members'].forEach((v) {
        members!.add(Members.fromJson(v));
      });
    }
    createDateTime = json['createDateTime'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['teamId'] = teamId;
    data['createdBy'] = createdBy;
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    data['createDateTime'] = createDateTime;
    return data;
  }
}

class Members {
  String? userID;
  String? userName;

  Members({this.userID, this.userName});

  Members.fromJson(Map<String, dynamic> json) {
    userID = json['userID'].toString();
    userName = json['userName'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['userName'] = userName;
    return data;
  }
}

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) =>
    json.encode(data.toJson());

class LoginModel {
  bool? status;
  String? message;
  Login? data;

  LoginModel({
     this.status,
     this.message,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        status: json["status"],
        message: json["message"],
        data: (json["data"] is Map<String, dynamic> && json["data"].isNotEmpty)
            ? Login.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}


class Login {
   String? id;
   String? internalId;
   String? employeeId;
   String? employeeName;
   String? email;
   String? supervisorId;
   String? supervisor;
   String? password;
   String? active;
   String? emptype;
   String? updatedAt;
   int? v;

  Login({
     this.id,
     this.internalId,
     this.employeeId,
     this.employeeName,
     this.email,
     this.supervisorId,
     this.supervisor,
     this.password,
     this.active,
     this.emptype,
     this.updatedAt,
     this.v,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['_id'] ?? '',
      internalId: json['internalId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      email: json['email'] ?? '',
      supervisorId: json['supervisorId'] ?? '',
      supervisor: json['supervisor'] ?? '',
      password: json['password'] ?? '',
      active: json['active'] ?? '',
      emptype: json['emptype'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'internalId': internalId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'email': email,
      'supervisorId': supervisorId,
      'supervisor': supervisor,
      'password': password,
      'active': active,
      'emptype': emptype,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
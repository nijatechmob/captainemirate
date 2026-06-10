import 'dart:convert';

AddTimesheetModel addTimesheetModelFromJson(String str) =>
    AddTimesheetModel.fromJson(json.decode(str));

String addTimesheetModelToJson(AddTimesheetModel data) =>
    json.encode(data.toJson());

class AddTimesheetModel {
  bool? status;
  String? message;
  int? internalId;

  AddTimesheetModel({
    this.status,
    this.message,
    this.internalId,
  });

  factory AddTimesheetModel.fromJson(Map<String, dynamic> json) {
    return AddTimesheetModel(
      status: json["status"],
      message: json["message"],
      internalId: json["internalId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "internalId": internalId,
    };
  }
}
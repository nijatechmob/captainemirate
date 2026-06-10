


import 'dart:convert';

AddRegularizationModel addRegularizationModelFromJson(String str) =>
    AddRegularizationModel.fromJson(json.decode(str));

String addRegularizationModelToJson(AddRegularizationModel data) =>
    json.encode(data.toJson());

class AddRegularizationModel {
  bool status;
  String message;

  AddRegularizationModel({
    required this.status,
    required this.message,
  });

  factory AddRegularizationModel.fromJson(Map<String, dynamic> json) =>
      AddRegularizationModel(
        status: json["status"] ?? false,
        message: json["message"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

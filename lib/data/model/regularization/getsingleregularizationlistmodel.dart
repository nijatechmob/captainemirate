import 'dart:convert';

GetsingleregularizationlistModel getsingleregularizationlistModelFromJson(String str) =>
    GetsingleregularizationlistModel.fromJson(json.decode(str));

String getsingleregularizationlistModelToJson(GetsingleregularizationlistModel data) =>
    json.encode(data.toJson());

class GetsingleregularizationlistModel {
  bool status;
  String message;
  List<RegularizationItem> data;

  GetsingleregularizationlistModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetsingleregularizationlistModel.fromJson(Map<String, dynamic> json) {
    return GetsingleregularizationlistModel(
      status: json["status"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] == null
          ? []
          : List<RegularizationItem>.from(
              json["data"].map((x) => RegularizationItem.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data.map((x) => x.toJson()).toList(),
    };
  }
}

class RegularizationItem {
  String? id;
  int? internalId;
  int? timesheetRef;
  String? attendanceDate;
  String? subsidiary;
  String? employeeType;
  String? section;
  String? employee;
  String? designation;
  String? department;
  int? salesOrder;
  String? timeIn;
  String? timeOut;
  String? hoursWorked;
  String? otApplicable;
  String? otHours;
  String?attendanceStatus;
  String? shiftMaster;
  String? notes;
  String? createdAt;
  String? updatedAt;
  int? v;

  RegularizationItem({
     this.id,
     this.internalId,
     this.timesheetRef,
     this.attendanceDate,
     this.subsidiary,
     this.employeeType,
     this.section,
     this.employee,
     this.designation,
     this.department,
     this.salesOrder,
     this.timeIn,
     this.timeOut,
     this.hoursWorked,
     this.otApplicable,
     this.otHours,
     this.attendanceStatus,
     this.shiftMaster,
     this.notes,
     this.createdAt,
     this.updatedAt,
     this.v,
  });

  factory RegularizationItem.fromJson(Map<String, dynamic> json) {
    return RegularizationItem(
      id: json["_id"] ?? "",
      internalId: json["internalId"] ?? 0,
      timesheetRef: json["timesheetRef"] ?? 0,
      attendanceDate: json["attendanceDate"] ?? "",
      subsidiary: json["subsidiary"] ?? "",
      employeeType: json["employeeType"] ?? "",
      section: json["section"] ?? "",
      employee: json["employee"] ?? "",
      designation: json["designation"] ?? "",
      department: json["department"] ?? "",
      salesOrder: json["salesOrder"] ?? 0,
      timeIn: json["timeIn"] ?? "",
      timeOut: json["timeOut"] ?? "",
      hoursWorked: json["hoursWorked"] ?? "",
      otApplicable: json["otApplicable"] ?? "",
      otHours: json["otHours"] ?? "",
      attendanceStatus: json["attendanceStatus"] ?? "",
      shiftMaster: json["shiftMaster"] ?? "",
      notes: json["notes"] ?? "",
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "internalId": internalId,
      "timesheetRef": timesheetRef,
      "attendanceDate": attendanceDate,
      "subsidiary": subsidiary,
      "employeeType": employeeType,
      "section": section,
      "employee": employee,
      "designation": designation,
      "department": department,
      "salesOrder": salesOrder,
      "timeIn": timeIn,
      "timeOut": timeOut,
      "hoursWorked": hoursWorked,
      "otApplicable": otApplicable,
      "otHours": otHours,
      "attendanceStatus": attendanceStatus,
      "shiftMaster": shiftMaster,
      "notes": notes,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
    };
  }
}
// class Notice {
//   final String id;
//   final String noticeTypeId;
//   final String noticeTypeName;
//   final bool status;
//
//   Notice({
//     required this.id,
//     required this.noticeTypeId,
//     required this.noticeTypeName,
//     required this.status,
//   });
//
//   // Factory constructor to create a Notice from JSON
//   factory Notice.fromJson(Map<String, dynamic> json) {
//     return Notice(
//       id: json['_id'] as String,
//       noticeTypeId: json['noticeTypeId'] as String,
//       noticeTypeName: json['noticeTypeName'] as String,
//       status: json['status'] as bool,
//     );
//   }
// }
//
// class ClientMapping {
//   final String id;
//   final Notice notice;
//
//   ClientMapping({
//     required this.id,
//     required this.notice,
//   });
//
//   // Factory constructor to create a ClientMapping from JSON
//   factory ClientMapping.fromJson(Map<String, dynamic> json) {
//     return ClientMapping(
//       id: json['_id'] as String,
//       notice: Notice.fromJson(json['notice'] as Map<String, dynamic>),
//     );
//   }
// }
class FilescreenModel {
  final String id;
  final String noticeTypeId;
  final String noticeTypeName;
  final bool status;

  FilescreenModel({
    required this.id,
    required this.noticeTypeId,
    required this.noticeTypeName,
    required this.status,
  });

  factory FilescreenModel.fromJson(Map<String, dynamic> json) {
    return FilescreenModel(
      id: json['_id'] as String,
      noticeTypeId: json['noticeTypeId'] as String,
      noticeTypeName: json['noticeTypeName'] as String,
      status: json['status'] as bool,
    );
  }
}

class ClientMappingModel {
  final String id;
  final FilescreenModel notice;

  ClientMappingModel({
    required this.id,
    required this.notice,
  });


  factory ClientMappingModel.fromJson(Map<String, dynamic> json) {
    return ClientMappingModel(
      id: json['_id'] as String,
      notice: FilescreenModel.fromJson(json['notice'] as Map<String, dynamic>),
    );
  }
}


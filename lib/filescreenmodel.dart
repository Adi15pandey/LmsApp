
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


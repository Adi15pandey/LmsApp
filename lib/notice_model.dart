class NoticeModel {
  final String id;
  final int? index;
  final String noticeTypeName;
  final DateTime createdAt;
  final String filename;

  // Constructor
  NoticeModel({
    required this.id,
    required this.index,
    required this.noticeTypeName,
    required this.createdAt,
    required this.filename,
  });


  factory NoticeModel.fromJson(Map<String, dynamic> json) {

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['createdAt'] ?? '1970-01-01T00:00:00Z');
    } catch (e) {
      parsedDate = DateTime.parse('1970-01-01T00:00:00Z');
    }

    return NoticeModel(
      id: json['_id'] ?? '',
      index: json['index'] != null ? json['index'] as int : null,
      noticeTypeName: json['notice']?['notice']?['noticeTypeName'] ?? '',
      createdAt: parsedDate,
      filename: json['filename'] ?? '',  // Default to empty string if null
    );
  }

  Map<String ,dynamic> toJson() {
    return {
      'index': index,  // `index` can be null now
      'noticeTypeName': noticeTypeName,
      'createdAt': createdAt.toIso8601String(),
      'filename': filename,
      'id': id,
    };
  }
}

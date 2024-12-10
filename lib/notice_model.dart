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

  // Factory method to create a NoticeModel from JSON
  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    // Safely handle potential null and invalid date parsing
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['createdAt'] ?? '1970-01-01T00:00:00Z');
    } catch (e) {
      parsedDate = DateTime.parse('1970-01-01T00:00:00Z');  // Fallback to epoch date if parsing fails
    }

    return NoticeModel(
      id: json['_id'] ?? '',  // Ensure the ID is never null
      index: json['index'] != null ? json['index'] as int : null,
      noticeTypeName: json['notice']?['notice']?['noticeTypeName'] ?? '',  // Handle nested nullable fields
      createdAt: parsedDate,
      filename: json['filename'] ?? '',  // Default to empty string if null
    );
  }

  // Method to convert NoticeModel to JSON (for sending data to API)
  Map<String, dynamic> toJson() {
    return {
      'index': index,  // `index` can be null now
      'noticeTypeName': noticeTypeName,
      'createdAt': createdAt.toIso8601String(),
      'filename': filename,
      'id': id,
    };
  }
}

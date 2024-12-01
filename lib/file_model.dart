class Notice {
  final String id;
  final String smsStatus;
  final String notificationType;
  final String whatsappStatus;
  final String processIndiaPost;
  final String shortURL;
  final NoticeID noticeID;
  final Data data;
  final  String date;

  Notice({
    required this.date,
    required this.shortURL,
    required this.processIndiaPost,
    required this.notificationType,
    required this.smsStatus,
    required this.whatsappStatus,
    required this.id,
    required this.noticeID,
    required this.data,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['_id'] ?? '', // Default to an empty string if null
      shortURL : json['shortURL'] ?? '',
      date:json['date']?? '',
      whatsappStatus: json['whatsappStatus'] ?? '', // Default to an empty string if null
      smsStatus: json['smsStatus'] ?? '', // Default to an empty string if null
      notificationType: json['notificationType'] ?? '', // Default to an empty string if null
      processIndiaPost: json['processIndiaPost'] ?? '', // Default to an empty string if null
      noticeID: NoticeID.fromJson(json['NoticeID'] ?? {}), // Empty object if null
      data: Data.fromJson(json['data'] ?? {}), // Empty object if null
    );
  }
}

class NoticeID {
  final String filename;
  final String user;

  NoticeID({
    required this.filename,
    required this.user,
  });

  factory NoticeID.fromJson(Map<String, dynamic> json) {
    return NoticeID(
      filename: json['filename'] ?? '', // Default to an empty string if null
      user: json['user'] ?? '', // Default to an empty string if null
    );
  }
}

class Data {
  final int account;
  final String date;
  final String email;
  final int mobileNumber;
  final String name;

  Data({
    required this.account,
    required this.date,
    required this.email,
    required this.mobileNumber,
    required this.name,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      account: json['account'] ?? 0, // Default to 0 if null
      date: json['date'] ?? '', // Default to an empty string if null
      email: json['email'] ?? '', // Default to an empty string if null
      mobileNumber: json['mobilenumber'] ?? 0, // Default to 0 if null
      name: json['name'] ?? '', // Default to an empty string if null
    );
  }
}

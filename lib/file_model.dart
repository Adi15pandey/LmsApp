import 'package:intl/intl.dart';

class Notice {
  final String id;
  final String smsStatus;
  final String notificationType;
  final String whatsappStatus;
  final String processIndiaPost;
  final String shortURL;
  final NoticeID noticeID;
  final Data data;
  final String date;

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
      id: json['_id'] ?? '',
      shortURL: json['shortURL'] ?? '',
      date: _parseDate(json['date']),
      whatsappStatus: json['whatsappStatus'] ?? '',
      smsStatus: json['smsStatus'] ?? '',
      notificationType: json['notificationType'] ?? '',
      processIndiaPost: json['processIndiaPost'] ?? '',
      noticeID: NoticeID.fromJson(json['NoticeID'] ?? {}),
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  // Helper function to parse the date
  static String _parseDate(dynamic dateJson) {
    if (dateJson == null) {
      return '';
    }

    if (dateJson is String) {
      return dateJson; // If it's a string, return it as is
    }

    if (dateJson is int) {
      // If it's a timestamp, convert to DateTime and format it
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateJson);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }

    return ''; // Default to empty string if neither string nor int
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
      filename: json['filename'] ?? '',
      user: json['user'] ?? '',
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
      account: int.tryParse(json['account'].toString()) ?? 0,
      date: _parseDate(json['date']),
      email: json['email'] ?? '',
      mobileNumber: _parseMobileNumber(json['mobilenumber']),
      name: json['name'] ?? '',
    );
  }


  static int _parseMobileNumber(dynamic mobileNumberJson) {
    if (mobileNumberJson == null) {
      return 0;
    }
    if (mobileNumberJson is String) {

      return int.tryParse(mobileNumberJson) ?? 0;  // Return 0 if parsing fails
    }
    if (mobileNumberJson is int) {
      return mobileNumberJson;
    }
    return 0;
  }

  // Helper function to parse the date
  static String _parseDate(dynamic dateJson) {
    if (dateJson == null) {
      return '';
    }

    if (dateJson is String) {
      return dateJson;
    }

    if (dateJson is int) {

      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateJson);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }

    return '';
  }
}

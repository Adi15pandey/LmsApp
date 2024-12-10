import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NoticeType {
  final String id;
  final Notice notice;

  NoticeType({required this.id, required this.notice});

  factory NoticeType.fromJson(Map<String, dynamic> json) {
    return NoticeType(
      id: json['_id'],
      notice: Notice.fromJson(json['notice']),
    );
  }
}

class Notice {
  final String id;
  final String noticeTypeId;
  final String noticeTypeName;
  final bool status;

  Notice({
    required this.id,
    required this.noticeTypeId,
    required this.noticeTypeName,
    required this.status,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['_id'],
      noticeTypeId: json['noticeTypeId'],
      noticeTypeName: json['noticeTypeName'],
      status: json['status'],
    );
  }
}




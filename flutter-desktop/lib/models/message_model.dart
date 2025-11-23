import 'package:flutter_getx_app/models/student.dart';

class MessageModel {
  final String id;
  final List<Student> studentIds;
  final String subject;
  final String messageBody;
  final List<String> fileUrls;
  final String examination;
  final String from;
  final DateTime? dateTime;
  final String? status;

  MessageModel({
    required this.id,
    required this.studentIds,
    required this.subject,
    required this.messageBody,
    required this.fileUrls,
    required this.examination,
    required this.from,
    this.dateTime,
    this.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      studentIds: (json['studentIds'] as List)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
      subject: json['subject'] ?? '',
      messageBody: json['messageBody'] ?? '',
      fileUrls: List<String>.from(json['fileUrls'] ?? []),
      examination: json['examination'] ?? '',
      from: json['from'] ?? 'School Admin',
      status: json['status'],
      dateTime:
          json['dateTime'] != null ? DateTime.parse(json['dateTime']) : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentIds': studentIds.map((e) => e.toJson()).toList(),
      'subject': subject,
      'messageBody': messageBody,
      'fileUrls': fileUrls,
      'examination': examination,
      'from': from,
      'dateTime': dateTime?.toIso8601String(),
      'status': status,
    };
  }
}

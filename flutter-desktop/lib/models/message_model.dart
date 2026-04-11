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
  final bool read;
  final String? senderName;
  final String? senderEmail;
  final String? patientName;
  final String? category;
  final String? doctorName;
  final String? clinicAddress;
  final bool hasAttachments;
  final int attachmentCount;
  final List<String> attachments;
  final String? studentClass;
  final String? studentGrade;
  final DateTime? createdAt;
  final String? recordId;

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
    this.read = false,
    this.senderName,
    this.senderEmail,
    this.patientName,
    this.category,
    this.doctorName,
    this.clinicAddress,
    this.hasAttachments = false,
    this.attachmentCount = 0,
    this.attachments = const [],
    this.studentClass,
    this.studentGrade,
    this.createdAt,
    this.recordId,
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

  /// Parse from the /api/messages/medical-records API response
  factory MessageModel.fromApiRecord(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    final recordData = json['recordData'] as Map<String, dynamic>? ?? {};

    return MessageModel(
      id: json['id'] ?? '',
      studentIds: [],
      subject: json['subject'] ?? '',
      messageBody: json['body'] ?? '',
      fileUrls: [],
      examination: recordData['category'] ?? '',
      from: sender['name'] ?? '',
      senderName: sender['name'],
      senderEmail: sender['email'],
      patientName: recordData['patientName'],
      category: recordData['category'],
      doctorName: recordData['doctorName'],
      clinicAddress: recordData['clinicAddress'],
      hasAttachments: recordData['hasAttachments'] ?? false,
      attachmentCount: recordData['attachmentCount'] ?? 0,
      attachments: List<String>.from(recordData['attachments'] ?? []),
      studentClass: recordData['studentClass'],
      studentGrade: recordData['studentGrade'],
      recordId: recordData['recordId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      status: json['status'],
      read: json['read'] ?? false,
      dateTime: recordData['date'] != null
          ? DateTime.tryParse(recordData['date'])
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null),
    );
  }

  MessageModel copyWith({
    String? id,
    List<Student>? studentIds,
    String? subject,
    String? messageBody,
    List<String>? fileUrls,
    String? examination,
    String? from,
    DateTime? dateTime,
    String? status,
    bool? read,
    String? senderName,
    String? senderEmail,
    String? patientName,
    String? category,
    String? doctorName,
    String? clinicAddress,
    bool? hasAttachments,
    int? attachmentCount,
    List<String>? attachments,
    String? studentClass,
    String? studentGrade,
    DateTime? createdAt,
    String? recordId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      studentIds: studentIds ?? this.studentIds,
      subject: subject ?? this.subject,
      messageBody: messageBody ?? this.messageBody,
      fileUrls: fileUrls ?? this.fileUrls,
      examination: examination ?? this.examination,
      from: from ?? this.from,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      read: read ?? this.read,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      patientName: patientName ?? this.patientName,
      category: category ?? this.category,
      doctorName: doctorName ?? this.doctorName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      attachments: attachments ?? this.attachments,
      studentClass: studentClass ?? this.studentClass,
      studentGrade: studentGrade ?? this.studentGrade,
      createdAt: createdAt ?? this.createdAt,
      recordId: recordId ?? this.recordId,
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

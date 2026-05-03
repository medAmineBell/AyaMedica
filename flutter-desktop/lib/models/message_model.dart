import 'package:flutter_getx_app/models/student.dart';

class MessageAttachment {
  final String url;
  final String? filename;
  final String? contentType;

  const MessageAttachment({
    required this.url,
    this.filename,
    this.contentType,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      url: (json['url'] ?? '').toString(),
      filename: json['filename']?.toString(),
      contentType: json['contentType']?.toString(),
    );
  }

  bool get isImage {
    final ct = (contentType ?? '').toLowerCase();
    if (ct.startsWith('image/')) return true;
    final name = (filename ?? url).toLowerCase();
    return ['.png', '.jpg', '.jpeg', '.gif', '.webp']
        .any((e) => name.endsWith(e));
  }
}

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
  final List<MessageAttachment> messageAttachments;
  final String? studentClass;
  final String? studentGrade;
  final DateTime? createdAt;
  final String? recordId;
  final String? messageType;
  final int? replyCount;
  final String? relatedAppointmentId;
  final String? relatedPatientId;
  final String? studentPhoto;
  final String? studentAid;
  final String? destinationType;
  final String? destinationLabel;
  final String? branchName;

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
    this.messageAttachments = const [],
    this.studentClass,
    this.studentGrade,
    this.createdAt,
    this.recordId,
    this.messageType,
    this.replyCount,
    this.relatedAppointmentId,
    this.relatedPatientId,
    this.studentPhoto,
    this.studentAid,
    this.destinationType,
    this.destinationLabel,
    this.branchName,
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

  /// Parse from the /api/messages?type=inbox|sent API response
  factory MessageModel.fromInboxApi(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    final requestData = json['requestData'] as Map<String, dynamic>? ?? {};
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null;

    final firstName = (requestData['firstName'] ?? '').toString();
    final lastName = (requestData['lastName'] ?? '').toString();
    final studentName = [firstName, lastName]
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();

    final rawAttachments = (data['attachments'] as List?) ?? const [];
    final parsedAttachments = rawAttachments
        .whereType<Map<String, dynamic>>()
        .map(MessageAttachment.fromJson)
        .where((a) => a.url.isNotEmpty)
        .toList();

    return MessageModel(
      id: json['id'] ?? '',
      studentIds: const [],
      subject: json['subject'] ?? '',
      messageBody: json['body'] ?? '',
      fileUrls: const [],
      examination: '',
      from: sender['name'] ?? '',
      senderName: sender['name'],
      senderEmail: sender['email'],
      status: json['status'],
      read: json['read'] ?? false,
      createdAt: createdAt,
      dateTime: createdAt,
      messageType: json['messageType'],
      replyCount: json['replyCount'],
      relatedAppointmentId: json['relatedAppointmentId'],
      relatedPatientId: json['relatedPatientId'],
      patientName: studentName.isEmpty ? null : studentName,
      studentGrade: requestData['grade']?.toString(),
      studentClass: requestData['class']?.toString(),
      studentPhoto: requestData['photo']?.toString(),
      studentAid: requestData['studentAid']?.toString(),
      destinationType: requestData['destinationType']?.toString(),
      destinationLabel: requestData['destinationLabel']?.toString(),
      branchName: requestData['branchName']?.toString(),
      messageAttachments: parsedAttachments,
      hasAttachments: parsedAttachments.isNotEmpty,
      attachmentCount: parsedAttachments.length,
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
    List<MessageAttachment>? messageAttachments,
    String? studentClass,
    String? studentGrade,
    DateTime? createdAt,
    String? recordId,
    String? messageType,
    int? replyCount,
    String? relatedAppointmentId,
    String? relatedPatientId,
    String? studentPhoto,
    String? studentAid,
    String? destinationType,
    String? destinationLabel,
    String? branchName,
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
      messageAttachments: messageAttachments ?? this.messageAttachments,
      studentClass: studentClass ?? this.studentClass,
      studentGrade: studentGrade ?? this.studentGrade,
      createdAt: createdAt ?? this.createdAt,
      recordId: recordId ?? this.recordId,
      messageType: messageType ?? this.messageType,
      replyCount: replyCount ?? this.replyCount,
      relatedAppointmentId: relatedAppointmentId ?? this.relatedAppointmentId,
      relatedPatientId: relatedPatientId ?? this.relatedPatientId,
      studentPhoto: studentPhoto ?? this.studentPhoto,
      studentAid: studentAid ?? this.studentAid,
      destinationType: destinationType ?? this.destinationType,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      branchName: branchName ?? this.branchName,
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
      'messageType': messageType,
      'replyCount': replyCount,
      'relatedAppointmentId': relatedAppointmentId,
      'relatedPatientId': relatedPatientId,
      'studentPhoto': studentPhoto,
      'studentAid': studentAid,
      'destinationType': destinationType,
      'destinationLabel': destinationLabel,
      'branchName': branchName,
    };
  }
}

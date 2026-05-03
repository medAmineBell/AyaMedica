import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';

class BulkUploadStudentPayload {
  final String givenName;
  final String familyName;
  final String dateOfBirth;
  final String gender;
  final String grade;
  final String studentClass;
  final String nationality;
  final String documentType;
  final String documentNumber;
  final String fgFullName;
  final String fgRelation;
  final String fgEmail;
  final String fgPhone;
  final String? sgFullName;
  final String? sgRelation;
  final String? sgEmail;
  final String? sgPhone;

  BulkUploadStudentPayload({
    required this.givenName,
    required this.familyName,
    required this.dateOfBirth,
    required this.gender,
    required this.grade,
    required this.studentClass,
    required this.nationality,
    required this.documentType,
    required this.documentNumber,
    required this.fgFullName,
    required this.fgRelation,
    required this.fgEmail,
    required this.fgPhone,
    this.sgFullName,
    this.sgRelation,
    this.sgEmail,
    this.sgPhone,
  });

  bool get _hasSecondGuardian {
    bool any(String? s) => s != null && s.trim().isNotEmpty;
    return any(sgFullName) || any(sgRelation) || any(sgEmail) || any(sgPhone);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': {'given': givenName, 'family': familyName},
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'grade': grade,
      'class': studentClass,
      'nationality': nationality,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'fgFullName': fgFullName,
      'fgRelation': fgRelation,
      'fgEmail': fgEmail,
      'fgPhone': fgPhone,
    };
    if (_hasSecondGuardian) {
      json['sgFullName'] = sgFullName ?? '';
      json['sgRelation'] = sgRelation ?? '';
      json['sgEmail'] = sgEmail ?? '';
      json['sgPhone'] = sgPhone ?? '';
    }
    return json;
  }
}

class BulkUploadInvalidField {
  final String field;
  final String reason;

  BulkUploadInvalidField({required this.field, required this.reason});

  factory BulkUploadInvalidField.fromJson(Map<String, dynamic> json) {
    return BulkUploadInvalidField(
      field: json['field']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }
}

class BulkUploadRowResult {
  final int row;
  final String student;
  final bool success;
  final String? mode;
  final String? studentId;
  final String? aid;
  final Map<String, dynamic> data;
  final List<BulkUploadInvalidField> invalidFields;

  BulkUploadRowResult({
    required this.row,
    required this.student,
    required this.success,
    this.mode,
    this.studentId,
    this.aid,
    required this.data,
    required this.invalidFields,
  });

  factory BulkUploadRowResult.fromJson(Map<String, dynamic> json) {
    final invalidRaw = json['invalidFields'] as List?;
    final invalid = invalidRaw == null
        ? const <BulkUploadInvalidField>[]
        : invalidRaw
            .map((e) => BulkUploadInvalidField.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
    return BulkUploadRowResult(
      row: (json['row'] as num?)?.toInt() ?? 0,
      student: json['student']?.toString() ?? '',
      success: json['success'] == true,
      mode: json['mode'] as String?,
      studentId: json['studentId'] as String?,
      aid: json['aid'] as String?,
      data: Map<String, dynamic>.from((json['data'] as Map?) ?? const {}),
      invalidFields: invalid,
    );
  }

  String? reasonFor(String field) {
    for (final f in invalidFields) {
      if (f.field == field) return f.reason;
    }
    return null;
  }

  bool isInvalid(String field) => reasonFor(field) != null;
}

class BulkUploadResponse {
  final bool success;
  final String message;
  final int total;
  final int successful;
  final int failed;
  final int created;
  final int updated;
  final int transferred;
  final List<BulkUploadRowResult> results;
  final String? errorFileBase64;

  BulkUploadResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.successful,
    required this.failed,
    required this.created,
    required this.updated,
    required this.transferred,
    required this.results,
    this.errorFileBase64,
  });

  factory BulkUploadResponse.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from((json['data'] as Map?) ?? const {});
    final resultsRaw = data['results'] as List?;
    final results = resultsRaw == null
        ? const <BulkUploadRowResult>[]
        : resultsRaw
            .map((e) => BulkUploadRowResult.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
    return BulkUploadResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      total: (data['total'] as num?)?.toInt() ?? results.length,
      successful: (data['successful'] as num?)?.toInt() ?? 0,
      failed: (data['failed'] as num?)?.toInt() ?? 0,
      created: (data['created'] as num?)?.toInt() ?? 0,
      updated: (data['updated'] as num?)?.toInt() ?? 0,
      transferred: (data['transferred'] as num?)?.toInt() ?? 0,
      results: results,
      errorFileBase64:
          (data['errorFile'] as String?)?.isEmpty == true ? null : data['errorFile'] as String?,
    );
  }
}

class BulkUploadParseException implements Exception {
  final String message;
  BulkUploadParseException(this.message);
  @override
  String toString() => message;
}

class BulkUploadParser {
  /// Headers the parser requires on every row. Lookup is case-insensitive.
  /// `documentType` is intentionally absent — it's derived from branch country
  /// + nationality at parse time. `firstName` / `lastName` are the user-facing
  /// names; the API still receives `name.given` / `name.family`.
  static const List<String> requiredHeaders = [
    'firstName',
    'lastName',
    'gender',
    'dateOfBirth',
    'nationality',
    'documentNumber',
    'grade',
    'class',
    'fgFullName',
    'fgRelation',
    'fgEmail',
    'fgPhone',
  ];

  /// Headers the API treats as optional. Listed for completeness; the parser
  /// just ignores them when missing.
  static const List<String> optionalHeaders = [
    'sgFullName',
    'sgRelation',
    'sgEmail',
    'sgPhone',
  ];

  static List<BulkUploadStudentPayload> parseExcel(
    Uint8List bytes, {
    required String branchCountry,
  }) {
    final bc = branchCountry.trim().toUpperCase();
    if (bc != 'EG' && bc != 'SA') {
      throw BulkUploadParseException(
          'Bulk upload is only supported for branches in Egypt (EG) or Saudi Arabia (SA). '
          'Current branch country: ${branchCountry.isEmpty ? 'unknown' : branchCountry}.');
    }

    final normalized = _normalizeXlsxBytes(bytes);

    Excel excel;
    try {
      excel = Excel.decodeBytes(normalized);
    } catch (e) {
      throw BulkUploadParseException(
          'Could not read the file. Make sure it is a valid .xlsx file. ($e)');
    }

    Sheet? sheet;
    for (final key in excel.tables.keys) {
      final candidate = excel.tables[key];
      if (candidate != null && candidate.maxRows > 1) {
        sheet = candidate;
        break;
      }
    }
    if (sheet == null) {
      throw BulkUploadParseException('No data rows found in any sheet.');
    }

    final headerRow = sheet.row(0);
    final idx = <String, int>{};
    for (int i = 0; i < headerRow.length; i++) {
      final raw = headerRow[i]?.value;
      if (raw == null) continue;
      final header = _cellToText(raw).trim().toLowerCase();
      if (header.isNotEmpty) idx[header] = i;
    }

    final missing = <String>[];
    for (final h in requiredHeaders) {
      if (!idx.containsKey(h.toLowerCase())) missing.add(h);
    }
    if (missing.isNotEmpty) {
      throw BulkUploadParseException(
          'Missing required column${missing.length == 1 ? '' : 's'}: '
          '${missing.join(', ')}. '
          'Click "Download template" in the upload dialog to get the latest xlsx.');
    }

    final out = <BulkUploadStudentPayload>[];
    for (int r = 1; r < sheet.maxRows; r++) {
      final row = sheet.row(r);
      final given = _readString(row, idx, 'firstname');
      final family = _readString(row, idx, 'lastname');
      if (given.isEmpty && family.isEmpty) continue;

      final nationality = _readString(row, idx, 'nationality');
      out.add(BulkUploadStudentPayload(
        givenName: given,
        familyName: family,
        dateOfBirth: _readDate(row, idx, 'dateofbirth'),
        gender: _readString(row, idx, 'gender').toLowerCase(),
        grade: _readString(row, idx, 'grade'),
        studentClass: _readString(row, idx, 'class'),
        nationality: nationality,
        documentType: _resolveDocumentType(bc, nationality),
        documentNumber: _readString(row, idx, 'documentnumber'),
        fgFullName: _readString(row, idx, 'fgfullname'),
        fgRelation: _readString(row, idx, 'fgrelation').toUpperCase(),
        fgEmail: _readString(row, idx, 'fgemail'),
        fgPhone: _readPhone(row, idx, 'fgphone'),
        sgFullName: _readNullable(row, idx, 'sgfullname'),
        sgRelation: _readNullable(row, idx, 'sgrelation')?.toUpperCase(),
        sgEmail: _readNullable(row, idx, 'sgemail'),
        sgPhone: _readPhoneNullable(row, idx, 'sgphone'),
      ));
    }
    return out;
  }

  /// Derives documentType from branch country + student nationality.
  /// Caller has already validated branchCountry is EG or SA.
  static String _resolveDocumentType(String branchCountry, String nationality) {
    final nat = nationality.trim().toUpperCase();
    if (branchCountry == 'EG') {
      return nat == 'EG' ? 'national_id' : 'passport';
    }
    return nat == 'SA' ? 'national_id' : 'residence_id';
  }

  /// Builds a fresh xlsx template with the friendly column headers and one
  /// example row. Returned bytes can be saved straight to disk.
  static Uint8List buildTemplateXlsx() {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != 'Students') {
      excel.rename(defaultSheet, 'Students');
    }
    final sheet = excel['Students'];

    const headers = [
      'firstName', 'lastName', 'gender', 'dateOfBirth', 'nationality',
      'documentNumber', 'grade', 'class',
      'fgFullName', 'fgRelation', 'fgEmail', 'fgPhone',
      'sgFullName', 'sgRelation', 'sgEmail', 'sgPhone',
    ];
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = TextCellValue(headers[i]);
    }

    const example = [
      'Ahmed', 'Hassan', 'male', '2012-05-14', 'EG',
      '29005140123456', '5', 'A',
      'Mona Hassan', 'MOTHER', 'mona@example.com', '+201001234567',
      '', '', '', '',
    ];
    for (var i = 0; i < example.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1))
          .value = TextCellValue(example[i]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw BulkUploadParseException('Could not generate template file.');
    }
    return Uint8List.fromList(bytes);
  }

  static String _readString(
      List<Data?> row, Map<String, int> idx, String key) {
    final i = idx[key];
    if (i == null || i >= row.length) return '';
    final raw = row[i]?.value;
    if (raw == null) return '';
    return _cellToText(raw).trim();
  }

  static String? _readNullable(
      List<Data?> row, Map<String, int> idx, String key) {
    final s = _readString(row, idx, key);
    return s.isEmpty ? null : s;
  }

  static String _readDate(List<Data?> row, Map<String, int> idx, String key) {
    final i = idx[key];
    if (i == null || i >= row.length) return '';
    final raw = row[i]?.value;
    if (raw == null) return '';
    if (raw is DateCellValue) {
      return _isoDate(raw.year, raw.month, raw.day);
    }
    if (raw is DateTimeCellValue) {
      return _isoDate(raw.year, raw.month, raw.day);
    }
    return _normalizeDateString(_cellToText(raw).trim());
  }

  static String _isoDate(int y, int m, int d) =>
      '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  static String _normalizeDateString(String s) {
    if (s.isEmpty) return '';
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
    if (iso != null) {
      return _isoDate(int.parse(iso.group(1)!), int.parse(iso.group(2)!),
          int.parse(iso.group(3)!));
    }
    final dmy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(s);
    if (dmy != null) {
      return _isoDate(int.parse(dmy.group(3)!), int.parse(dmy.group(2)!),
          int.parse(dmy.group(1)!));
    }
    return s;
  }

  /// Reads a phone cell, normalizing it to the API's expected format. Numbers
  /// already in E.164 (`+201234567890`) pass through; bare digits get a `+`
  /// prefixed so the spreadsheet doesn't have to.
  static String _readPhone(List<Data?> row, Map<String, int> idx, String key) {
    final raw = _readString(row, idx, key);
    return _normalizePhone(raw);
  }

  static String? _readPhoneNullable(
      List<Data?> row, Map<String, int> idx, String key) {
    final raw = _readNullable(row, idx, key);
    if (raw == null) return null;
    final normalized = _normalizePhone(raw);
    return normalized.isEmpty ? null : normalized;
  }

  static String _normalizePhone(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    if (s.startsWith('+')) return s;
    return '+$s';
  }

  /// Some XLSX writers (Apple Numbers, LibreOffice, server-side libs) emit
  /// absolute `Target` paths in `xl/_rels/workbook.xml.rels`
  /// (e.g. `Target="/xl/worksheets/sheet1.xml"`). The `excel: 4.0.6` package
  /// concatenates these naively into `'xl//xl/worksheets/sheet1.xml'` which
  /// doesn't match any archive entry, then crashes with a null-check error in
  /// `_parseTable`. We strip the leading `/xl/` (and bare leading `/`) from
  /// rels Targets before handing the bytes off to the package.
  static Uint8List _normalizeXlsxBytes(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      bool changed = false;
      final rebuilt = Archive();

      for (final file in archive.files) {
        final isRels = file.name.endsWith('.rels');
        if (isRels && file.isFile) {
          final original = utf8.decode(file.content as List<int>);
          // Only strip leading slashes inside Target attributes.
          var fixed = original.replaceAllMapped(
            RegExp(r'Target="(/+)([^"]*)"'),
            (m) {
              var t = m.group(2) ?? '';
              // Inside xl/_rels/workbook.xml.rels and friends, paths are
              // resolved relative to xl/, so a leading `xl/` is the same as
              // the relative form — strip it for consistency.
              if (file.name.startsWith('xl/_rels/') && t.startsWith('xl/')) {
                t = t.substring(3);
              }
              return 'Target="$t"';
            },
          );
          if (fixed != original) {
            changed = true;
            final newBytes = utf8.encode(fixed);
            rebuilt.addFile(ArchiveFile(file.name, newBytes.length, newBytes));
            continue;
          }
        }
        rebuilt.addFile(file);
      }

      if (!changed) return bytes;
      final encoded = ZipEncoder().encode(rebuilt);
      if (encoded == null) return bytes;
      return Uint8List.fromList(encoded);
    } catch (_) {
      // If anything goes wrong the original bytes are passed through and the
      // standard "Could not read the file" message will surface upstream.
      return bytes;
    }
  }

  static String _cellToText(Object value) {
    if (value is TextCellValue) {
      return value.value.toString();
    }
    if (value is IntCellValue) return value.value.toString();
    if (value is DoubleCellValue) {
      final d = value.value;
      if (d == d.truncateToDouble()) return d.toInt().toString();
      return d.toString();
    }
    if (value is BoolCellValue) return value.value.toString();
    if (value is DateCellValue) {
      return _isoDate(value.year, value.month, value.day);
    }
    if (value is DateTimeCellValue) {
      return _isoDate(value.year, value.month, value.day);
    }
    return value.toString();
  }
}

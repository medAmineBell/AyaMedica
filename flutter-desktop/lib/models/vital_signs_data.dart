class VitalSignsData {
  String bloodGlucose;
  String bloodPressure; // stored as "systolic/diastolic" e.g. "120/80"
  String heartRate;
  String medication;
  String administrationForm;
  String doze;
  String unit;
  String presence; // BMI only: "Present" / "Absent"
  String height; // BMI only (CM)
  String weight; // BMI only (Kg)
  String note; // BMI only
  String bmiResult; // BMI only, calculated
  String patientStatus;
  String patientNote;

  VitalSignsData({
    this.bloodGlucose = '',
    this.bloodPressure = '',
    this.heartRate = '',
    this.medication = '',
    this.administrationForm = '',
    this.doze = '',
    this.unit = '',
    this.presence = '',
    this.height = '',
    this.weight = '',
    this.note = '',
    this.bmiResult = '',
    this.patientStatus = 'pending',
    this.patientNote = '',
  });

  /// Split blood pressure into systolic part
  String get systolic {
    if (bloodPressure.contains('/')) {
      return bloodPressure.split('/')[0];
    }
    return bloodPressure;
  }

  /// Split blood pressure into diastolic part
  String get diastolic {
    if (bloodPressure.contains('/')) {
      return bloodPressure.split('/')[1];
    }
    return '';
  }

  /// Set blood pressure from systolic and diastolic values
  void setBloodPressure(String systolic, String diastolic) {
    if (systolic.isNotEmpty || diastolic.isNotEmpty) {
      bloodPressure = '$systolic/$diastolic';
    } else {
      bloodPressure = '';
    }
  }

  /// Check if all required fields are filled for the given disease type
  bool isDone(String diseaseType) {
    switch (diseaseType.toLowerCase()) {
      case 'diabetes':
        return bloodGlucose.isNotEmpty &&
            medication.isNotEmpty &&
            administrationForm.isNotEmpty &&
            doze.isNotEmpty &&
            unit.isNotEmpty;
      case 'blood pressure':
        return systolic.isNotEmpty &&
            diastolic.isNotEmpty &&
            medication.isNotEmpty &&
            administrationForm.isNotEmpty &&
            doze.isNotEmpty &&
            unit.isNotEmpty;
      case 'cardiovascular':
        return heartRate.isNotEmpty &&
            medication.isNotEmpty &&
            administrationForm.isNotEmpty &&
            doze.isNotEmpty &&
            unit.isNotEmpty;
      case 'bmi':
        if (presence.isEmpty) return false;
        if (presence.toLowerCase() == 'absent') return true;
        return height.isNotEmpty && weight.isNotEmpty;
      default:
        return false;
    }
  }

  /// Calculate BMI from height (cm) and weight (kg)
  double? calculateBmi() {
    final h = double.tryParse(height);
    final w = double.tryParse(weight);
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final heightM = h / 100;
    return w / (heightM * heightM);
  }

  /// Get BMI category string
  static String bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obesity';
  }

  /// Get formatted BMI result string (e.g. "BMI = 23 (Normal)")
  String get formattedBmiResult {
    if (presence.toLowerCase() == 'absent') return 'Absent';
    final bmi = calculateBmi();
    if (bmi == null) return '';
    final rounded = bmi.round();
    return 'BMI = $rounded (${bmiCategory(bmi)})';
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodGlucose': bloodGlucose,
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'medication': medication,
      'administrationForm': administrationForm,
      'doze': doze,
      'unit': unit,
      'presence': presence,
      'height': height,
      'weight': weight,
      'note': note,
      'bmiResult': bmiResult,
      'patientStatus': patientStatus,
      'patientNote': patientNote,
    };
  }

  factory VitalSignsData.fromJson(Map<String, dynamic> json) {
    return VitalSignsData(
      bloodGlucose: json['bloodGlucose'] ?? '',
      bloodPressure: json['bloodPressure'] ?? '',
      heartRate: json['heartRate'] ?? '',
      medication: json['medication'] ?? '',
      administrationForm: json['administrationForm'] ?? '',
      doze: json['doze'] ?? '',
      unit: json['unit'] ?? '',
      presence: json['presence'] ?? '',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      note: json['note'] ?? '',
      bmiResult: json['bmiResult'] ?? '',
      patientStatus: json['patientStatus'] ?? 'pending',
      patientNote: json['patientNote'] ?? '',
    );
  }

  VitalSignsData copyWith({
    String? bloodGlucose,
    String? bloodPressure,
    String? heartRate,
    String? medication,
    String? administrationForm,
    String? doze,
    String? unit,
    String? presence,
    String? height,
    String? weight,
    String? note,
    String? bmiResult,
    String? patientStatus,
    String? patientNote,
  }) {
    return VitalSignsData(
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      medication: medication ?? this.medication,
      administrationForm: administrationForm ?? this.administrationForm,
      doze: doze ?? this.doze,
      unit: unit ?? this.unit,
      presence: presence ?? this.presence,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      note: note ?? this.note,
      bmiResult: bmiResult ?? this.bmiResult,
      patientStatus: patientStatus ?? this.patientStatus,
      patientNote: patientNote ?? this.patientNote,
    );
  }
}

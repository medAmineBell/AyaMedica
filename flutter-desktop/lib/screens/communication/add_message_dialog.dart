import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:flutter_getx_app/models/message_model.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddMessageDialog extends StatefulWidget {
  @override
  _AddMessageDialogState createState() => _AddMessageDialogState();
}

class _AddMessageDialogState extends State<AddMessageDialog> {
  int selectedAudience = 2; // 0: All, 1: Grade/Class, 2: Selected
  final controller = Get.find<CommunicationController>();

  // for “grade/class” mode
  final List<String> grades = ['Grade 1', 'Grade 2', 'Grade 3'];
  final List<String> classes = ['Class A', 'Class B', 'Class C'];
  String? selectedGrade;
  String? selectedClass;

  // for “selected students” mode
  final List<String> students = [
    'Emily Johnson',
    'John Doe',
    'Alice Smith',
    'Bob Lee',
    'Carol King'
  ];
  List<String> selectedStudents = [];

  // common fields
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController examinationController = TextEditingController();

  // file uploads
  final List<_UploadedFile> uploadedFiles = [];

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.first;
      final upload = _UploadedFile(file: file, progress: 0.0);
      setState(() => uploadedFiles.add(upload));
      // simulate upload progress
      Future.delayed(Duration(milliseconds: 200), () {
        _simulateProgress(upload);
      });
    }
  }

  void _simulateProgress(_UploadedFile upload) {
    if (upload.progress < 1.0) {
      setState(() => upload.progress += 0.1);
      Future.delayed(Duration(milliseconds: 200), () {
        _simulateProgress(upload);
      });
    }
  }

  void removeFile(int index) {
    setState(() => uploadedFiles.removeAt(index));
  }

  Widget buildAudienceSelector() {
    final titles = ['All students', 'A grade or class', 'Selected student(s)'];
    final icons = ["users-group", "teacher", "user-avatar"];

    return Row(
      children: List.generate(3, (i) {
        final isSelected = selectedAudience == i;
        return Expanded(
          child: ChoiceChip(
            showCheckmark: false,
            label: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isSelected
                      ? const Color(0xFFCDFF1F)
                      : const Color(0xFFDCE0E4),
                  child: SvgPicture.asset(
                    "assets/svg/${icons[i]}.svg",
                    width: 18,
                    color: const Color(0xFF595A5B),
                  ),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    titles[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            selected: isSelected,
            onSelected: (_) => setState(() => selectedAudience = i),
            selectedColor: const Color(0xFF1339FF),
            backgroundColor: const Color.fromARGB(255, 243, 242, 242),
            side: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
            shape: StadiumBorder(),
          ),
        );
      }),
    );
  }

  Widget buildStudentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select student(s):", style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        MultiSelectDialogField<String>(
          items: students.map((s) => MultiSelectItem(s, s)).toList(),
          initialValue: selectedStudents,
          title: Text("Students"),
          buttonText: Text(
            selectedStudents.isEmpty ? "All students" : "Select...",
          ),
          listType: MultiSelectListType.LIST,
          chipDisplay: MultiSelectChipDisplay(
            onTap: (item) => setState(() => selectedStudents.remove(item)),
          ),
          onConfirm: (values) => setState(() => selectedStudents = values),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 236, 236, 236),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 216, 216, 216),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildUploadedFiles() {
    return Column(
      children: uploadedFiles.asMap().entries.map((entry) {
        final idx = entry.key;
        final upload = entry.value;
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.folder, size: 24, color: Colors.grey),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(upload.file.name,
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: upload.progress,
                        minHeight: 4,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: () => removeFile(idx),
                child: Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Create new message",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // content
            Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildAudienceSelector(),
                    SizedBox(height: 20),

                    // inside your build(...) where you handle selectedAudience == 1:
                    if (selectedAudience == 1) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Select grade:",
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedGrade,
                                  items: grades
                                      .map((g) => DropdownMenuItem(
                                          value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => selectedGrade = v),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 236, 236, 236),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 216, 216, 216)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Select class:",
                                    style: TextStyle(fontSize: 16)),
                                SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: selectedClass,
                                  items: classes
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => selectedClass = v),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromARGB(
                                        255, 236, 236, 236),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 216, 216, 216)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ]

                    // selected students mode
                    else if (selectedAudience == 2) ...[
                      buildStudentDropdown(),
                      SizedBox(height: 20),
                    ],
                    Text(
                      "Message content",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // common fields
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: "Subject *",
                        filled: true,
                        fillColor: const Color.fromARGB(255, 236, 236, 236),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 216, 216, 216)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Message body",
                        filled: true,
                        fillColor: const Color.fromARGB(255, 236, 236, 236),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 216, 216, 216)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: pickFile,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open,
                                  size: 32, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Upload file',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    buildUploadedFiles(),
                    SizedBox(height: 12),
                    TextField(
                      controller: examinationController,
                      decoration: InputDecoration(
                        labelText: "Examination",
                        filled: true,
                        fillColor: const Color.fromARGB(255, 236, 236, 236),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 216, 216, 216)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // actions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Cancel',
                      variant: ButtonVariant.secondary,
                      backgroundColor: const Color(0xFFF3F4F6),
                      onPressed: () {
                        // Handle save as draft logic
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Send',
                      variant: ButtonVariant.primary,
                      backgroundColor: const Color(0xFF1339FF),
                      onPressed: () {
                        controller.addMessage(
                          MessageModel(
                            subject: subjectController.text,
                            messageBody: messageController.text,
                            dateTime: DateTime.now(),
                            from: 'You',
                            studentIds: [
                              Student(
                                id: '8EG3960J65A',
                                name: 'Jhon smith',
                                avatarColor: Color(0xFF10B981),
                                dateOfBirth: DateTime.parse('2011-03-15'),
                                bloodType: 'A-',
                                weightKg: 35.2,
                                heightCm: 132,
                                goToHospital: 'Ain Shams Hospital',
                                firstGuardianName: 'Amine Riahi',
                                firstGuardianPhone: '+21693719091',
                                firstGuardianEmail: 'amine@example.com',
                                firstGuardianStatus: 'Online',
                                secondGuardianName: 'Sarah Ben Ali',
                                secondGuardianPhone: '+21612345678',
                                secondGuardianEmail: 'sarah@example.com',
                                secondGuardianStatus: 'Offline',
                                city: 'Tunis',
                                street: '123 Rue de Marseille',
                                zipCode: '1000',
                                province: 'Tunis',
                                insuranceCompany: 'Saham',
                                policyNumber: 'POL1234567',
                                passportIdNumber: 'TN987654321',
                                nationality: 'Tunisian',
                                nationalId: '0123456789',
                                gender: 'Female',
                                phoneNumber: '+21698765432',
                                email: 'fatma@example.com',
                              ),
                            ],
                            status: 'Sent',
                            id: '',
                            fileUrls: [],
                            examination: '',
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadedFile {
  final PlatformFile file;
  double progress;
  _UploadedFile({required this.file, this.progress = 0.0});
}

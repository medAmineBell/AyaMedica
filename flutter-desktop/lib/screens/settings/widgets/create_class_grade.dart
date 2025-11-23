import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/gardes_controller.dart';
import 'package:flutter_getx_app/models/gardes.dart';
import 'package:get/get.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({Key? key}) : super(key: key);

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final TextEditingController gradeSearchController = TextEditingController();
  final TextEditingController classNameController = TextEditingController();

  final List<String> availableGrades = ['G1', 'G2', 'G3'];
  final List<String> selectedGrades = ['G1', 'G2'];
  final Map<String, String?> gradeCapacities = {};

  final List<String> capacities = ['20', '25', '30', '35'];
  final controller = Get.find<GardesController>();

  void removeGrade(String grade) {
    setState(() {
      selectedGrades.remove(grade);
      gradeCapacities.remove(grade);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add new class',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add the new class and grades details',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              /// Grade(s) and Class Name Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grade(s)*'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: gradeSearchController,
                          decoration: const InputDecoration(
                            hintText: 'Search grades',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: selectedGrades.map((grade) {
                            return Chip(
                              label: Text(grade),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => removeGrade(grade),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Class name*'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: classNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter class name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              /// Capacities
              const Text(
                'Class maximum capacity',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: selectedGrades.map((grade) {
                  return SizedBox(
                    width: 250,
                    child: DropdownButtonFormField<String>(
                      value: gradeCapacities[grade],
                      decoration: InputDecoration(
                        labelText: '$grade - Maximum capacity',
                        border: const OutlineInputBorder(),
                      ),
                      items: capacities.map((cap) {
                        return DropdownMenuItem(
                          value: cap,
                          child: Text(cap),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          gradeCapacities[grade] = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        var record = Gardes(
                          id: "4",
                          name: "Grade - G2",
                          MaxCapacity: 40,
                          NumClasses: 21,
                          ClassName: "Tigers",
                          ActualCapacity: 30,
                        );
                        controller.gardes.add(record);
                        Navigator.pop(context);
                        // TODO: Handle form submission
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color.fromARGB(255, 19, 57, 255),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                      ),
                      child: const Text('Add record'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

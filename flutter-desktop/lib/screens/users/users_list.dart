import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/users_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class UsersListScreen extends StatelessWidget {
  final UsersController controller = Get.find<UsersController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Users"),
                  // ElevatedButton(
                  //   onPressed: controller.onAddUserPressed,
                  //   child: Text("Add new user"),
                  // ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("User name & role")),
                    DataColumn(label: Text("Type")),
                    DataColumn(label: Text("City & Governorate")),
                    DataColumn(label: Text("Role")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: controller.users.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user.name)),
                      DataCell(Text(user.type)),
                      DataCell(Text(user.city)),
                      DataCell(Text(user.role)),
                      DataCell(Text(user.status)),
                      DataCell(Row(
                        children: [
                          // IconButton(
                          //     icon: Icon(Icons.edit),
                          //     onPressed: () => controller.onEdit(user)),
                          IconButton(
                              icon: SvgPicture.asset(
                                'assets/svg/note-remove.svg',
                                width: 24,
                                height: 24,
                              ),
                              // onPressed: () => controller.onDelete(user)
                              onPressed: () {
                                // Logic to delete user
                                // controller.users.remove(user);
                              }),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ));
  }
}

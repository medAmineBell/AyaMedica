import 'package:get/get.dart';
import 'package:flutter_getx_app/models/userAppItem.dart';

class MobileAppUserController extends GetxController {
  final RxList<UserAppItem> users = <UserAppItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Mock data
    users.value = [
      UserAppItem(
        initials: 'AB',
        fullName: 'Alice Brown',
        classGroup: 'G1 - A',
        firstGuardian: Guardian(
          name: 'John Brown',
          phone: '123456789',
          email: 'john@example.com',
          status: 'Active',
          deliveryStatus: 'Delivered',
        ),
        secondGuardian: Guardian(
          name: 'Jane Brown',
          phone: '987654321',
          email: 'jane@example.com',
          status: 'Unverified',
          deliveryStatus: 'Sent',
        ),
      ),
      UserAppItem(
        initials: 'CD',
        fullName: 'Charlie Davis',
        classGroup: 'G2 - B',
        firstGuardian: Guardian(
          name: 'Chris Davis',
          phone: '555555555',
          email: 'chris@example.com',
          status: 'Inactive',
          deliveryStatus: 'Failed',
        ),
        secondGuardian: Guardian(
          name: '--',
          phone: '',
          email: '',
          status: 'Unverified',
          deliveryStatus: 'Sent',
        ),
      ),
    ];
  }
} 
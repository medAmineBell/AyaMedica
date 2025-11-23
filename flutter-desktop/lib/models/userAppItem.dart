class UserAppItem {
  final String initials;
  final String fullName;
  final String classGroup;
  final Guardian firstGuardian;
  final Guardian secondGuardian;

  UserAppItem({
    required this.initials,
    required this.fullName,
    required this.classGroup,
    required this.firstGuardian,
    required this.secondGuardian,
  });
}

class Guardian {
  final String name;
  final String phone;
  final String email;
  final String status;
  final String deliveryStatus;

  Guardian({
    required this.name,
    required this.phone,
    required this.email,
    required this.status, // e.g., "Active", "Inactive", "Offline"
    required this.deliveryStatus, // e.g., "Sent", "Delivered", "Failed"
  });
}

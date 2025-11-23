enum HealthStatus { good, issue }

class HealthStatusData {
  final HealthStatus status;
  final String? issueDescription;
  
  HealthStatusData({
    required this.status,
    this.issueDescription,
  });
}

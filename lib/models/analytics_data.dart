class AnalyticsData {
  final int registeredUsers;
  final int totalComplaints;
  final int totalInquiries;
  final int activeProjects;
  final int pendingRequests;
  final Map<String, int> complaintsPerCategory;
  final Map<String, int> userActivityLastWeek;

  AnalyticsData({
    required this.registeredUsers,
    required this.totalComplaints,
    required this.totalInquiries,
    required this.activeProjects,
    required this.pendingRequests,
    required this.complaintsPerCategory,
    required this.userActivityLastWeek,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      registeredUsers: json['registeredUsers'] ?? 0,
      totalComplaints: json['totalComplaints'] ?? 0,
      totalInquiries: json['totalInquiries'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      complaintsPerCategory: Map<String, int>.from(json['complaintsPerCategory'] ?? {}),
      userActivityLastWeek: Map<String, int>.from(json['userActivityLastWeek'] ?? {}),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/feedbackDashboard/feedback_dashboard_screen.dart';
import 'package:get/get.dart';
import '../../shared/widgets/breadcrumb_widget.dart';
import '../mobileAppUser/mobile_app_user_app_screen.dart';
import 'widgets/gard_settings_screen.dart';

class AyamedicaSolutionScreen extends StatefulWidget {
  const AyamedicaSolutionScreen({Key? key}) : super(key: key);

  @override
  State<AyamedicaSolutionScreen> createState() => _AyamedicaSolutionScreenState();
}

class _AyamedicaSolutionScreenState extends State<AyamedicaSolutionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
_tabController = TabController(length: 5, vsync: this); // ✅ Matches tabs count
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFCFD),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child:              Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appointment connect',
                        style: TextStyle(
                          color: Color(0xFF2D2E2E) /* Text-Text-100 */,
                          fontSize: 20,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      const BreadcrumbWidget(
                        items: [
                          BreadcrumbItem(label: 'Ayamedica portal'),
                          BreadcrumbItem(label: 'Ayamedica solution'),
                        ],
                      ),
                    ],
                  ),
          ),
          
          // Tab Bar
      Container(
  color: Colors.white,
  child: TabBar(
    controller: _tabController,
    isScrollable: true,
    labelColor: const Color(0xFF1339FF),
    unselectedLabelColor: const Color(0xFF595A5B),
    indicatorColor: const Color(0xFF1339FF),
    indicatorWeight: 2,
    indicatorPadding: const EdgeInsets.only(bottom: 8),
    labelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    tabs: const [
      Tab(
        child: Row(
          children: [
            Icon(Icons.phone_android, size: 18),
            SizedBox(width: 8),
            Text('Mobile app Insights & Feedback'),
          ],
        ),
      ),
      Tab(
        child: Row(
          children: [
            Icon(Icons.group, size: 18),
            SizedBox(width: 8),
            Text('Mobile app users'),
          ],
        ),
      ),
      Tab(
        child: Row(
          children: [
            Icon(Icons.settings, size: 18),
            SizedBox(width: 8),
            Text('Service health'),
          ],
        ),
      ),
      Tab(
        child: Row(
          children: [
            Icon(Icons.policy, size: 18),
            SizedBox(width: 8),
            Text('Compliance & Policies'),
          ],
        ),
      ),
      Tab(
        child: Row(
          children: [
            Icon(Icons.support_agent, size: 18),
            SizedBox(width: 8),
            Text('Contact & support'),
          ],
        ),
      ),
    ],
  ),
),
   
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Grades Settings Tab
                const FeedbackDashboardScreen(),
                
                // User Management Tab
                MobileAppUserAppScreen(),
                
                // System Configuration Tab
                _buildSystemConfigurationTab(),
                
                // Security Tab
                _buildSecurityTab(),
                                _buildSecurityTab(),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2E2E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage system users, roles, and permissions',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF595A5B),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder for user management content
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text(
                'User Management content will be implemented here',
                style: TextStyle(
                  color: Color(0xFF595A5B),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemConfigurationTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2E2E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Configure system settings and preferences',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF595A5B),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder for system configuration content
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text(
                'System Configuration content will be implemented here',
                style: TextStyle(
                  color: Color(0xFF595A5B),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2E2E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage security settings and access controls',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF595A5B),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder for security content
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Center(
              child: Text(
                'Security Settings content will be implemented here',
                style: TextStyle(
                  color: Color(0xFF595A5B),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
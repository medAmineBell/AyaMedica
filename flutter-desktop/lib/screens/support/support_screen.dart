import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/breadcrumb_widget.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support',
                  style: TextStyle(
                    color: Color(0xFF2D2E2E),
                    fontSize: 20,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                    height: 1.40,
                  ),
                ),
                BreadcrumbWidget(
                  items: [
                    BreadcrumbItem(label: 'Ayamedica portal'),
                    BreadcrumbItem(label: 'Support'),
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
              isScrollable: false,
              labelColor: const Color(0xFF1339FF),
              unselectedLabelColor: const Color(0xFF595A5B),
              indicatorColor: const Color(0xFF1339FF),
              indicatorWeight: 2,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.support_agent, size: 18),
                      SizedBox(width: 8),
                      Text('Contact support'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.privacy_tip_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Privacy policies'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Terms of service'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.system_update_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Software updates'),
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
                _buildContactSupportTab(),
                _buildPrivacyPoliciesTab(),
                _buildTermsOfServiceTab(),
                _buildSoftwareUpdatesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportTab() {
    final emailController = TextEditingController();
    final categoryController = TextEditingController();
    final subCategoryController = TextEditingController();
    final messageController = TextEditingController();
    String selectedService = 'Customer support';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayamedica support section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent,
                        size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Ayamedica support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Frequently asked questions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 12),
                _buildExpandableItem('How to use it'),
                const SizedBox(height: 8),
                _buildExpandableItem('Category services goes here'),
                const SizedBox(height: 8),
                _buildExpandableItem('Category services goes here'),
                const SizedBox(height: 8),
                _buildExpandableItem('Category services goes here'),
                const SizedBox(height: 24),
                const Text(
                  'Connect you through social networks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSocialButton('WhatsApp', '+974 1111-2222'),
                    const SizedBox(width: 16),
                    _buildSocialButton('Telegram', '+974 1111-2222'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact ayamedica section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact ayamedica',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'email@company.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFBFCFD),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE9E9E9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Color(0xFF0066FF)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Services',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFCFD),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFE9E9E9)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedService,
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Color(0xFF0066FF)),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF374151),
                                  fontWeight: FontWeight.w400,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Customer support',
                                    child: Text('Customer support'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Technical support',
                                    child: Text('Technical support'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Sales inquiry',
                                    child: Text('Sales inquiry'),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Handle dropdown change
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    text: 'Sub category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBFCFD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE9E9E9)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text('Select sub category'),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF0066FF)),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w400,
                      ),
                      items: const [],
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    text: 'Message',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Please provide a brief explanation of the subject',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFBFCFD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0066FF)),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: const Text('Upload additional file'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF595A5B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoliciesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip_outlined,
                    size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Privacy policies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '1) Overview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'AYAMEDICA LLC is the operator and controller of the website www.ayamedica.com and Mobile applications on iOS or ANDROID stores, and he responsibly for the Privacy Policy of Ayamedica.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1.2 This Privacy Policy describes how we collect, use, disclose and protect your personal information. It applies to all information that you share with us when visiting and interacting with https://www.ayamedica.com and mobile applications ("Ayamedica"). By the way, use of Ayamedica constitutes your acceptance of this Privacy Policy and our Terms of Service ("Terms"). If you do not agree to the terms of this policy, please do not use this information.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1.3 Please take your time to read this policy ("Ayamedica Privacy Policy"), which describes how we collect personal information, what are the types of information we collect when you access or use of Ayamedica ("Ayamedica Portal Services").',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                text:
                    '1.4 You acknowledge that your continued or any personal use of Ayamedica, whether or not by a registered user, constitutes your consent to undergo any changes to this policy before any use. If you do not agree to the terms of this policy or any other terms or services of Ayamedica provided, we may stop the services of service storing providers in order to help you.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: ' Please note that ',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text:
                        'Ayamedica is a platform that provides services to clients such as hospitals, large legal person and the providers to on behalf of the data or service storing providers.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '2) Definitions',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'In this policy, unless otherwise required by the context, the following terms shall have the meanings referred to:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            _buildDefinitionItem('2.1', '"User", "you" or "yours"',
                'shall refer to any person using, registering account or using the website or mobile applications.'),
            _buildDefinitionItem('2.2', '"We", "us", or "ours"',
                'shall refer to the platform and information collected through the user in the entity to on the platform while communicating with the website or mobile applications.'),
            _buildDefinitionItem('2.3', '"Personal information"',
                'shall refer to the data and information collected about the user by the entity to on the data collected about the information who has been selected.'),
            _buildDefinitionItem('2.4', '"Third party"',
                'shall refer to any third party or external legal entity not directly affiliated with Ayamedica, in the meaning of this policy means that any third party legal person who provides to on the behalf of service or on behalf of Ayamedica to clients.'),
            _buildDefinitionItem('2.5', '"Processing"',
                'shall refer to any operation which is performed upon personal information, whether or not by automatic means.'),
            _buildDefinitionItem('2.6', '"Data Processors (Service Providers)"',
                'shall refer to any or legal person who processes the data on behalf of the data controller; we may use the services of various service providers in order to process your information more effectively.'),
            _buildDefinitionItem('2.7', '"Policy"',
                'shall refer to this document as well as the clauses contained herein.'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Read and approved',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      'Read and here...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0066FF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsOfServiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Terms of service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '1) Overview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1.1 These terms govern your access to the website www.ayamedica.com and Mobile Apps on iOS or ANDROID server running on smartphones of year use of content or services provided by the AYAMEDICA LLC at the owner and operator of the website and Mobile Apps (referred to as "Ayamedica").',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1.2 Please read our terms of use, privacy policy and all supplemental policies policies relating to your use of the services (collectively referred to as "Terms and Conditions") to ensure that you understand each term before using any of the services.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1.3 By accessing or using any part of the website and Mobile Apps or services, you agree to be bound by these terms. If you do not agree to all of our terms, then you may not access or use any of the services.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1.4 You stand our right to:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '1.4.1 Amend or change these terms.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1.4.2 Will not give your access to the services.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1.4.3 Discontinue or Suspend providing these terms.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1.4.4 Deny or withdraw this service temporarily or permanently without notice.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '2) Procedures Of Use',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'To use Ayamedica\'s services, you represent and warrant to us that:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            _buildDefinitionItem('2.1.1', 'You must agree to these terms.', ''),
            _buildDefinitionItem('2.2', '"User", "you" or "yours"',
                'shall refer to any person using, registering account or using the website or mobile applications.'),
            _buildDefinitionItem('2.3', '"Personal information"',
                'shall refer to the data and information collected about the user by the entity to on the data collected about the information who has been selected.'),
            _buildDefinitionItem('2.4', '"Third party"',
                'shall refer to any third party or external legal entity not directly affiliated with Ayamedica; in the meaning of this policy means that any third party legal person who provides to on the behalf of service or on behalf of Ayamedica to clients.'),
            _buildDefinitionItem('2.5', '"Processing"',
                'shall refer to any operation which is performed upon personal information, whether or not by automatic means.'),
            _buildDefinitionItem('2.6', '"Data Processors (Service Providers)"',
                'shall refer to any or legal person who processes the data on behalf of the data controller; we may use the services of service storing providers in order to'),
            _buildDefinitionItem('2.7', '"Policy"',
                'shall refer to this document as well as the clauses contained herein.'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Read and approved',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {},
                    child: const Text(
                      'Read and here...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0066FF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoftwareUpdatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Date & time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'No software updates available at this time.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Current Version: 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last checked: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Check for updates'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableItem(String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Content for $title will be displayed here.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String platform, String contact) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: platform == 'WhatsApp'
                    ? const Color(0xFF25D366)
                    : const Color(0xFF0088CC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                platform == 'WhatsApp' ? Icons.chat : Icons.send,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              platform,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionItem(String number, String term, String definition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '$number ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: term,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (definition.isNotEmpty)
              TextSpan(
                text: ' $definition',
              ),
          ],
        ),
      ),
    );
  }
}

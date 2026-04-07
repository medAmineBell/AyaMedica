import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/app_config.dart';
import '../../controllers/update_controller.dart';
import '../../utils/api_service.dart';
import '../../utils/storage_service.dart';
import '../../shared/widgets/breadcrumb_widget.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final WebViewController _privacyWebViewController;
  late final WebViewController _termsWebViewController;

  // API services
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Social links state
  Map<String, dynamic> _socialLinks = {};
  bool _isLoadingSocialLinks = true;

  // Contact form state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'Customer Support';
  String _selectedSubCategory = 'Access to platform';
  PlatformFile? _attachedFile;
  bool _isSending = false;

  static const List<String> _categories = [
    'Customer Support',
    'Technical Support',
    'Billing',
    'General Inquiry',
  ];

  static const Map<String, List<String>> _subCategories = {
    'Customer Support': [
      'Access to platform',
      'Account issues',
      'Feature request',
      'Other',
    ],
    'Technical Support': [
      'App crash',
      'Bug report',
      'Performance issue',
      'Other',
    ],
    'Billing': [
      'Payment issue',
      'Subscription',
      'Refund request',
      'Other',
    ],
    'General Inquiry': [
      'Partnership',
      'Feedback',
      'Other',
    ],
  };

  List<String> get _currentSubCategories =>
      _subCategories[_selectedCategory] ?? ['Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Pre-fill email from user data
    final userData = _storageService.getUserData();
    if (userData != null && userData['email'] != null) {
      _emailController.text = userData['email'];
    }

    _fetchSocialLinks();

    _privacyWebViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == 'https://ayamedica.com/privacy-policy/' ||
                request.url == 'https://ayamedica.com/privacy-policy') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://ayamedica.com/privacy-policy/'));

    _termsWebViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url ==
                    'https://ayamedica.com/terms-and-conditions/' ||
                request.url ==
                    'https://ayamedica.com/terms-and-conditions') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(
          Uri.parse('https://ayamedica.com/terms-and-conditions/'));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchSocialLinks() async {
    final result = await _apiService.fetchSocialLinks();
    if (mounted) {
      setState(() {
        _isLoadingSocialLinks = false;
        if (result['success'] == true) {
          _socialLinks = Map<String, dynamic>.from(result['data']);
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _attachedFile = result.files.first);
    }
  }

  Future<void> _submitSupportTicket() async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your message',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      String? attachmentUrl;

      // Upload attachment if selected
      if (_attachedFile != null && _attachedFile!.path != null) {
        final uploadResult = await _apiService.uploadSupportFile(
          _attachedFile!.path!,
          _attachedFile!.name,
        );
        if (uploadResult['success'] == true) {
          attachmentUrl = uploadResult['data']['url'];
        } else {
          throw Exception('Failed to upload attachment');
        }
      }

      final result = await _apiService.submitSupportTicket(
        email: _emailController.text.trim(),
        serviceCategory: _selectedCategory,
        subCategory: _selectedSubCategory,
        message: _messageController.text.trim(),
        attachmentUrl: attachmentUrl,
      );

      if (result['success'] == true) {
        _messageController.clear();
        setState(() => _attachedFile = null);
        Get.snackbar(
          'Success',
          'Your support request has been submitted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      } else {
        throw Exception(result['error'] ?? 'Failed to submit');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit support request. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Social networks section
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
                  'Connect you through social networks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                _isLoadingSocialLinks
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Row(
                        children: [
                          if (_socialLinks['whatsapp'] != null)
                            _buildSocialButton(
                              'WhatsApp',
                              _socialLinks['whatsapp'],
                              const Color(0xFF25D366),
                              Icons.chat,
                            ),
                          if (_socialLinks['whatsapp'] != null &&
                              _socialLinks['telegram'] != null)
                            const SizedBox(width: 16),
                          if (_socialLinks['telegram'] != null)
                            _buildSocialButton(
                              'Telegram',
                              _socialLinks['telegram'],
                              const Color(0xFF0088CC),
                              Icons.send,
                            ),
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact form section
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
                      child: _buildFormField(
                        label: 'Email',
                        required: true,
                        child: TextField(
                          controller: _emailController,
                          decoration: _inputDecoration(
                              hintText: 'email@company.com'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField(
                        label: 'Services',
                        required: true,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFCFD),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFE9E9E9)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF0066FF)),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                                fontWeight: FontWeight.w400,
                              ),
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategory = value;
                                    _selectedSubCategory =
                                        _currentSubCategories.first;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'Sub category',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFCFD),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFE9E9E9)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSubCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Color(0xFF0066FF)),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w400,
                        ),
                        items: _currentSubCategories
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(
                                () => _selectedSubCategory = value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  label: 'Message',
                  child: TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: _inputDecoration(
                      hintText:
                          'Please provide a brief explanation of the subject',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: const Text('Upload additional file'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF595A5B),
                      ),
                    ),
                    if (_attachedFile != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file,
                                size: 14, color: Color(0xFF6B7280)),
                            const SizedBox(width: 6),
                            Text(
                              _attachedFile!.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => setState(
                                  () => _attachedFile = null),
                              child: const Icon(Icons.close,
                                  size: 14,
                                  color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSending ? null : _submitSupportTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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

  Widget _buildFormField({
    required String label,
    bool required = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
            children: [
              if (required)
                const TextSpan(
                  text: '*',
                  style: TextStyle(color: Color(0xFFDC2626)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildPrivacyPoliciesTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: WebViewWidget(controller: _privacyWebViewController),
      ),
    );
  }

  Widget _buildTermsOfServiceTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: WebViewWidget(controller: _termsWebViewController),
      ),
    );
  }

  Widget _buildSoftwareUpdatesTab() {
    final updateController = Get.find<UpdateController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() {
          final isUpdateAvailable = updateController.isUpdateAvailable.value;
          final isUpdating = updateController.isUpdating.value;
          return Column(
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
              Text(
                isUpdateAvailable
                    ? 'A new software update is available.'
                    : 'No software updates available at this time.',
                style: TextStyle(
                  fontSize: 14,
                  color: isUpdateAvailable
                      ? const Color(0xFF059669)
                      : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Current Version: ${AppConfig.appVersion}',
                style: const TextStyle(
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
              if (isUpdateAvailable) ...[
                ElevatedButton.icon(
                  onPressed: isUpdating
                      ? null
                      : () => updateController.applyUpdate(),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: Text(
                      isUpdating ? 'Updating...' : 'Update Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () => updateController.checkForUpdate(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Check for updates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSocialButton(
      String platform, String url, Color color, IconData icon) {
    // Extract display text from URL
    String displayText = url;
    if (url.contains('wa.me/')) {
      displayText = url.replaceAll('https://wa.me/', '');
    } else if (url.contains('t.me/')) {
      displayText = url.replaceAll('https://t.me/', '');
    }

    return Expanded(
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(8),
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
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
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
                displayText,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

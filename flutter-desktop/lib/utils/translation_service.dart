import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TranslationService extends Translations {
  static const Locale fallbackLocale = Locale('ar');

  @override
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'ar': ar,
      };

  // English translations
  static const Map<String, String> en = {
    // ===== GENERAL =====
    'app_name': 'Ayamedica',
    'next': 'Next',
    'skip': 'Skip',
    'get_started': 'Get Started',
    'settings': 'Settings',
    'language': 'Language',
    'theme': 'Theme',
    'dark_mode': 'Dark Mode',
    'english': 'English',
    'arabic': 'Arabic',
    'user': 'User',
    'role': 'Role',
    'error_occurred': 'An error occurred',

    // ===== AUTHENTICATION =====
    // Login Screen
    'welcome_title': 'Welcome to ayamedica portal',
    'welcome_subtitle': 'Please select a login method and enter your details to proceed',
    'login': 'Login',
    'login_methods': 'Login Methods',
    'login_failed': 'Login failed',
    'login_failed_title': 'Login Failed',
    'login_error': 'An error occurred during login',
    'logout_success': 'Successfully logged out',
    'logout_error': 'Failed to log out',
    'logged_out': 'You have been successfully logged out',
    'invalid_credentials': 'Please enter a valid phone number and password',
    'credentials_invalid': 'Invalid credentials',

    // Login Methods
    'aid': 'AID',
    'phone': 'Phone',
    'email': 'Email address',
    'nid_ppn': 'NID/PPN',

    // Field Labels
    'enter_phone': 'Enter your phone number',
    'enter_phone_number': 'Enter your phone number',
    'enter_password': 'Enter your password',
    'enter_aid': 'Enter your AID',
    'enter_email': 'Enter your email address',
    'enter_nid': 'Enter your NID/PPN',
    'forgot_password': 'Forgot your password?',

    // Field Hints
    'password_hint': '************',
    'phone_hint': '22222222',
    'aid_hint': 'AID123456',
    'email_hint': 'admin@example.com',
    'nid_hint': '1234567890',

    // Field Validation
    'aid_invalid': 'AID must be at least 8 characters',
    'phone_invalid': 'Phone number must be at least 8 characters',
    'email_invalid': 'Please enter a valid email address',
    'nid_invalid': 'NID must be at least 10 characters',
    'field_invalid': 'Please enter a valid value',

    // Field Errors
    'phone_not_exist': 'Phone number does not exist',
    'aid_not_exist': 'AID does not exist',
    'email_not_exist': 'Email address does not exist',
    'nid_not_exist': 'NID does not exist',

    // ===== ONBOARDING =====
    'onboarding_title_1': 'Welcome to Ayamedica',
    'onboarding_desc_1': 'Your complete healthcare solution',
    'onboarding_title_2': 'Multiple Themes',
    'onboarding_desc_2': 'Switch between light and dark themes easily',
    'onboarding_title_3': 'Multiple Languages',
    'onboarding_desc_3': 'Support for English and Arabic languages',

    // ===== ORGANIZATION =====
    'welcome_back': 'Welcome back',
    'choose_branch': 'Please choose the branch from the list',
    'add_new_organization': 'Add new organization',
    'branch': 'Branch',
    'organization': 'Organization',
    'select_branch': 'Select Branch',
    'no_branches_available': 'No branches available',
    'loading_branches': 'Loading branches...',
    'error_loading_branches': 'Error loading branches',

    // ===== LOGOUT DIALOG =====
    'logout': 'Logout',
    'logout_confirmation_title': 'Logout',
    'logout_confirmation_message': 'Are you sure you want to logout? You will need to sign in again to access your account.',
    'cancel': 'Cancel',

    // ===== ROLES =====
    'admin': 'Admin',
    'staff': 'Staff',
    'manager': 'Manager',
    'doctor': 'Doctor',
    'nurse': 'Nurse',
    'receptionist': 'Receptionist',
    'pharmacist': 'Pharmacist',
    'accountant': 'Accountant',
    'other': 'Other',

    // ===== LEGACY/DUPLICATES =====
    'register_greeting': 'Welcome to Ayamedica',
    'English': 'English',
    'العربية': 'Arabic',
    'select_country': 'Select country',
  };

  // Arabic translations
  static const Map<String, String> ar = {
    // ===== GENERAL =====
    'app_name': 'أياميديكا',
    'next': 'التالي',
    'skip': 'تخطي',
    'get_started': 'ابدأ الآن',
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'theme': 'المظهر',
    'dark_mode': 'الوضع الداكن',
    'english': 'الإنجليزية',
    'arabic': 'العربية',
    'user': 'المستخدم',
    'role': 'الدور',
    'error_occurred': 'حدث خطأ',

    // ===== AUTHENTICATION =====
    // Login Screen
    'welcome_title': 'مرحبًا بكم في بوابة أيامديكا',
    'welcome_subtitle': 'الرجاء اختيار طريقة تسجيل الدخول وإدخال بياناتك للمتابعة',
    'login': 'تسجيل الدخول',
    'login_methods': 'طرق تسجيل الدخول',
    'login_failed': 'فشل تسجيل الدخول',
    'login_failed_title': 'فشل تسجيل الدخول',
    'login_error': 'حدث خطأ أثناء تسجيل الدخول',
    'logout_success': 'تم تسجيل الخروج بنجاح',
    'logout_error': 'فشل تسجيل الخروج',
    'logged_out': 'تم تسجيل خروجك بنجاح',
    'invalid_credentials': 'الرجاء إدخال رقم هاتف وكلمة مرور صالحين',
    'credentials_invalid': 'بيانات اعتماد غير صحيحة',

    // Login Methods
    'aid': 'معرف المساعدة',
    'phone': 'الهاتف',
    'email': 'البريد الإلكتروني',
    'nid_ppn': 'الهوية/رقم الجواز',

    // Field Labels
    'enter_phone': 'أدخل رقم هاتفك',
    'enter_phone_number': 'أدخل رقم هاتفك',
    'enter_password': 'أدخل كلمة المرور',
    'enter_aid': 'أدخل معرف المساعدة',
    'enter_email': 'أدخل عنوان بريدك الإلكتروني',
    'enter_nid': 'أدخل رقم الهوية/الجواز',
    'forgot_password': 'نسيت كلمة المرور؟',

    // Field Hints
    'password_hint': '************',
    'phone_hint': '22222222',
    'aid_hint': 'AID123456',
    'email_hint': 'admin@example.com',
    'nid_hint': '1234567890',

    // Field Validation
    'aid_invalid': 'معرف المساعدة يجب أن يكون 8 أحرف على الأقل',
    'phone_invalid': 'رقم الهاتف يجب أن يكون 8 أرقام على الأقل',
    'email_invalid': 'الرجاء إدخال عنوان بريد إلكتروني صحيح',
    'nid_invalid': 'رقم الهوية يجب أن يكون 10 أرقام على الأقل',
    'field_invalid': 'الرجاء إدخال قيمة صحيحة',

    // Field Errors
    'phone_not_exist': 'رقم الهاتف غير موجود',
    'aid_not_exist': 'معرف المساعدة غير موجود',
    'email_not_exist': 'عنوان البريد الإلكتروني غير موجود',
    'nid_not_exist': 'رقم الهوية غير موجود',

    // ===== ONBOARDING =====
    'onboarding_title_1': 'مرحبًا بك في أياميديكا',
    'onboarding_desc_1': 'حل الرعاية الصحية الكامل الخاص بك',
    'onboarding_title_2': 'سمات متعددة',
    'onboarding_desc_2': 'التبديل بين السمات الفاتحة والداكنة بسهولة',
    'onboarding_title_3': 'لغات متعددة',
    'onboarding_desc_3': 'دعم للغتين الإنجليزية والعربية',

    // ===== ORGANIZATION =====
    'welcome_back': 'مرحباً بعودتك',
    'choose_branch': 'الرجاء اختيار الفرع من القائمة',
    'add_new_organization': 'إضافة منشأة جديدة',
    'branch': 'الفرع',
    'organization': 'المنشأة',
    'select_branch': 'اختر الفرع',
    'no_branches_available': 'لا توجد فروع متاحة',
    'loading_branches': 'جاري تحميل الفروع...',
    'error_loading_branches': 'حدث خطأ أثناء تحميل الفروع',

    // ===== LOGOUT DIALOG =====
    'logout': 'تسجيل الخروج',
    'logout_confirmation_title': 'تسجيل الخروج',
    'logout_confirmation_message': 'هل أنت متأكد من أنك تريد تسجيل الخروج؟ ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى حسابك.',
    'cancel': 'إلغاء',

    // ===== ROLES =====
    'admin': 'مدير النظام',
    'staff': 'موظف',
    'manager': 'مدير',
    'doctor': 'طبيب',
    'nurse': 'ممرض',
    'receptionist': 'موظف استقبال',
    'pharmacist': 'صيدلي',
    'accountant': 'محاسب',
    'other': 'آخر',

    // ===== LEGACY/DUPLICATES =====
    'register_greeting': 'مرحبًا بك في أياميديكا',
    'English': 'الإنجليزية',
    'العربية': 'العربية',
    'select_country': 'اختر الدولة',
  };
}

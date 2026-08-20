import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/Batch/colors.dart';
import '../../widgets/language_selector_sheet.dart';
import '../auth/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool darkMode = false;
  bool twoFactorAuth = true;

  // Editable user fields
  String _customName = "";
  String _customEmail = "";
  String _customPhone = "+94 77 123 4567";
  String _customLocation = "Chillaw Processing Center";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _customName = (auth.user?.fullName.isNotEmpty == true)
            ? auth.user!.fullName
            : "Sanjaya";
        _customEmail = (auth.user?.email.isNotEmpty == true)
            ? auth.user!.email
            : "sanjaya@smartkarawala.com";
      });
    });
  }

  /// 1. Edit Personal Information Dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _customName);
    final emailController = TextEditingController(text: _customEmail);
    final phoneController = TextEditingController(text: _customPhone);
    final locationController = TextEditingController(text: _customLocation);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Personal Info",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    controller: nameController,
                    label: "Full Name",
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v?.trim().isEmpty == true ? "Please enter your name" : null,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    controller: emailController,
                    label: "Email Address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.contains("@") != true ? "Please enter a valid email" : null,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    controller: phoneController,
                    label: "Phone Number",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    controller: locationController,
                    label: "Facility Location",
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        setState(() {
                          _customName = nameController.text.trim();
                          _customEmail = emailController.text.trim();
                          _customPhone = phoneController.text.trim();
                          _customLocation = locationController.text.trim();
                        });
                        Navigator.pop(ctx);
                        _showSuccessSnackBar("Personal information updated successfully!");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0A5B8E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 2. Security Settings Modal
  void _showSecuritySettingsModal() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool hideCurrent = true;
    bool hideNew = true;
    bool hideConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Security Settings",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Two-Factor Auth Switch Tile
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xffF2F8FD),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffD0E6F7)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.shield_outlined, color: Color(0xff0A5B8E)),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Two-Factor Authentication",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      "OTP required for new logins",
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: twoFactorAuth,
                              activeColor: const Color(0xff0A5B8E),
                              onChanged: (val) {
                                setModalState(() => twoFactorAuth = val);
                                setState(() => twoFactorAuth = val);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Current Password
                      _buildPasswordField(
                        controller: currentPasswordController,
                        label: "Current Password",
                        obscureText: hideCurrent,
                        onToggle: () => setModalState(() => hideCurrent = !hideCurrent),
                        validator: (v) => v?.trim().isEmpty == true ? "Enter current password" : null,
                      ),
                      const SizedBox(height: 12),

                      // New Password
                      _buildPasswordField(
                        controller: newPasswordController,
                        label: "New Password",
                        obscureText: hideNew,
                        onToggle: () => setModalState(() => hideNew = !hideNew),
                        validator: (v) => (v?.length ?? 0) < 6 ? "Minimum 6 characters required" : null,
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password
                      _buildPasswordField(
                        controller: confirmPasswordController,
                        label: "Confirm New Password",
                        obscureText: hideConfirm,
                        onToggle: () => setModalState(() => hideConfirm = !hideConfirm),
                        validator: (v) => v != newPasswordController.text ? "Passwords do not match" : null,
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(ctx);
                            _showSuccessSnackBar("Security credentials updated successfully!");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff0A5B8E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Update Security Settings",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 3. Help & Support Sheet
  void _showHelpSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Help & Support Center",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Need assistance with the Smart Karawala plant operations platform? Reach our support desk directly.",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 20),

              _buildSupportTile(
                icon: Icons.phone_in_talk_rounded,
                title: "Helpline Hotline",
                subtitle: "+94 11 234 5678 (24/7 Available)",
                color: Colors.green,
                onTap: () {
                  Navigator.pop(ctx);
                  _showSuccessSnackBar("Calling Smart Karawala Operations Helpline...");
                },
              ),
              const SizedBox(height: 12),

              _buildSupportTile(
                icon: Icons.email_outlined,
                title: "Email Support Desk",
                subtitle: "support@smartkarawala.com",
                color: const Color(0xff0A5B8E),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSuccessSnackBar("Opening support ticket composer...");
                },
              ),
              const SizedBox(height: 12),

              _buildSupportTile(
                icon: Icons.menu_book_rounded,
                title: "Operations User Manual",
                subtitle: "Guides for batch tracking, salting & sensors",
                color: Colors.orange.shade800,
                onTap: () {
                  Navigator.pop(ctx);
                  _showSuccessSnackBar("Opening Smart Karawala Operations Guide...");
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// 4. Log Out Confirmation
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                "Log Out",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to sign out from your administrative session?",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                auth.logout();
                await StorageService.clearToken();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: const Color(0xff0A5B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xff0A5B8E), size: 20),
        filled: true,
        fillColor: const Color(0xffF2F8FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffD0E6F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffD0E6F7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff0A5B8E), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xff0A5B8E), size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xff0A5B8E),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xffF2F8FD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffD0E6F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffD0E6F7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xff0A5B8E), width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget insightItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget menuOption(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xff0A5B8E).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xff0A5B8E), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? const Color(0xFF121B24) : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          context.tr('admin_profile'),
          style: TextStyle(
            color: darkMode ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Profile Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkMode ? const Color(0xFF1E2A38) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0A5B8E).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xff0A5B8E).withOpacity(0.12),
                        backgroundImage: const AssetImage("assets/images/profile.jpg"),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _showEditProfileDialog,
                          child: Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xff0A5B8E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _customName.isNotEmpty ? _customName : "Sanjaya",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: darkMode ? Colors.white : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "System Administrator",
                          style: TextStyle(
                            fontSize: 13,
                            color: darkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _customEmail.isNotEmpty ? _customEmail : "sanjaya@smartkarawala.com",
                          style: TextStyle(
                            fontSize: 12,
                            color: darkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Profile Insights Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: darkMode ? const Color(0xFF1E2A38) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0A5B8E).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.insights_rounded, color: Color(0xff0A5B8E)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('admin_insights'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: darkMode ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F3F5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      insightItem("142", "Batches\nManaged"),
                      insightItem("450 kg", "Waste\nMonitored"),
                      insightItem("3.2%", "Average\nSalt Level"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Settings List Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: darkMode ? const Color(0xFF1E2A38) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff0A5B8E).withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  menuOption(
                    Icons.person_outline_rounded,
                    context.tr('edit_personal_info'),
                    _showEditProfileDialog,
                  ),
                  menuOption(
                    Icons.lock_outline_rounded,
                    context.tr('security_settings'),
                    _showSecuritySettingsModal,
                  ),
                  Consumer<LanguageProvider>(
                    builder: (context, langProv, child) {
                      final currentLang = langProv.currentLanguage;
                      return menuOption(
                        Icons.language_rounded,
                        context.tr('language'),
                        () => LanguageSelectorSheet.show(context),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentLang.nativeName,
                              style: const TextStyle(
                                color: Color(0xff0A5B8E),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      );
                    },
                  ),
                  menuOption(
                    Icons.dark_mode_outlined,
                    context.tr('dark_mode'),
                    () {},
                    trailing: Switch.adaptive(
                      value: darkMode,
                      activeColor: const Color(0xff0A5B8E),
                      onChanged: (val) {
                        setState(() {
                          darkMode = val;
                        });
                        _showSuccessSnackBar(val ? "Dark mode preview enabled" : "Light mode enabled");
                      },
                    ),
                  ),
                  menuOption(
                    Icons.help_outline_rounded,
                    context.tr('help_and_support'),
                    _showHelpSupportSheet,
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F3F5)),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    ),
                    title: Text(
                      context.tr('log_out'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.red),
                    onTap: _showLogoutConfirmation,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                context.tr('powered_by'),
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

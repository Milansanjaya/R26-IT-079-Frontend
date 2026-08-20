import 'package:flutter/material.dart';
import '../../widgets/Batch/colors.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  bool biometricEnabled = true;
  bool twoFactorEnabled = false;
  bool autoLockEnabled = true;
  bool isUpdatingPassword = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final current = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (current.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all password fields")),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New password must be at least 6 characters long")),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    setState(() => isUpdatingPassword = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    setState(() => isUpdatingPassword = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  InputDecoration _passwordDecoration(String label, bool obscureState, VoidCallback toggleObscure) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary.withOpacity(0.7)),
      suffixIcon: IconButton(
        icon: Icon(
          obscureState ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
        ),
        onPressed: toggleObscure,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Security Settings",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Change Password Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.key_rounded, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        "Change Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent,
                    decoration: _passwordDecoration(
                      "Current Password",
                      obscureCurrent,
                      () => setState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: _passwordDecoration(
                      "New Password",
                      obscureNew,
                      () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: _passwordDecoration(
                      "Confirm New Password",
                      obscureConfirm,
                      () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isUpdatingPassword ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isUpdatingPassword
                          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          : const Text(
                              "Update Password",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Additional Security Toggles
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        "Authentication & Access",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Biometric Login (Face / Fingerprint)",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      "Use biometric sensor for fast sign-in",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: biometricEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => biometricEnabled = val),
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F3F5)),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Two-Factor Authentication (2FA)",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      "Require an SMS or Email OTP code on login",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: twoFactorEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => twoFactorEnabled = val),
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F3F5)),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Auto-Lock Inactive Session",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      "Lock application after 15 minutes of inactivity",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: autoLockEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => autoLockEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Active Sessions Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.devices_rounded, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text(
                        "Active Devices",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_android_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Smart Karawala Mobile (Current Device)",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Active now • Android App",
                              style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

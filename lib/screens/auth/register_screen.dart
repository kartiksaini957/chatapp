import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/auth_service.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showError('Terms & Conditions accept karना zaroori hai');
      return;
    }
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final result = await AuthService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      _showError(result.errorMessage!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: AppTheme.lightMaroon,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightCream,
      body: Stack(
        children: [
          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 180,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.deepMaroon, AppTheme.lightMaroon, Color(0xFFFFF8F0)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Naya Account', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text('Apna account banayein 🙏', style: TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Form
          FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 172,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Step indicator
                    _buildStepBadge(),
                    const SizedBox(height: 24),

                    // Full name
                    _buildLabel('Pura Naam *'),
                    const SizedBox(height: 8),
                    _buildTextFormField(
                      controller: _nameCtrl,
                      hint: 'Apna pura naam likhein',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Naam daalna zaroori hai';
                        if (v.trim().length < 2) return 'Naam kam se kam 2 characters ka hona chahiye';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildLabel('Email Address *'),
                    const SizedBox(height: 8),
                    _buildTextFormField(
                      controller: _emailCtrl,
                      hint: 'aapka@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email daalna zaroori hai';
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(v)) return 'Sahi email format daalen';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone — MANDATORY
                    _buildLabel('Mobile Number * (mandatory)'),
                    const SizedBox(height: 8),
                    _buildPhoneField(),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '⚠️ Mobile number mandatory hai — bina iske account nahi banega',
                        style: TextStyle(color: AppTheme.saffron.withOpacity(0.8), fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildLabel('Password *'),
                    const SizedBox(height: 8),
                    _buildPasswordFormField(
                      controller: _passCtrl,
                      hint: 'Kam se kam 8 characters',
                      obscure: _obscurePass,
                      onToggle: () => setState(() => _obscurePass = !_obscurePass),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password daalna zaroori hai';
                        if (v.length < 8) return 'Password kam se kam 8 characters ka hona chahiye';
                        if (!RegExp(r'[0-9]').hasMatch(v)) return 'Password mein kam se kam ek number hona chahiye';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 16),

                    // Confirm password
                    _buildLabel('Password Confirm Karein *'),
                    const SizedBox(height: 8),
                    _buildPasswordFormField(
                      controller: _confirmPassCtrl,
                      hint: '••••••••',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password confirm karna zaroori hai';
                        if (v != _passCtrl.text) return 'Dono passwords match nahi karte';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Terms checkbox
                    _buildTermsCheckbox(),
                    const SizedBox(height: 24),

                    // Register button
                    _buildRegisterButton(),
                    const SizedBox(height: 20),

                    // Back to login
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Pehle se account hai? ',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Login Karein',
                                style: TextStyle(color: AppTheme.saffron, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.saffron.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.saffron.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.saffron),
            child: const Center(child: Text('1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 10),
          const Text('Apni basic jaankari bharein', style: TextStyle(color: AppTheme.deepMaroon, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(color: AppTheme.deepMaroon, fontSize: 13, fontWeight: FontWeight.w600));
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppTheme.deepMaroon, fontSize: 15),
      decoration: _inputDecoration(hint, icon),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneCtrl,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: (v) {
        if (v == null || v.isEmpty) return '📱 Mobile number mandatory hai';
        if (v.length != 10) return 'Mobile number 10 digits ka hona chahiye';
        if (!RegExp(r'^[6-9]').hasMatch(v)) return 'Sahi Indian mobile number daalen';
        return null;
      },
      style: const TextStyle(color: AppTheme.deepMaroon, fontSize: 15),
      decoration: InputDecoration(
        hintText: '9876543210',
        hintStyle: const TextStyle(color: Color(0xFFBBAA99)),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.phone_android_outlined, color: AppTheme.saffron, size: 20),
              const SizedBox(width: 8),
              Text('+91', style: TextStyle(color: AppTheme.deepMaroon.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 14)),
              Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 20, color: const Color(0xFFDDD0C8)),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.saffron, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.saffron, width: 2.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: AppTheme.deepMaroon, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBAA99)),
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.saffron, size: 20),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[500], size: 20),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE8DDD0), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.saffron, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final pass = _passCtrl.text;
    int strength = 0;
    if (pass.length >= 8) strength++;
    if (pass.contains(RegExp(r'[A-Z]'))) strength++;
    if (pass.contains(RegExp(r'[0-9]'))) strength++;
    if (pass.contains(RegExp(r'[!@#\$%^&*]'))) strength++;

    final labels = ['', 'Kamzor', 'Theek hai', 'Achha', 'Mazboot'];
    final colors = [Colors.transparent, Colors.red, Colors.orange, Colors.yellow[700]!, Colors.green];

    return AnimatedBuilder(
      animation: _passCtrl,
      builder: (_, __) {
        final p = _passCtrl.text;
        int s = 0;
        if (p.length >= 8) s++;
        if (p.contains(RegExp(r'[A-Z]'))) s++;
        if (p.contains(RegExp(r'[0-9]'))) s++;
        if (p.contains(RegExp(r'[!@#\$%^&*]'))) s++;

        if (p.isEmpty) return const SizedBox.shrink();
        return Row(
          children: [
            ...List.generate(4, (i) => Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < s ? colors[s] : const Color(0xFFE0D8D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
            const SizedBox(width: 8),
            Text(s > 0 ? labels[s] : '', style: TextStyle(fontSize: 11, color: colors[s], fontWeight: FontWeight.w600)),
          ],
        );
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _agreedToTerms ? AppTheme.saffron.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _agreedToTerms ? AppTheme.saffron.withOpacity(0.4) : const Color(0xFFE8DDD0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _agreedToTerms ? AppTheme.saffron : Colors.transparent,
                border: Border.all(
                  color: _agreedToTerms ? AppTheme.saffron : const Color(0xFFBBAA99),
                  width: 2,
                ),
              ),
              child: _agreedToTerms
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Main ',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  children: [
                    TextSpan(text: 'Terms & Conditions', style: TextStyle(color: AppTheme.saffron, fontWeight: FontWeight.w600)),
                    TextSpan(text: ' aur '),
                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppTheme.saffron, fontWeight: FontWeight.w600)),
                    TextSpan(text: ' se agree karta/karti hun'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.deepMaroon,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: AppTheme.deepMaroon.withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Account Banayein', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(width: 8),
                  Icon(Icons.how_to_reg_rounded, size: 22),
                ],
              ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBAA99)),
      prefixIcon: Icon(icon, color: AppTheme.saffron, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8DDD0), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.saffron, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
    );
  }
}

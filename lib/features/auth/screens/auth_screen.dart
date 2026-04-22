import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/language_provider.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  final int initialTabIndex;
  const AuthScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Sign-up controllers
  final _signupFormKey = GlobalKey<FormState>();
  final _signupNameCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPhoneCtrl = TextEditingController();
  final _signupPasswordCtrl = TextEditingController();
  final _signupConfirmCtrl = TextEditingController();

  bool _loginPasswordVisible = false;
  bool _signupPasswordVisible = false;
  bool _signupConfirmVisible = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() => _formError = null);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPhoneCtrl.dispose();
    _signupPasswordCtrl.dispose();
    _signupConfirmCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _formError = null);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.signIn(
      email: _loginEmailCtrl.text.trim(),
      password: _loginPasswordCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } else {
      setState(() => _formError = auth.errorMessage ?? 'Login failed');
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _formError = null);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.signUp(
      email: _signupEmailCtrl.text.trim(),
      password: _signupPasswordCtrl.text,
      name: _signupNameCtrl.text.trim(),
      phoneNumber: _signupPhoneCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } else {
      setState(() => _formError = auth.errorMessage ?? 'Registration failed');
    }
  }

  Future<void> _handleGoogle() async {
    setState(() => _formError = null);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } else {
      setState(() => _formError = auth.errorMessage ?? 'Google sign-in failed');
    }
  }

  Future<void> _handleGuest() async {
    setState(() => _formError = null);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.signInAsGuest();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } else {
      setState(() =>
          _formError = auth.errorMessage ?? 'Could not continue as guest');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    // Logo & Title
                    _buildHeader(),

                    // Tab Bar
                    _buildTabBar(),

                    // Tab Views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [_buildLoginTab(), _buildSignUpTab()],
                      ),
                    ),
                  ],
                ),
                // Language picker — top-right corner
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildLanguageButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingXL,
        AppSizes.paddingXXL,
        AppSizes.paddingXL,
        AppSizes.paddingM,
      ),
      child: Column(
        children: [
          // App logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: AppSizes.iconXL,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            AppStrings.appName,
            style: const TextStyle(
              fontSize: AppFonts.headingL,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            AppStrings.appTagline,
            style: const TextStyle(
              fontSize: AppFonts.bodyM,
              color: AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingXL,
        vertical: AppSizes.paddingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.lightTextSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppFonts.bodyM,
        ),
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  // ─── Login Tab ─────────────────────────────────────────────────────────────

  Widget _buildLoginTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXL,
            vertical: AppSizes.paddingM,
          ),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  controller: _loginEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSizes.spacingM),
                CustomTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
                  controller: _loginPasswordCtrl,
                  obscureText: !_loginPasswordVisible,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: _loginPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () => setState(
                    () => _loginPasswordVisible = !_loginPasswordVisible,
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: AppSizes.spacingS),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: AppFonts.bodyS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingL),
                CustomButton(
                  label: AppStrings.login,
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildDivider(),
                const SizedBox(height: AppSizes.spacingM),
                _buildGoogleButton(auth.isLoading),
                const SizedBox(height: AppSizes.spacingM),
                _buildDivider(),
                const SizedBox(height: AppSizes.spacingM),
                _buildGuestButton(auth.isLoading),
                if (_formError != null) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  _ErrorBanner(message: _formError!),
                ],
                const SizedBox(height: AppSizes.spacingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Sign-Up Tab ───────────────────────────────────────────────────────────

  Widget _buildSignUpTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingXL,
            vertical: AppSizes.paddingM,
          ),
          child: Form(
            key: _signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Jane Doe',
                  controller: _signupNameCtrl,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: AppSizes.spacingM),
                CustomTextField(
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  controller: _signupEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildPhoneField(),
                const SizedBox(height: AppSizes.spacingM),
                CustomTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
                  controller: _signupPasswordCtrl,
                  obscureText: !_signupPasswordVisible,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: _signupPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () => setState(
                    () => _signupPasswordVisible = !_signupPasswordVisible,
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: AppSizes.spacingM),
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  hint: '••••••••',
                  controller: _signupConfirmCtrl,
                  obscureText: !_signupConfirmVisible,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: _signupConfirmVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () => setState(
                    () => _signupConfirmVisible = !_signupConfirmVisible,
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please confirm password';
                    if (v != _signupPasswordCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacingL),
                CustomButton(
                  label: AppStrings.signup,
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _handleSignUp,
                ),
                const SizedBox(height: AppSizes.spacingM),
                _buildDivider(),
                const SizedBox(height: AppSizes.spacingM),
                _buildGuestButton(auth.isLoading),
                if (_formError != null) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  _ErrorBanner(message: _formError!),
                ],
                const SizedBox(height: AppSizes.spacingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Phone Field with Country Code ─────────────────────────────────────────

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: AppFonts.titleM,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        TextFormField(
          controller: _signupPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+1 555 000 0000',
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: AppSizes.spacingS),
                  Icon(Icons.phone_outlined, color: AppColors.primary),
                  SizedBox(width: AppSizes.spacingXS),
                  Text(
                    '+',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: AppFonts.bodyM,
                    ),
                  ),
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty)
              return 'Phone number is required';
            final digits = v.replaceAll(RegExp(r'\D'), '');
            if (digits.length < 7) return 'Enter a valid phone number';
            return null;
          },
        ),
      ],
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: AppFonts.bodyS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildGoogleButton(bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : _handleGoogle,
      icon: Image.network(
        'https://developers.google.com/identity/images/g-logo.png',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
      ),
      label: Text(
        AppStrings.signInWithGoogle,
        style: const TextStyle(
          fontSize: AppFonts.bodyM,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightM),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),
    );
  }

  // ─── Validators ────────────────────────────────────────────────────────────

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim()))
      return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ─── Language Button ─────────────────────────────────────────────────────────

  Widget _buildLanguageButton() {
    final currentLang = context.watch<LanguageProvider>().currentLanguage;
    return PopupMenuButton<String>(
      tooltip: 'Change language',
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
          ],
        ),
        child: const Icon(Icons.language_rounded,
            color: AppColors.primary, size: 20),
      ),
      onSelected: (code) =>
          context.read<LanguageProvider>().changeLanguage(code),
      itemBuilder: (_) => LanguageProvider.supportedLanguages
          .map(
            (l) => PopupMenuItem<String>(
              value: l.code,
              child: Row(
                children: [
                  Text(l.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(l.nativeName),
                  if (currentLang == l.code) ...[
                    const Spacer(),
                    const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 18),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  // ─── Guest Button ─────────────────────────────────────────────────────────────

  Widget _buildGuestButton(bool isLoading) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : _handleGuest,
      icon: const Icon(Icons.person_outline_rounded, size: 20),
      label: const Text(
        'Continue as Guest',
        style: TextStyle(
          fontSize: AppFonts.bodyM,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextSecondary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightM),
        foregroundColor: AppColors.lightTextSecondary,
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.error.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: AppColors.error, fontSize: AppFonts.bodyS),
            ),
          ),
        ],
      ),
    );
  }
}

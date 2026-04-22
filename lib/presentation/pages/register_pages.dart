import 'package:flutter/material.dart';
import 'app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  String? _selectedRole;
  final List<String> _roles = [
    'Admin Gudang',
    'Staff Gudang',
    'Supervisor',
    'Manajer',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap setujui syarat dan ketentuan'),
          backgroundColor: AppTheme.statusRejected,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Akun berhasil dibuat!',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Top gradient header
          Container(
            height: size.height * 0.28,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Header
                      _buildHeader(),

                      const SizedBox(height: 28),

                      // Form card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.12),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Buat Akun Baru',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Isi data berikut untuk mendaftar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Nama Lengkap
                                _buildInputLabel('Nama Lengkap'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _namaController,
                                  hint: 'Masukkan nama lengkap',
                                  icon: Icons.person_outline_rounded,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Nama tidak boleh kosong';
                                    }
                                    if (val.length < 3) {
                                      return 'Nama minimal 3 karakter';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Email
                                _buildInputLabel('Alamat Email'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'contoh@email.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    if (!val.contains('@') ||
                                        !val.contains('.')) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Username
                                _buildInputLabel('Username'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _usernameController,
                                  hint: 'Buat username unik',
                                  icon: Icons.alternate_email_rounded,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Username tidak boleh kosong';
                                    }
                                    if (val.length < 4) {
                                      return 'Username minimal 4 karakter';
                                    }
                                    if (val.contains(' ')) {
                                      return 'Username tidak boleh mengandung spasi';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Role dropdown
                                _buildInputLabel('Jabatan / Peran'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  hint: Text(
                                    'Pilih jabatan Anda',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppTheme.primary,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                      color: AppTheme.primary,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: AppTheme.primaryLight
                                            .withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: AppTheme.statusRejected,
                                        width: 1.5,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  items: _roles.map((role) {
                                    return DropdownMenuItem(
                                      value: role,
                                      child: Text(role,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textDark)),
                                    );
                                  }).toList(),
                                  onChanged: (val) =>
                                      setState(() => _selectedRole = val),
                                  validator: (val) {
                                    if (val == null) {
                                      return 'Harap pilih jabatan';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 18),

                                // Password
                                _buildInputLabel('Kata Sandi'),
                                const SizedBox(height: 8),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  hint: '••••••••',
                                  isVisible: _isPasswordVisible,
                                  onToggle: () => setState(() =>
                                      _isPasswordVisible = !_isPasswordVisible),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Kata sandi tidak boleh kosong';
                                    }
                                    if (val.length < 8) {
                                      return 'Minimal 8 karakter';
                                    }
                                    return null;
                                  },
                                ),

                                // Password strength indicator
                                const SizedBox(height: 8),
                                _buildPasswordStrength(_passwordController.text),

                                const SizedBox(height: 18),

                                // Confirm Password
                                _buildInputLabel('Konfirmasi Kata Sandi'),
                                const SizedBox(height: 8),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  hint: '••••••••',
                                  isVisible: _isConfirmPasswordVisible,
                                  onToggle: () => setState(() =>
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Harap konfirmasi kata sandi';
                                    }
                                    if (val != _passwordController.text) {
                                      return 'Kata sandi tidak cocok';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Terms & conditions
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (val) => setState(
                                            () => _agreeToTerms = val!),
                                        activeColor: AppTheme.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Saya menyetujui ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                          ),
                                          children: const [
                                            TextSpan(
                                              text: 'Syarat & Ketentuan',
                                              style: TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(text: ' dan '),
                                            TextSpan(
                                              text: 'Kebijakan Privasi',
                                              style: TextStyle(
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(text: ' GudangPro'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 28),

                                // Register button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          AppTheme.primary
                                              .withOpacity(0.6),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ).copyWith(
                                      elevation:
                                          WidgetStateProperty.resolveWith(
                                        (states) => states
                                                .contains(WidgetState.pressed)
                                            ? 2
                                            : 8,
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.person_add_rounded,
                                                  size: 20),
                                              SizedBox(width: 10),
                                              Text(
                                                'Daftar Sekarang',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                        thickness: 1.5,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        'atau',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade200,
                                        thickness: 1.5,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Login link
                                Center(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushReplacementNamed(
                                        context, '/login'),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Sudah punya akun? ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'Masuk di sini',
                                            style: TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.warehouse_rounded,
                size: 28,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'GudangPro',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Daftar akun baru',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryDark,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppTheme.primaryLight.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.statusRejected, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.statusRejected, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 15, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          letterSpacing: 3,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppTheme.primary,
          size: 20,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off_outlined,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppTheme.primaryLight.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.statusRejected, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.statusRejected, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordStrength(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    Color strengthColor;
    String strengthLabel;

    switch (strength) {
      case 1:
        strengthColor = AppTheme.statusRejected;
        strengthLabel = 'Lemah';
        break;
      case 2:
        strengthColor = Colors.orangeAccent;
        strengthLabel = 'Cukup';
        break;
      case 3:
        strengthColor = Colors.amber;
        strengthLabel = 'Kuat';
        break;
      case 4:
        strengthColor = AppTheme.statusApproved;
        strengthLabel = 'Sangat Kuat';
        break;
      default:
        strengthColor = Colors.grey;
        strengthLabel = '';
    }

    return Row(
      children: [
        ...List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: index < strength
                    ? strengthColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          strengthLabel,
          style: TextStyle(
            fontSize: 11,
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

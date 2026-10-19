import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.signInWithEmail(
        email: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تسجيل الدخول بنجاح!'),
              backgroundColor: AppColors.primaryTeal,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('اسم المستخدم أو كلمة المرور غير صحيحة.'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تسجيل الدخول: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF006D77),
              Color(0xFF00897B),
              Color(0xFF00796B),
            ],
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                top: -40,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                top: 80,
                right: -50,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Bottom Mosque Silhouette Graphic
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 100),
                  painter: MosqueSilhouettePainter(),
                ),
              ),

              // Main Scrollable Content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Central Logo & Header (Exactly as Screenshot 2)
                        _buildHeaderLogo(),

                        const SizedBox(height: 20),

                        // Login Card (Rounded card matching Screenshot 2)
                        _buildLoginCard(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderLogo() {
    return Column(
      children: [
        // Rounded Square Logo Card with Gold Border
        Container(
          width: 95,
          height: 95,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE8C882), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.mosque_rounded,
                  color: AppColors.primaryTeal,
                  size: 44,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Title with side gold accent lines
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 1.5,
              color: const Color(0xFFE8C882),
            ),
            const SizedBox(width: 8),
            Text(
              'ساداتنا أهل بدر الكرام',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 1.5,
              color: const Color(0xFFE8C882),
            ),
          ],
        ),

        const SizedBox(height: 2),

        // Subtitle
        Text(
          'لحفظ القرآن الكريم',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE8C882),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Star & Decorative Line
            _buildGoldDividerWithStar(),

            const SizedBox(height: 6),

            Center(
              child: Text(
                'مرحبًا بك',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),

            Center(
              child: Text(
                'يرجى تسجيل الدخول للمتابعة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),

            const SizedBox(height: 6),

            _buildGoldDividerWithStar(),

            const SizedBox(height: 20),

            // Field 1: Username
            _buildFieldLabel('اسم المستخدم', Icons.person),
            const SizedBox(height: 6),
            TextFormField(
              controller: _usernameController,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textDark),
              decoration: _inputDecoration(
                hintText: 'ادخل اسم المستخدم',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال اسم المستخدم';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Field 2: Password
            _buildFieldLabel('كلمة المرور', Icons.lock),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textDark),
              decoration: _inputDecoration(
                hintText: 'أدخل كلمة المرور',
                prefixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.primaryTeal,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            // Checkbox: Remember Me
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: AppColors.textMuted, width: 1.2),
                    onChanged: (val) {
                      setState(() => _rememberMe = val ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'تذكرني',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 1,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'تسجيل الدخول',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Forgot password & Demo Credentials
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'هل نسيت كلمة المرور؟ ',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء مراجعة إدارة المعهد لإعادة تعيين كلمة المرور'),
                        ),
                      );
                    },
                    child: Text(
                      'تواصل مع المدير',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                'للتجربة: admin / 1234',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppColors.inputHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldDividerWithStar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE8C882).withValues(alpha: 0.6),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.star_rate_rounded,
            size: 14,
            color: Color(0xFFC89336),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE8C882).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, IconData icon) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          icon,
          size: 16,
          color: AppColors.primaryTeal,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.cairo(
        color: AppColors.inputHint,
        fontSize: 13,
      ),
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryTeal,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
      ),
    );
  }
}

// Custom Painter for subtle Mosque Silhouette at bottom
class MosqueSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final path = Path();
    final h = size.height;
    final w = size.width;

    path.moveTo(0, h);
    path.lineTo(0, h - 25);

    // Minaret 1
    path.lineTo(w * 0.1, h - 25);
    path.lineTo(w * 0.1, h - 75);
    path.lineTo(w * 0.11, h - 85);
    path.lineTo(w * 0.12, h - 75);
    path.lineTo(w * 0.12, h - 25);

    // Dome 1
    path.lineTo(w * 0.25, h - 25);
    path.arcToPoint(
      Offset(w * 0.45, h - 25),
      radius: const Radius.circular(40),
      clockwise: false,
    );

    // Central Main Dome
    path.lineTo(w * 0.5, h - 25);
    path.arcToPoint(
      Offset(w * 0.75, h - 25),
      radius: const Radius.circular(60),
      clockwise: false,
    );

    // Minaret 2
    path.lineTo(w * 0.88, h - 25);
    path.lineTo(w * 0.88, h - 80);
    path.lineTo(w * 0.89, h - 90);
    path.lineTo(w * 0.90, h - 80);
    path.lineTo(w * 0.90, h - 25);

    path.lineTo(w, h - 25);
    path.lineTo(w, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:ahl_bader_institute/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // المتحكمات بحقول النصوص
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLogin = true; // هل الواجهة الآن تسجيل دخول أم إنشاء حساب جديد؟
  bool isLoading = false; // لمتابعة حالة التحميل عند الضغط

  // دالة التعامل مع التسجيل والإنشاء
  Future<void> _submitAuthForm() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال البريد وكلمة السر')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        // 1️⃣ تسجيل الدخول بحساب موجود
        UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'أهلاً بك! تم تسجيل الدخول: ${credential.user?.email}',
            ),
          ),
        );
      } else {
        // 2️⃣ إنشاء حساب جديد
        UserCredential credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء الحساب بنجاح! UID: ${credential.user?.uid}',
            ),
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 3️⃣ التعامل مع أخطاء Firebase الخاصة بالحسابات
      String message = 'حدث خطأ ما';
      if (e.code == 'weak-password') {
        message = 'كلمة السر ضعيفة جداً (يجب أن تكون 6 خانات على الأقل)';
      } else if (e.code == 'email-already-in-use') {
        message = 'هذا البريد الإلكتروني مستخدم بالفعل';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صحيحة';
      } else if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'البريد أو كلمة السر غير صحيحة';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // حقل البريد الإلكتروني
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            // حقل كلمة السر
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة السر',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            // زر الإرسال (تحميل أو زر)
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _submitAuthForm,
                    child: Text(isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد'),
                  ),
            const SizedBox(height: 12),

            // زر التبديل بين تسجيل الدخول والإنشاء
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? 'ليس لديك حساب؟ أنشئ حساباً جديداً'
                    : 'لديك حساب بالفعل؟ سجل دخولك',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

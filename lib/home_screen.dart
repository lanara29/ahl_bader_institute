import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _noteController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser; // المستخدم الحالي المسجل

  // 1️⃣ دالة إضافة ملاحظة/بيانات جديدة إلى Firestore
  Future<void> _addNote() async {
    final noteText = _noteController.text.trim();
    if (noteText.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('notes').add({
        'text': noteText,
        'userId': user?.uid, // ربط الملاحظة برقم المستخدم
        'userEmail': user?.email, // إيميل المستخدم
        'createdAt': Timestamp.now(), // وقت الإضافة
      });

      _noteController.clear(); // مسح الحقل بعد الإضافة
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الإضافة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 2️⃣ دالة حذف ملاحظة من Firestore
  Future<void> _deleteNote(String docId) async {
    await FirebaseFirestore.instance.collection('notes').doc(docId).delete();
  }

  // 3️⃣ دالة تسجيل الخروج
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات اللحظية (Firestore)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut, // زر تسجيل الخروج
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // بطاقة الترحيب بالمستخدم
            Card(
              color: Colors.teal.shade50,
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.teal),
                title: Text('المستخدم: ${user?.email ?? 'مجهول'}'),
                subtitle: Text(
                  'UID: ${user?.uid}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // حقل إضافة ملاحظة جديدة
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب ملاحظة أو بياناً جديداً...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addNote,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4️⃣ القراءة اللحظية من Firestore عبر StreamBuilder
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // الاستماع لمجموعة notes مرتبة حسب الوقت
                stream: FirebaseFirestore.instance
                    .collection('notes')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('لا توجد بيانات حالياً. أضف أول ملاحظة!'),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(data['text'] ?? ''),
                          subtitle: Text('بواسطة: ${data['userEmail']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteNote(docId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

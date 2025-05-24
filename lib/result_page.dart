import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String userId;
  late Stream<QuerySnapshot> _resultsStream;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? '';
    _resultsStream = _firestore
        .collection('test_results')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _goToProfile() {
    Navigator.pushReplacementNamed(context, '/profile');
  }

  Widget _buildResultCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final DateTime timestamp =
        (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final String testType = data['testType'] ?? 'Unknown Test';
    final String result = data['result'] ?? 'No result';
    final double similarity = (data['similarity'] ?? 0).toDouble();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.medical_information, color: Colors.deepPurple),
        title: Text(testType,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Result: $result', style: GoogleFonts.poppins()),
            if (similarity > 0)
              Text(
                'Similarity Score: ${(similarity * 100).toStringAsFixed(1)}%',
                style:
                    GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              ),
            Text(
              'Date: ${timestamp.toLocal().toString().split('.')[0]}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Test Results', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _resultsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading results'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No test results found.\nPlease complete some tests first.',
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) => _buildResultCard(docs[index]),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) _goToHome();
          if (index == 1) _goToProfile();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class McqUnder18 extends StatefulWidget {
  const McqUnder18({Key? key}) : super(key: key);

  @override
  State<McqUnder18> createState() => _McqUnder18State();
}

class _McqUnder18State extends State<McqUnder18> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // List of 10 questions (Yes/No)
  final List<String> questions = [
    'Does your child make eye contact when you talk to them?',
    'Does your child respond to their name?',
    'Does your child smile back at you?',
    'Does your child babble or make sounds?',
    'Does your child show interest in faces?',
    'Does your child reach out to be picked up?',
    'Does your child imitate sounds or movements?',
    'Does your child show curiosity about objects?',
    'Does your child follow your gestures?',
    'Does your child enjoy playing with you?',
  ];

  // Store answers, true = Yes, false = No, null = unanswered
  List<bool?> answers = List<bool?>.filled(10, null);

  bool isSubmitting = false;
  String? resultText;

  int calculateScore() {
    int score = 0;
    for (var ans in answers) {
      if (ans == true) {
        score++;
      }
    }
    return score;
  }

  void _submit() {
    if (answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    int totalScore = calculateScore();
    double percent = totalScore / questions.length;

    if (percent > 0.7) {
      resultText =
          'Your child may be at risk for autism. Please visit a specialist.';
    } else {
      resultText = 'Your child shows no signs of autism at this time.';
    }

    // TODO: Save results to Firestore with timestamp under current user

    setState(() {
      isSubmitting = false;
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Under 18 Months Test', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}. ${questions[index]}',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title:
                                      Text('Yes', style: GoogleFonts.poppins()),
                                  value: true,
                                  groupValue: answers[index],
                                  onChanged: (val) {
                                    setState(() {
                                      answers[index] = val;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title:
                                      Text('No', style: GoogleFonts.poppins()),
                                  value: false,
                                  groupValue: answers[index],
                                  onChanged: (val) {
                                    setState(() {
                                      answers[index] = val;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (resultText != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  resultText!,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: resultText!.contains('risk')
                        ? Colors.red
                        : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Submit',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

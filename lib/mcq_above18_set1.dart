import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class McqAbove18Set1 extends StatefulWidget {
  const McqAbove18Set1({Key? key}) : super(key: key);

  @override
  State<McqAbove18Set1> createState() => _McqAbove18Set1State();
}

class _McqAbove18Set1State extends State<McqAbove18Set1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> questions = [
    'Does your child play pretend or imaginary games?',
    'Does your child point to things to show interest?',
    'Does your child make eye contact during conversations?',
    'Does your child respond to their name consistently?',
    'Does your child use simple gestures like waving or nodding?',
    'Does your child show interest in other children?',
    'Does your child imitate your actions or words?',
    'Does your child have varied facial expressions?',
    'Does your child understand simple instructions?',
    'Does your child engage in back-and-forth play?',
    'Does your child respond to emotions of others?',
    'Does your child show curiosity about surroundings?',
    'Does your child use single words meaningfully?',
    'Does your child play with toys appropriately?',
    'Does your child engage in social games?',
    'Does your child express needs verbally?',
    'Does your child maintain eye contact when listening?',
    'Does your child enjoy being around people?',
    'Does your child point to objects to get attention?',
    'Does your child show interest in shared activities?',
  ];

  // Answers: 0 = No, 1 = Somewhat, 2 = Yes
  List<int?> answers = List<int?>.filled(20, null);

  bool isSubmitting = false;
  String? resultText;

  double calculateScore() {
    double score = 0.0;
    for (var ans in answers) {
      if (ans == 2) {
        score += 1.0;
      } else if (ans == 1) {
        score += 0.5;
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

    double totalScore = calculateScore();
    double percent = totalScore / questions.length;

    // Store result in state for now; actual logic depends on combining with set2
    // You may want to pass this score to the next screen

    // For now, just show message
    resultText =
        'You scored ${(percent * 100).toStringAsFixed(1)}% on this section.';

    // TODO: Save this partial score to Firestore

    setState(() {
      isSubmitting = false;
    });

    // Navigate to the next set (mcq_above18_set2)
    Navigator.pushReplacementNamed(context, '/mcq_above18_set2');
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
        title:
            Text('Above 18 Months Test - Set 1', style: GoogleFonts.poppins()),
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
                                child: RadioListTile<int>(
                                  title:
                                      Text('No', style: GoogleFonts.poppins()),
                                  value: 0,
                                  groupValue: answers[index],
                                  onChanged: (val) {
                                    setState(() {
                                      answers[index] = val;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title: Text('Somewhat',
                                      style: GoogleFonts.poppins()),
                                  value: 1,
                                  groupValue: answers[index],
                                  onChanged: (val) {
                                    setState(() {
                                      answers[index] = val;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<int>(
                                  title:
                                      Text('Yes', style: GoogleFonts.poppins()),
                                  value: 2,
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
                    color: Colors.deepPurple,
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
                'Next',
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

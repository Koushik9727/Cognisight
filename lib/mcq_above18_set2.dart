import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class McqAbove18Set2 extends StatefulWidget {
  const McqAbove18Set2({Key? key}) : super(key: key);

  @override
  State<McqAbove18Set2> createState() => _McqAbove18Set2State();
}

class _McqAbove18Set2State extends State<McqAbove18Set2> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> questions = [
    'Does your child have difficulty making friends?',
    'Does your child repeat actions or movements?',
    'Does your child get upset by minor changes?',
    'Does your child have unusual reactions to sounds?',
    'Does your child avoid eye contact?',
    'Does your child flap their hands when excited?',
    'Does your child prefer to play alone?',
    'Does your child have trouble understanding feelings?',
    'Does your child resist cuddling or being held?',
    'Does your child have difficulty with transitions?',
  ];

  // Answers: 0 = No, 1 = Somewhat, 2 = Yes
  List<int?> answers = List<int?>.filled(10, null);

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

  Future<double> fetchSet1Score() async {
    // TODO: Fetch set1 score from Firestore for current user
    // For now, return a dummy value
    return 15.0; // dummy value for 20 questions
  }

  void _submit() async {
    if (answers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    double set2Score = calculateScore();
    double set1Score = await fetchSet1Score();

    double totalScore = set1Score + set2Score;
    double maxScore = 20 + 10; // total questions

    double percent = totalScore / maxScore;

    // TODO: Save combined score and timestamp in Firestore

    setState(() {
      isSubmitting = false;
      resultText = 'Combined score: ${(percent * 100).toStringAsFixed(1)}%';
    });

    // TODO: Based on score and user age, navigate to image naming or sentence reading page
    if (percent <= 0.7) {
      // No autism
      Navigator.pushReplacementNamed(context, '/result',
          arguments: {'result': 'No Autism detected'});
    } else {
      // Autism likely
      // For demo, just navigate to image page
      Navigator.pushReplacementNamed(context, '/image_page');
    }
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
            Text('Above 18 Months Test - Set 2', style: GoogleFonts.poppins()),
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

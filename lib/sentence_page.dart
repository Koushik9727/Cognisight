import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SentencePage extends StatefulWidget {
  const SentencePage({Key? key}) : super(key: key);

  @override
  State<SentencePage> createState() => _SentencePageState();
}

class _SentencePageState extends State<SentencePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String sentenceToRead = "The quick brown fox jumps over the lazy dog";
  late stt.SpeechToText speech;
  bool speechAvailable = false;
  bool isListening = false;
  String recognizedText = '';
  double similarity = 0.0;
  String feedback = '';

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() {
            isListening = false;
          });
          _evaluateSimilarity();
        }
      },
      onError: (error) {
        setState(() {
          isListening = false;
          feedback = 'Error: ${error.errorMsg}';
        });
      },
    );
    setState(() {
      speechAvailable = available;
    });
  }

  void _startListening() async {
    if (!speechAvailable) {
      setState(() {
        feedback = 'Speech recognition not available';
      });
      return;
    }
    setState(() {
      recognizedText = '';
      feedback = '';
      similarity = 0.0;
      isListening = true;
    });
    await speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords.toLowerCase();
        });
      },
      listenFor: Duration(seconds: 10),
    );
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {
      isListening = false;
    });
  }

  // Simple similarity based on word overlap percentage
  void _evaluateSimilarity() {
    List<String> originalWords =
        sentenceToRead.toLowerCase().split(RegExp(r'\s+'));
    List<String> recognizedWords = recognizedText.split(RegExp(r'\s+'));

    if (recognizedWords.isEmpty) {
      setState(() {
        feedback = 'No speech detected.';
        similarity = 0.0;
      });
      return;
    }

    int matches = 0;
    for (var word in recognizedWords) {
      if (originalWords.contains(word)) {
        matches++;
      }
    }

    double sim = matches / originalWords.length;
    setState(() {
      similarity = sim;
      if (sim >= 0.7) {
        feedback = 'Good job! Similarity: ${(sim * 100).toStringAsFixed(1)}%';
      } else {
        feedback =
            'Low similarity: ${(sim * 100).toStringAsFixed(1)}%. Please try again or visit a specialist.';
      }
    });
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _goToResultPage() {
    // TODO: Save similarity and result to Firestore here
    Navigator.pushReplacementNamed(context, '/result_page');
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentence Reading Task', style: GoogleFonts.poppins()),
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
            Text(
              'Please read the following sentence aloud:',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sentenceToRead,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: isListening ? _stopListening : _startListening,
              icon: Icon(isListening ? Icons.mic_off : Icons.mic),
              label: Text(isListening ? 'Stop Recording' : 'Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'You said: $recognizedText',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              feedback,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:
                    feedback.startsWith('Good job') ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: feedback.isNotEmpty ? _goToResultPage : null,
              child: Text('Finish Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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

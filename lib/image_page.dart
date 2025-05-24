import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, String>> images = [
    {'image': 'assets/images/apple.png', 'label': 'apple'},
    {'image': 'assets/images/dog.png', 'label': 'dog'},
    {'image': 'assets/images/ball.png', 'label': 'ball'},
    {'image': 'assets/images/car.png', 'label': 'car'},
    {'image': 'assets/images/cat.png', 'label': 'cat'},
  ];

  int currentIndex = 0;
  bool isListening = false;
  String recognizedText = '';
  String feedback = '';
  late stt.SpeechToText speech;
  bool speechAvailable = false;

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
          _evaluateAnswer();
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
      isListening = true;
    });
    await speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords.toLowerCase();
        });
      },
      listenFor: Duration(seconds: 5),
    );
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {
      isListening = false;
    });
  }

  void _evaluateAnswer() {
    String expected = images[currentIndex]['label']!;
    if (recognizedText.trim() == expected.toLowerCase()) {
      setState(() {
        feedback = 'Correct!';
      });
    } else {
      setState(() {
        feedback = 'Incorrect, you said: "$recognizedText"';
      });
    }
  }

  void _nextImage() {
    if (currentIndex < images.length - 1) {
      setState(() {
        currentIndex++;
        recognizedText = '';
        feedback = '';
        isListening = false;
      });
    } else {
      // TODO: Save results in Firestore
      // TODO: Navigate to next page (sentence reading or result)
      Navigator.pushReplacementNamed(context, '/sentence_page');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = images[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Picture Naming Task', style: GoogleFonts.poppins()),
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
              'Image ${currentIndex + 1} of ${images.length}',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Image.asset(
                currentImage['image']!,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Speak the name of the object shown',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 10),
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
            SizedBox(height: 15),
            Text(
              'You said: $recognizedText',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            Text(
              feedback,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: feedback == 'Correct!' ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: feedback.isNotEmpty ? _nextImage : null,
              child: Text('Next'),
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

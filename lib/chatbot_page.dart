import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final String _openAiApiKey = 'YOUR_OPENAI_API_KEY'; // <-- Add your key here

  List<Map<String, String>> _messages = [
    {
      'role': 'system',
      'content':
          '''You are a helpful autism specialist assistant chatbot. You have knowledge of autism diagnosis, symptoms, therapy, and treatments. You also have access to a predefined list of 10 doctors specializing in autism with their names, specialties, and locations. When the user asks for doctors, recommend from this list appropriately.

Doctors:
1. Dr. Aisha Patel - Pediatric Neurologist - Mumbai
2. Dr. Ravi Sharma - Child Psychiatrist - Delhi
3. Dr. Neha Gupta - Developmental Pediatrician - Bangalore
4. Dr. Sanjay Mehta - Clinical Psychologist - Chennai
5. Dr. Priya Iyer - Pediatrician - Hyderabad
6. Dr. Amit Desai - Child Psychologist - Pune
7. Dr. Kavita Reddy - Neurodevelopmental Specialist - Kolkata
8. Dr. Suresh Rao - Autism Therapist - Ahmedabad
9. Dr. Anjali Verma - Child Neurologist - Lucknow
10. Dr. Rajesh Kumar - Behavioral Therapist - Jaipur
'''
    },
  ];

  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': input});
      _isLoading = true;
    });
    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': _messages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String botMessage = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({'role': 'assistant', 'content': botMessage});
          _isLoading = false;
        });
        // Scroll to bottom after a delay to let the UI update
        await Future.delayed(const Duration(milliseconds: 100));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                'Sorry, I am unable to answer right now. Please try again later.'
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              'An error occurred while processing your request. Please check your internet connection.'
        });
        _isLoading = false;
      });
    }
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

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    final bgColor = isUser ? Colors.deepPurple : Colors.grey[200];
    final textColor = isUser ? Colors.white : Colors.black87;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16))
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
            ),
            padding: const EdgeInsets.all(14),
            child: Text(
              message['content'] ?? '',
              style: GoogleFonts.poppins(color: textColor, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatMessages =
        _messages.where((msg) => msg['role'] != 'system').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cognisight Chatbot', style: GoogleFonts.poppins()),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatMessages.length,
              itemBuilder: (context, index) =>
                  _buildMessageBubble(chatMessages[index]),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.poppins(),
                    decoration: const InputDecoration(
                      hintText: 'Ask me about autism or doctors...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _isLoading ? null : _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Chatbot considered Profile or separate tab if added
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

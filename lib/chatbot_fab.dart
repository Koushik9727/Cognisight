import 'package:flutter/material.dart';
import 'chatbot_page.dart';

class ChatbotFab extends StatelessWidget {
  const ChatbotFab({Key? key}) : super(key: key);

  void _openChatbot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const ChatbotPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _openChatbot(context),
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('Need any help?'),
      backgroundColor: Colors.deepPurple,
      heroTag: 'chatbot_fab',
    );
  }
}

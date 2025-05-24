import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'registration.dart';
import 'forgot_password.dart';
import 'code_verification_page.dart';
import 'home.dart';
import 'profile.dart';
import 'mcq_under18.dart';
import 'mcq_above18_set1.dart';
import 'mcq_above18_set2.dart';
import 'image_page.dart';
import 'sentence_page.dart';
import 'result_page.dart';
import 'chatbot_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CognisightApp());
}

class CognisightApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognisight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        '/code-verification': (context) => CodeVerificationPage(
              email: '',
            ),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
        '/mcq-under18': (context) => McqUnder18(),
        '/mcq-above18-set1': (context) => McqAbove18Set1(),
        '/mcq-above18-set2': (context) => McqAbove18Set2(),
        '/image-page': (context) => ImagePage(),
        '/sentence-page': (context) => SentencePage(),
        '/result': (context) => ResultPage(),
        '/chatbot': (context) => ChatbotPage(),
      },
    );
  }
}

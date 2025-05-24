import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  Future<void> sendVerificationCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        errorMessage = 'Please enter a valid email';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    int code = 1000 + Random().nextInt(9000); // 4-digit code
    try {
      final response = await http.post(
        Uri.parse(
            'https://<your-region>-<your-project-id>.cloudfunctions.net/sendEmailCode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code.toString()}),
      );

      if (response.statusCode == 200) {
        Navigator.pushNamed(context, '/code-verification', arguments: {
          'email': email,
          'code': code.toString(),
        });
      } else {
        setState(() {
          errorMessage = 'Failed to send email. Try again later.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Enter your email to receive a verification code.',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : sendVerificationCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Send Code'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}

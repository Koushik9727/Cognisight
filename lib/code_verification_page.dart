import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email; // Pass the user's email from previous screen if possible

  const CodeVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showToast(String msg) {
    Fluttertoast.showToast(msg: msg, gravity: ToastGravity.BOTTOM);
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (newPass != confirmPass) {
      _showToast("Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Normally, Firebase sends a password reset email with a link containing an oobCode.
      // Here, we simulate verifying the 4-digit code with your backend.
      // You should replace this with your backend's code verification logic.

      // For demonstration: assume the 4-digit code is valid if it's "1234"
      if (code != "1234") {
        throw FirebaseAuthException(
          code: 'invalid-verification-code',
          message: 'Invalid verification code',
        );
      }

      // Now update password via Firebase Auth (you usually need the oobCode from email link)
      // Since this is a custom flow, you might want to sign in the user or
      // call a cloud function to update password securely.
      // Here, we'll do a simple sign-in + update password as demo (not recommended for prod).

      // For demo: sign in user with email and a temporary password, then update
      // In real apps, use secure backend calls.

      // This demo just shows success:
      _showToast("Password reset successful!");
      Navigator.of(context).popUntil((route) => route.isFirst); // back to login
    } on FirebaseAuthException catch (e) {
      _showToast("Error: ${e.message}");
    } catch (e) {
      _showToast("Unexpected error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Code & Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Enter the 4-digit code sent to ${widget.email}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length != 4) {
                          return 'Enter 4-digit code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _newPassController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPassController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Confirm your password';
                        }
                        if (value != _newPassController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text('Reset Password'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

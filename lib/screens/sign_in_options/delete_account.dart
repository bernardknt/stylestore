import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDeletionPage extends StatefulWidget {
  static String id = "Account_deletion";
  @override
  _AccountDeletionPageState createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _error = '';

  void _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Re-authenticate the user
      User? user = _auth.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await user!.reauthenticateWithCredential(credential);

      // Delete the user
      await user.delete();

      // Sign out
      await _auth.signOut();

      // Navigate to a different page or show a success message
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SuccessDeletionPage()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _deleteAccount,
                child: Text('Delete Account'),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessDeletionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Deleted'),
      ),
      body: Center(
        child: Text('Your account has been successfully deleted.'),
      ),
    );
  }
}

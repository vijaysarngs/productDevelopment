import 'package:flutter/material.dart';
import 'package:flutter_application_5/pages/auth/discover.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_5/utils/user_manager.dart';

void main() {
  runApp(SignUpApp());
}

class SignUpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUpPage(),
      routes: {
        '/discover': (context) =>
            DiscoverScreen(), // Replace with your actual DiscoverPage implementation
      },
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  void _signUp() async {
    final url = 'http://192.168.215.128:3000/signup'; // Flask backend URL

    const Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'text/plain', // Accept plain text response
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'category': _categoryController.text.trim(),
          'source': _sourceController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // Assign email to UserManager
        UserManager.instance.email = _emailController.text.trim();

        // Navigate to the discover page
        Navigator.pushNamed(context, '/discover');
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Sign Up Failed. Status code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _sourceController,
              decoration: InputDecoration(labelText: 'Source'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _signUp,
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                child: Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

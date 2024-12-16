import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_5/utils/user_manager.dart';

void main() => runApp(const EditProfileApp());

class EditProfileApp extends StatelessWidget {
  const EditProfileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      home: const EditOptionsScreen(),
    );
  }
}

class EditOptionsScreen extends StatelessWidget {
  const EditOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const EditFieldScreen(field: 'Name')),
                );
              },
              child: const Text('Edit Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const EditFieldScreen(field: 'Password')),
                );
              },
              child: const Text('Edit Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const EditFieldScreen(field: 'Category')),
                );
              },
              child: const Text('Edit Category'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const EditFieldScreen(field: 'Source')),
                );
              },
              child: const Text('Edit Source'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditFieldScreen extends StatefulWidget {
  final String field;
  const EditFieldScreen({Key? key, required this.field}) : super(key: key);

  @override
  State<EditFieldScreen> createState() => _EditFieldScreenState();
}

class _EditFieldScreenState extends State<EditFieldScreen> {
  final _fieldController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _updateField() async {
    if (_fieldController.text.isEmpty) {
      setState(() {
        _errorMessage = '${widget.field} cannot be empty.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = UserManager.instance.email ?? '';
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Email is required.';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://192.168.215.128:7000/update-profile');
    final body = json.encode({
      "email": email,
      widget.field.toLowerCase(): _fieldController.text.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.field} updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? "An error occurred.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error connecting to the server: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.field}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _fieldController,
              decoration: InputDecoration(
                labelText: widget.field,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateField,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Update ${widget.field}'),
            ),
          ],
        ),
      ),
    );
  }
}

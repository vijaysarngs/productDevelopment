import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPage2 extends StatefulWidget {
  const FeedbackPage2({super.key});

  @override
  State<FeedbackPage2> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage2> {
  double _rating = 8.0; // Start at the 8th value
  String _review = '';
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.215.128:7000/submit-feedback'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rating': _rating, 'review': _review}),
      );
      final result = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Feedback submitted!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Rating buttons similar to the ones shown in the image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(11, (index) {
                return IconButton(
                  icon: Icon(
                    index <= _rating ? Icons.star : Icons.star_border,
                    color: index <= _rating ? Colors.blue : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () => setState(() {
                    _rating = index.toDouble();
                  }),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What feature can we add to improve?',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _review = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _review = value,
            ),
            const SizedBox(height: 20),
            _isSubmitting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitFeedback,
                    child: const Text('SEND FEEDBACK'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue, // button color
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

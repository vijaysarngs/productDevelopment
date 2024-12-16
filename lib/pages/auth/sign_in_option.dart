import 'package:flutter/material.dart';
import 'package:flutter_application_5/widgets/custom_button.dart';

class SignInOptionsScreen extends StatelessWidget {
  const SignInOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Skip', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/google_icon.jpg',
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 40),
            const Text(
              'Sign In options.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Continue with Email',
              onPressed: () => Navigator.pushNamed(context, '/sign-in'),
              backgroundColor: Colors.red,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Sign In with Google',
              onPressed: () => Navigator.pushNamed(context, '/google-sign-in'),
              backgroundColor: Colors.white,
              textColor: Colors.black,
              icon: Image.asset('assets/google_icon.jpg', height: 24),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Sign In with Apple ID',
              onPressed: () {},
              backgroundColor: Colors.white,
              textColor: Colors.black,
              icon: Image.asset('assets/apple_icon.jpg', height: 24),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/sign-up'),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

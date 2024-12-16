import 'package:flutter/material.dart';
// import 'package:flutter_application_5/onboard/edit_profile.dart';
import 'package:flutter_application_5/pages/auth/articles/edit_profile.dart';
import 'package:flutter_application_5/pages/auth/articles/feedback.dart';
import 'package:flutter_application_5/pages/auth/sign_up.dart';
import '/onboard/onboard.dart';
import 'pages/auth/sign_in_option.dart';
import 'pages/auth/sign_in.dart';
// import 'pages/auth/sign_up.dart';
import 'pages/auth/google_sign_in.dart';
import 'pages/auth/discover.dart';
import 'pages/auth/source_selction.dart';
// import 'pages/auth/news_filter.dart';
import 'pages/auth/articles/general_article.dart';
// import 'pages/auth/articles/article_detail.dart';
import 'package:flutter_application_5/pages/auth/articles/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beyond Headlines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Inter',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/sign-in-options': (context) => const SignInOptionsScreen(),
        // '/sign-in': (context) => const SignUpScreen(),
        '/sign-up': (context) => SignUpPage(),
        '/google-sign-in': (context) => const SignInScreen(),
        '/discover': (context) => const DiscoverScreen(),
        '/source-selection': (context) => const SourceSelectionScreen(),
        '/general-articles': (context) => const GeneralArticlesScreen(),
        '/feedback': (context) => const FeedbackPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/edit-profile': (context) => const EditProfileApp()
      },
    );
  }
}

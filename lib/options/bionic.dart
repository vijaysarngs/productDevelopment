import 'package:flutter/material.dart';

class BionicFormatPage extends StatelessWidget {
  // The article content passed from the previous page
  final String articleContent;

  // Constructor to receive the article content
  const BionicFormatPage({Key? key, required this.articleContent})
      : super(key: key);

  // Function to apply Bionic formatting
  RichText buildBionicFormattedText(String text,
      {TextStyle? normalStyle, TextStyle? boldStyle}) {
    final words = text.split(' '); // Split the article into words
    List<TextSpan> spans = [];

    // Loop through each word and apply the bionic formatting
    for (var word in words) {
      if (word.isNotEmpty) {
        final splitIndex = (word.length / 2).ceil(); // Split the word in half
        spans.add(
          TextSpan(
            text: word.substring(0, splitIndex), // Bold part
            style: boldStyle ?? const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        spans.add(
          TextSpan(
            text: word.substring(splitIndex) + ' ', // Normal part
            style:
                normalStyle ?? const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bionic Format'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality (if needed)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Title section for Bionic format
              Text(
                'Bionic Formatted Article',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),

              // Show the article content with Bionic formatting applied
              Container(
                decoration: BoxDecoration(
                  color: Colors
                      .grey[100], // Slight grey background for readability
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(12.0),
                child: buildBionicFormattedText(
                  articleContent, // The article content passed in
                  normalStyle: TextStyle(
                    fontSize: 18.0,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                  boldStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

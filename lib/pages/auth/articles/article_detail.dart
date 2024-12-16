import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_5/options/fact_checker.dart';
import 'package:flutter_application_5/options/summarization.dart';
import 'package:flutter_application_5/options/bionic.dart';
import 'package:flutter_application_5/options/trend_identifier.dart';
import 'package:flutter_application_5/options/perspec.dart';

class ArticlePage extends StatefulWidget {
  final String articleUrl;
  final String articleSource;

  const ArticlePage(
      {Key? key, required this.articleUrl, required this.articleSource})
      : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Map<String, dynamic>? articleData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchArticleData();
  }

  Future<void> fetchArticleData() async {
    const String flaskApiUrl = 'http://192.168.215.128:6000/article-details';
    try {
      final response = await http.post(
        Uri.parse(flaskApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'url': widget.articleUrl,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          articleData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load article: ${response.statusCode} - ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void openFullArticle() async {
    final Uri articleUri = Uri.parse(widget.articleUrl);

    if (await canLaunchUrl(articleUri)) {
      await launchUrl(articleUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article')),
      );
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Fact Check'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FactCheckerPage(
                        articleUrl: widget.articleUrl,
                        sourceName: widget.articleSource),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.balance_outlined),
              title: const Text('Bias Analyzer'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bias Analyzer Coming Soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Perspective Blog'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BiasFreeArticleScreen(article: articleData?['body'])),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.summarize_outlined),
              title: const Text('Summarize'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SummarizePage(articleUrl: widget.articleUrl),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_bold_outlined),
              title: const Text('Bionic Format'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BionicFormatPage(
                      articleContent: articleData?['body'],
                    ),
                  ),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.trending_up_outlined),
            //   title: const Text('Trend Identifier'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => TrendIdentifierPage(
            //           topic: articleData?['title'] ?? 'Unknown Topic',
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            articleData?['title'] ?? 'No title available',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Published on: ${articleData?['date'] ?? 'Unknown'}',
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Source: ${widget.articleSource}',
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 16),
                          if (articleData?['image'] != null)
                            Image.network(articleData!['image']),
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                articleData?['body'] ??
                                    articleData?['summary'] ??
                                    'No content available',
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Center(
                            child: ElevatedButton(
                              onPressed: openFullArticle,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              child: const Text('Read Full Article'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => _showMoreOptions(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                              child: const Text('More Options'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

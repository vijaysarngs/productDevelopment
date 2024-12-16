import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BiasFreeArticleScreen extends StatefulWidget {
  final String article;

  const BiasFreeArticleScreen({required this.article, Key? key})
      : super(key: key);

  @override
  _BiasFreeArticleScreenState createState() => _BiasFreeArticleScreenState();
}

class _BiasFreeArticleScreenState extends State<BiasFreeArticleScreen> {
  bool isLoading = true;
  String rewrittenArticle = "";
  String summary = "";
  List<dynamic> changes = [];

  @override
  void initState() {
    super.initState();
    fetchBiasFreeArticle(widget.article);
  }

  Future<void> fetchBiasFreeArticle(String article) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.215.128:3000/rewrite"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"article": article}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          rewrittenArticle = data["rewritten_article"];
          summary = data["summary"];
          changes = data["changes"];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      setState(() {
        rewrittenArticle = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bias-Free Article"),
        backgroundColor: Colors.indigo,
      ),
      body: Stack(
        children: [
          // Background Color
          Container(
            color: Colors.indigo.shade50,
          ),
          isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        color: Colors.indigo,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Bias eradication in progress...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Rewritten Article Section
                        buildCard(
                          title: "Rewritten Article",
                          content: rewrittenArticle,
                        ),
                        const SizedBox(height: 20),

                        // Summary Section
                        buildCard(
                          title: "Summary",
                          content: summary,
                        ),
                        const SizedBox(height: 20),

                        // Changes Made Section
                        buildCard(
                          title: "Changes Made",
                          content: changes.isEmpty
                              ? "No changes were necessary."
                              : changes
                                  .map((change) => buildChangeDetail(change))
                                  .join("\n\n"),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildCard({required String title, required String content}) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  String buildChangeDetail(Map<String, dynamic> change) {
    return "Original: ${change['original']}\n"
        "Rewritten: ${change['rewritten']}\n"
        "Reason: ${change['reason']}";
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_5/pages/auth/articles/article_detail.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  const CategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Article>> articles;

  @override
  void initState() {
    super.initState();
    articles = fetchArticlesFromFlask(widget.category);
  }

  Future<List<Article>> fetchArticlesFromFlask(String category) async {
    final String serverAddress =
        'http://192.168.215.128:6000/api/articles?category=$category';
    try {
      final response = await http.get(Uri.parse(serverAddress));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} News'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: FutureBuilder<List<Article>>(
        future: articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final article = snapshot.data![index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlePage(
                            articleUrl: article.link,
                            articleSource: article.source),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image or Placeholder
                      if (article.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            article.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                      const SizedBox(height: 8),

                      // Category Tag and Date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'F1 Racing',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article.publishedAt,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title and Description
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

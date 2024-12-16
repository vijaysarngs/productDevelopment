import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application_5/utils/user_manager.dart';
import 'package:http/http.dart' as http;
import '/models/article.dart';
import 'article_detail.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_application_5/options/category.dart';
import 'package:cached_network_image/cached_network_image.dart';

// class CategoryScreen extends StatelessWidget {
//   final String category;

//   const CategoryScreen({Key? key, required this.category}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(category),
//       ),
//       body: Center(
//         child: Text(
//           'Welcome to the $category category!',
//           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

class GeneralArticlesScreen extends StatefulWidget {
  const GeneralArticlesScreen({Key? key}) : super(key: key);

  @override
  _GeneralArticlesScreenState createState() => _GeneralArticlesScreenState();
}

class _GeneralArticlesScreenState extends State<GeneralArticlesScreen> {
  List<Article> articles = [];
  List<Article> carouselArticles = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedCategory = 'Politics';
  int totalArticles = 0;
  int _currentCarouselIndex = 0;
  final PageController _carouselController =
      PageController(viewportFraction: 0.9);
  final PageController _categoryController = PageController();

  final List<String> categories = [
    'Politics',
    'Sports',
    'Government',
    'Economy',
  ];

  final Map<String, String> categoryImages = {
    'Politics': 'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620',
    'Sports': 'https://images.unsplash.com/photo-1518770660439-4636190af475',
    'Government':
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf',
    'Economy': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211',
  };

  final String placeholderImageUrl = 'assets/images/placeholder.jpg';

  @override
  void initState() {
    super.initState();
    _fetchArticles(selectedCategory);
  }

  Future<void> articleReadUpdate(String userEmail, String articleSource) async {
    const String apiUrl = "http://192.168.91.128:7000/update_article_read";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userEmail,
          "source": articleSource,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Article read count updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception(
            "Failed to update article read count: ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating article read count: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _fetchArticles(String category) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final uri = Uri.http('192.168.215.128:6000', '/news', {
        'category': category,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData['status'] == 'success') {
          List<dynamic> articlesJson = decodedData['articles'] ?? [];

          setState(() {
            articles =
                articlesJson.map((json) => Article.fromJson(json)).toList();
            totalArticles = articles.length;

            if (articles.length > 5) {
              carouselArticles = articles.sublist(0, 5);
              articles = articles.sublist(5);
            } else {
              carouselArticles = articles;
              articles = [];
            }

            isLoading = false;
          });
        } else {
          throw Exception(decodedData['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to load articles: ${response.reasonPhrase}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load articles: $error';
        isLoading = false;
      });
    }
  }

  String getTimeAgo(String? publishedAt) {
    if (publishedAt == null) return '12 hours ago';
    try {
      final dateTime = DateTime.parse(publishedAt);
      return timeago.format(dateTime);
    } catch (e) {
      return '12 hours ago';
    }
  }

  void navigateToArticleDetail(Article? article) {
    if (article == null || article.url == null || article.source == null) {
      Fluttertoast.showToast(
        msg: "Article details are missing!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    String? userEmail = UserManager.instance.email;
    if (userEmail == null) {
      Fluttertoast.showToast(
        msg: "User email is missing!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Update article read count
    articleReadUpdate(userEmail, article.source);

    // Navigate to the article detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlePage(
            articleUrl: article.url!, articleSource: article.source),
      ),
    );
  }

  void navigateToCategoryScreen(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(category: category),
      ),
    );
  }

  Widget buildNetworkImage(String? imageUrl,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              'Image not available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("General Articles"),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Navigation Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile Overview'),
              onTap: () {
                // Add navigation logic for Profile Overview
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Feedback'),
              onTap: () {
                Navigator.pushNamed(context, '/feedback');
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: IconButton(
                                alignment: Alignment.centerLeft,
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              height: 90,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return GestureDetector(
                                    onTap: () {
                                      navigateToCategoryScreen(category);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      width: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            buildNetworkImage(
                                              categoryImages[category] ?? '',
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              left: 4,
                                              child: Text(
                                                category,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 4,
                                              right: 4,
                                              child: Text(
                                                "$totalArticles News",
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 300,
                                  child: PageView.builder(
                                    controller: _carouselController,
                                    itemCount: carouselArticles.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentCarouselIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final article = carouselArticles[index];
                                      return GestureDetector(
                                        onTap: () =>
                                            navigateToArticleDetail(article),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Card(
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  buildNetworkImage(
                                                    article.imageUrl ?? '',
                                                    width: double.infinity,
                                                    height: 220,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Text(
                                                      article.title ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8.0),
                                                    child: Text(
                                                      getTimeAgo(
                                                          article.publishedAt),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final article = articles[index];
                                return GestureDetector(
                                  onTap: () => navigateToArticleDetail(article),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                          child: buildNetworkImage(
                                            article.imageUrl ?? '',
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            article.title ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(
                                            getTimeAgo(article.publishedAt),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: articles.length,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}

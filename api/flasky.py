from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import http.client
import json
app = Flask(__name__)
CORS(app)

API_URL = "https://eventregistry.org/api/v1/article/getArticles"  # Replace with your actual API URL
API_KEY = "f8a41aca-c7ed-4092-b1f9-155249e3b295"
NEWS_API_KEY = "5378b113380e4777a595687ed0d1633f"
NEWS_API_BASE_URL = "https://newsapi.org/v2/everything"

# Endpoint to fetch articles
@app.route('/api/articles', methods=['GET'])
def get_articles():
    category = request.args.get('category', 'general')

    params = {
        'q': category,
        'apiKey': NEWS_API_KEY,
    }

    try:
        response = requests.get(NEWS_API_BASE_URL, params=params)
        response.raise_for_status()
        articles_data = response.json().get('articles', [])

        articles = []
        for article in articles_data:
            articles.append({
                'title': article.get('title', 'No Title Available'),
                'source': article.get('source', {}).get('name', 'Unknown Source'),
                'imageUrl': article.get('urlToImage', ''),
                'publishedAt': article.get('publishedAt', 'Unknown Date'),
                'content': article.get('content', ''),
                'link': article.get('url', ''),
                'description': article.get('description', 'No description available.'),
                'url': article.get('url', ''),
            })

        return jsonify(articles), 200

    except requests.exceptions.RequestException as e:
        return jsonify({'error': str(e)}), 500

def search_articles(request_data, api_url):
    
    response = requests.post(api_url, json=request_data)
    response.raise_for_status()  # Raise an error for unsuccessful status codes
    return response.json()


@app.route('/news', methods=['GET'])
def get_news():
    try:
        # Default category to 'general' if no keyword is provided
        keyword = request.args.get('keyword', 'general')  
        location = "india" 
        page = int(request.args.get('page', 1)) 
        
        # Define parameters for the article request
        params = {
            'q': keyword,  # The query for general articles
            'apiKey': NEWS_API_KEY,
            'pageSize': 10,  # Number of articles per page
            'page': page,    # Current page number
        }

        # Get the articles from the external API
        response = requests.get(NEWS_API_BASE_URL, params=params)
        response.raise_for_status()  # Raise an error for unsuccessful status codes
        
        articles_data = response.json().get('articles', [])
        
        # Format the articles to match the frontend structure
        formatted_articles = [
            {
                'title': article.get('title', 'No title'),
                'summary': article.get('description', 'No summary available'),
                'url': article.get('url', '#'),
                'date': article.get('publishedAt', 'Unknown date'),
                'source': article.get('source', {}).get('name', 'Unknown source'),
                'imageUrl': article.get('urlToImage', 'https://via.placeholder.com/150') 
            }
            for article in articles_data
        ]

        # Return results
        if formatted_articles:
            return jsonify({'status': 'success', 'articles': formatted_articles}), 200
        else:
            return jsonify({'status': 'error', 'message': 'No articles found'}), 404

    except requests.exceptions.RequestException as e:
        return jsonify({'status': 'error', 'message': f'API request error: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'status': 'error', 'message': f'Internal server error: {str(e)}'}), 500

    
@app.route('/article-details', methods=['POST'])
def fetch_article_details():
    api_url = "http://analytics.eventregistry.org/api/v1/extractArticleInfo"
    headers = {
        "Content-Type": "application/json"
    }

    data = request.get_json()
    article_url = data.get('url')
    api_key = "f8a41aca-c7ed-4092-b1f9-155249e3b295"

    if not article_url:
        return jsonify({"error": "Article URL is required"}), 400

    try:
        response = requests.post(
            api_url,
            headers=headers,
            json={"url": article_url, "apiKey": api_key}
        )

        if response.status_code == 200:
            return jsonify(response.json())
        else:
            return jsonify({
                "error": "Failed to fetch article details",
                "status_code": response.status_code,
                "message": response.text
            }), response.status_code
    except Exception as e:
        return jsonify({"error": str(e)}), 500

def fetch_media_bias_data(source_name):
    conn = http.client.HTTPSConnection("political-bias-database.p.rapidapi.com")

    headers = {
        'x-rapidapi-key': "c61480be18msh222aeaa86ab2f8bp162cf7jsn81954872764e",
        'x-rapidapi-host': "political-bias-database.p.rapidapi.com"
    }

    conn.request("GET", "/MBFCdata", headers=headers)
    res = conn.getresponse()
    data = res.read()

    try:
        # Parse the API response
        all_sources = json.loads(data)
        # Search for the source
        for source in all_sources:
            if source_name.lower() in source['name'].lower():
                return source  # Return the matching source details

        return None  # If source is not found
    except json.JSONDecodeError:
        return None  # Error decoding response

@app.route('/fetch_media_bias', methods=['GET'])
def fetch_media_bias():
    source_name = request.args.get('name')
    if not source_name:
        return jsonify({"error": "Source name is required."}), 400
    
    result = fetch_media_bias_data(source_name)
    
    if result:
        return jsonify(result)
    else:
        return jsonify({"error": f"No data found for the source '{source_name}'."}), 404

if __name__ == '__main__':
    app.run(host="192.168.215.128",debug=True,port=6000)

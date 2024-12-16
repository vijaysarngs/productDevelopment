from flask import Flask, request, jsonify
from transformers import pipeline
from textblob import TextBlob
import nltk

nltk.download('punkt_tab')

app = Flask(__name__)

# Load the NLP models
paraphraser = pipeline("text2text-generation", model="t5-small")
summarizer = pipeline("summarization")

def detect_bias(sentence):
   
    analysis = TextBlob(sentence)
    return abs(analysis.sentiment.polarity) > 0.5

def rewrite_biased_sentence(sentence):
    
    paraphrased = paraphraser(f"paraphrase: {sentence}", max_length=50, num_return_sequences=1)
    return paraphrased[0]['generated_text']

@app.route('/rewrite', methods=['POST'])
def process_article():
    
    try:
        data = request.json
        article = data.get('article', '')

        if not article:
            return jsonify({"error": "Article content is missing"}), 400

        sentences = nltk.sent_tokenize(article)
        rewritten_article = []
        summary_of_changes = []

        for sentence in sentences:
            if detect_bias(sentence):
                rewritten_sentence = rewrite_biased_sentence(sentence)
                summary_of_changes.append({
                    "original": sentence,
                    "rewritten": rewritten_sentence,
                    "reason": "High sentiment polarity detected"
                })
                rewritten_article.append(rewritten_sentence)
            else:
                rewritten_article.append(sentence)

        rewritten_text = " ".join(rewritten_article)
        summary = summarizer(rewritten_text, max_length=100, min_length=30, do_sample=False)[0]['summary_text']

        return jsonify({
            "rewritten_article": rewritten_text,
            "summary": summary,
            "changes": summary_of_changes
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="192.168.215.128", port=3000)

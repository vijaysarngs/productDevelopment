from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# Database connection
def create_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="Kutta@123",
        database="your_database"
    )

@app.route('/update-profile', methods=['POST'])
def update_profile():
    try:
        data = request.get_json()

        # Extract email and validate
        email = data.get("email")
        if not email:
            return jsonify({"message": "Email is required"}), 400

        # Connect to database
        connection = create_connection()
        cursor = connection.cursor(dictionary=True)

        # Check if user exists
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        if not user:
            return jsonify({"message": "User not found"}), 404

        # Update user fields if provided
        if "name" in data:
            cursor.execute("UPDATE users SET name = %s WHERE email = %s", (data["name"], email))
        if "password" in data:
            cursor.execute("UPDATE users SET password = %s WHERE email = %s", (data["password"], email))
        if "category" in data:
            cursor.execute("UPDATE users SET category = %s WHERE email = %s", (data["category"], email))
        if "source" in data:
            cursor.execute("UPDATE users SET source = %s WHERE email = %s", (data["source"], email))

        connection.commit()

        return jsonify({"message": "Profile updated successfully!"}), 200

    except Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500

    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()
# Route to update article read count and source
@app.route('/update_article_read', methods=['POST'])
def update_article_read():
    data = request.json

    user_id = data.get('user_id')  
    article_source = data.get('source') 

    if not user_id or not article_source:
        return jsonify({"error": "Missing required fields"}), 400

    try:
        connection = create_connection()
        cursor = connection.cursor()

        query = """
            UPDATE users
            SET articles_read_count = articles_read_count + 1,
                last_article_source = %s
            WHERE email = %s
        """
        values = (article_source, user_id)

        cursor.execute(query, values)
        connection.commit()

        cursor.close()
        connection.close()

        return jsonify({"message": "Article read count and source updated successfully"}), 200
    except Error as e:
        return jsonify({"error": f"Database error: {e}"}), 500

# Route to save sources
@app.route('/save-sources', methods=['POST'])
def save_sources():
    data = request.json
    email = data.get('email')
    selected_sources = data.get('selectedSources', [])

    if not email:
        return jsonify({"error": "Email is required"}), 400

    try:
        conn = create_connection()
        cursor = conn.cursor()

        # Ensure user entry exists
        cursor.execute("INSERT IGNORE INTO usersources (email) VALUES (%s)", (email,))
        conn.commit()

        # Update sources in the table
        for source in ['bbc', 'cnn', 'hindu', 'news18', 'toi']:
            value = source if source in selected_sources else 'NA'
            cursor.execute(
                f"UPDATE usersources SET {source} = %s WHERE email = %s",
                (value, email)
            )
        conn.commit()
        return jsonify({"message": "Sources saved successfully"}), 200

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        cursor.close()
        conn.close()

# Route to save categories
@app.route('/save-categories', methods=['POST'])
def save_categories():
    data = request.json
    email = data.get('email')
    categories = data.get('categories', [])

    if not email:
        return jsonify({"error": "Email is required"}), 400

    try:
        conn = create_connection()
        cursor = conn.cursor()

        # Remove existing categories for the user
        cursor.execute("DELETE FROM usercategories WHERE email = %s", (email,))
        conn.commit()

        # Insert new categories
        for category in categories:
            cursor.execute(
                "INSERT INTO usercategories (email, category) VALUES (%s, %s)",
                (email, category)
            )
        conn.commit()
        return jsonify({"message": "Categories saved successfully"}), 200

    except mysql.connector.Error as err:
        return jsonify({"error": str(err)}), 500

    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    app.run(host="192.168.215.128", debug=True, port=7000)

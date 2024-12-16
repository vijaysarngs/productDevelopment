from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# Enable CORS
CORS(app, resources={r"/*": {"origins": "*"}})

# Database connection
def create_connection():
    try:
        return mysql.connector.connect(
            host="localhost",
            user="root",
            password="Kutta@123",
            database="your_database"
        )
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None
@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    category = data.get('category')
    source = data.get('source')
    agreed_to_terms = data.get('agreedToTerms')

    # Validate required fields
    if not name or not email or not password:
        return jsonify({"message": "All fields are required."}), 400

    # Validate agreedToTerms
    if agreed_to_terms is None or not agreed_to_terms:
        return jsonify({"message": "You must agree to the terms and conditions."}), 400

    try:
        connection = create_connection()
        cursor = connection.cursor()

        # Check if the user already exists
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        existing_user = cursor.fetchone()
        if existing_user:
            return jsonify({"message": "User already exists."}), 400

        # Insert new user
        cursor.execute(
            "INSERT INTO users (name, email, password, category, source, agreed_to_terms) VALUES (%s, %s, %s, %s, %s, %s)",
            (name, email, password, category, source, agreed_to_terms),
        )
        connection.commit()

        cursor.close()
        connection.close()

        # Always return a JSON response
        return jsonify({"message": "User created successfully."}), 201
    except Exception as e:
        return jsonify({"message": f"Server error: {e}"}), 500

# @app.route('/signup', methods=['POST'])
# def signup():
#     data = request.json

#     name = data.get('name')
#     email = data.get('email')
#     password = data.get('password')
#     agreed_to_terms = data.get('agreedToTerms',False) 
#     category = data.get('category', '')
#     source = data.get('source', '')
    

#     # Ensure all required fields are present
#     if not name or not email or not password:
#         return jsonify({"message": "Missing required fields"}), 400

#     connection = create_connection()
#     if connection is None:
#         return jsonify({"message": "Unable to connect to the database"}), 500

#     try:
#         cursor = connection.cursor()

#         query = """
#             INSERT INTO users (name, email, password, agreed_to_terms, category, source) 
#             VALUES (%s, %s, %s, %s, %s, %s)
#         """
#         values = (name, email, password, agreed_to_terms,category, source)

#         cursor.execute(query, values)
#         connection.commit()

#         cursor.close()
#         connection.close()

#         return jsonify({
#             "message": "User registered successfully", "status_code": 201
#         }),201

#     except Error as e:
#         print(f"Database error: {e}")
#         return jsonify({"message": f"Database error occurred: {str(e)}"}), 500


@app.route('/signin', methods=['POST'])
def signin():
    data = request.json

    email = data.get('email')
    password = data.get('password')

    # Validate required fields
    if not email or not password:
        return jsonify({"message": "Missing email or password", "status_code": 400}), 400

    connection = create_connection()
    if connection is None:
        return jsonify({"message": "Unable to connect to the database", "status_code": 500}), 500

    try:
        cursor = connection.cursor()

        # SQL query to fetch user data
        query = "SELECT id, name, email, category, source FROM users WHERE email = %s AND password = %s"
        cursor.execute(query, (email, password))
        user = cursor.fetchone()

        if user:
            return jsonify({
                "message": "Sign-in successful",
                "user": {
                    "id": user[0],
                    "name": user[1],
                    "email": user[2],
                    "category": user[3],  # Added category field
                    "source": user[4],     # Added source field
                    "status_code": 200
                }
            }), 200
        else:
            return jsonify({
                "message": "Invalid email or password",
                "status_code": 401
            }), 401  # Unauthorized

    except Error as e:
        print(f"Database error: {e}")
        return jsonify({"message": f"Database error: {e}", "status_code": 500}), 500
    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    app.run(host='192.168.215.128', debug=True, port=5000)

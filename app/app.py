# Simple Flask API for backend servers
# Provides endpoints for health check and database connection

from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

# Create new PostgreSQL connection using environment variables
def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )

# Root endpoint (used to test load balancing)
@app.route("/")
def home():
    return jsonify({"message": "Hello from Flask API"})

# Database check endpoint (verifies connection to PostgreSQL)
@app.route("/db")
def db_check():
    try:
        conn = get_connection()
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version = cur.fetchone()
        cur.close()
        conn.close()

        return jsonify({
            "status": "connected",
            "db_version": version[0]
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        })

# Run application on all interfaces (required for Docker)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
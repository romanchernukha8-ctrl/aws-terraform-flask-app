# Base image with Python runtime
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy application files into container
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Start Flask application
CMD ["python", "main.py"]

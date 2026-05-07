# Launch template for EC2 instances running the backend API
resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # Security group allowing HTTP traffic
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # SSH key
  key_name = aws_key_pair.deployer.key_name

  # Script executed on instance startup
  user_data = base64encode(<<-EOF
#!/bin/bash
set -ex

# Install Docker
apt update -y
apt install -y docker.io

# Start Docker
systemctl start docker
systemctl enable docker

sleep 20

# Prepare app directory
mkdir -p /app
cd /app

# Create Flask API
cat > main.py << 'PYEOF'
from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

# Connect to PostgreSQL using environment variables
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

# Database check endpoint
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

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PYEOF

# Python dependencies
cat > requirements.txt << 'REQEOF'
flask
psycopg2-binary
REQEOF

# Docker image
cat > Dockerfile << 'DOCKEREOF'
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "main.py"]
DOCKEREOF

# Build and run container
docker build -t myapp .
docker run -d -p 80:80 \
  -e DB_HOST=${aws_db_instance.postgres.address} \
  -e DB_NAME=appdb \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres123 \
  myapp
EOF
  )
}

# Auto Scaling Group maintaining backend instances
resource "aws_autoscaling_group" "app" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  # Subnets for instances
  vpc_zone_identifier = data.aws_subnets.default.ids

  # Use launch template
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Attach to Load Balancer
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # Health check via ALB
  health_check_type = "ELB"

  # Tag instances
  tag {
    key                 = "Name"
    value               = "autoscale-app"
    propagate_at_launch = true
  }
}
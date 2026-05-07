# PostgreSQL database (AWS RDS)
# Used by backend API to store and retrieve data
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"

  db_name              = "appdb"
  username             = "postgres"
  password             = "postgres123"

  skip_final_snapshot  = true
  publicly_accessible  = true

  # Attach security group to control access
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

# Security group for PostgreSQL
# Allows access only from backend servers
resource "aws_security_group" "db_sg" {
  name = "db-sg"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"

    # Only allow traffic from web/app security group
    security_groups = [aws_security_group.web_sg.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
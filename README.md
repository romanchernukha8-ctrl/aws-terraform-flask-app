# 🚀 AWS Terraform Flask API

## Overview

This project demonstrates a simple backend infrastructure on AWS using Terraform.

It includes:

* Flask API running in Docker containers
* Application Load Balancer (ALB)
* Auto Scaling Group (multiple backend instances)
* PostgreSQL database (AWS RDS)

The main goal of the project is to showcase:

* Infrastructure as Code with Terraform
* Scalable backend architecture on AWS
* Integration between API and managed database (RDS)

---

## Tech Stack

* Python (Flask)
* Terraform
* AWS (EC2, ALB, RDS)
* Docker
* PostgreSQL

---

## Project Structure

```
.
├── app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── terraform/
│   ├── main.tf
│   ├── ec2.tf
│   ├── autoscaling.tf
│   ├── alb.tf
│   ├── rds.tf
│   ├── outputs.tf
│   └── init.sh
│
└── README.md
```

---

## How It Works

1. Terraform provisions AWS infrastructure:
   * EC2 instances (Auto Scaling Group)
   * Application Load Balancer
   * PostgreSQL database (RDS)

2. Each EC2 instance:
   * installs Docker
   * builds and runs Flask API container

3. Load Balancer distributes traffic between instances

4. Flask API:
   * `/` → returns response from instance (used to test load balancing)
   * `/db` → checks connection to PostgreSQL

---

## How to Run

### 1. Initialize Terraform

```
cd terraform
terraform init
```

### 2. Apply infrastructure

```
terraform apply
```

### 3. Get Load Balancer DNS

```
terraform output alb_dns
```

---

## Testing

```
curl http://<alb_dns>/
curl http://<alb_dns>/db
```

---

## Example Output

```
{"message": "Hello from 1647be995828"}
{"message": "Hello from 95ced41d3a65"}
```

```
{"status": "connected"}
```

---

## Features

* Auto Scaling backend (2+ instances)
* Load balancing via AWS ALB
* Dockerized Flask API
* PostgreSQL database (RDS)
* Health checks and fault tolerance

---

## Future Improvements

* Add HTTPS (SSL via ACM)
* Use private subnets for RDS
* Add CI/CD pipeline (GitHub Actions)
* Store Terraform state in S3
* Add environment separation (dev/prod)

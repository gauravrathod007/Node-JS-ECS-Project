# DevOps Practical Tasks

This repository contains multiple DevOps practice tasks, covering containerization, infrastructure as code, and Linux system administration.

---

## 🐳 Part 1: Containerize a Node.js Application using Docker

### Objective
Containerize a simple Node.js Express application following Docker best practices.

---

### Steps

#### 1. Create a simple Node.js app

```bash
mkdir node-app && cd node-app
npm init -y
npm install express

app.js

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello World from containerized Node.js!');
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

2. Create .dockerignore
node_modules
npm-debug.log
.DS_Store
.git
.gitignore
.env
logs
*.log

3. Create Dockerfile
# --- Stage 1: builder ---
FROM node:20-alpine AS builder

# Create app directory
WORKDIR /app

# Install build deps (if needed) and copy package files first for caching
COPY package.json package-lock.json* ./

# Install only production dependencies in builder (optional)
RUN npm ci --production

# Copy app source
COPY . .

# If you have any build step (e.g. transpile), run it here
# RUN npm run build


# --- Stage 2: runtime ---
FROM node:20-alpine AS runtime

# Create non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only what's necessary from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/app.js ./app.js
# (Copy other needed files if present, e.g. public/, dist/)

# Ensure file permissions are correct for non-root user
RUN chown -R appuser:appgroup /app

# Expose default port
ENV PORT=3000
EXPOSE 3000

# Use non-root user
USER appuser

# Start the app
CMD ["node", "app.js"]

4. Build and run locally
docker build -t node-app .
docker run -d -p 3000:3000 node-app

5. Test
curl http://localhost:3000
# Output: Hello World from containerized Node.js!

Part 2: Infrastructure as Code using Terraform (AWS ECS)
Objective

Deploy the containerized Node.js app to AWS ECS (Fargate) using Terraform.

Main Components
Networking: VPC, subnets, security groups
ECS Cluster: AWS Fargate cluster
Task Definition: References Docker image from Amazon ECR
Service: Runs tasks behind an Application Load Balancer
IAM Roles: Task execution roles with least privileges

Terraform Project Structure
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   ├── ecs/
│   ├── alb/
│   ├── iam/


Each module should:

Contain its own main.tf, variables.tf, and outputs.tf
Use meaningful variable names
Include documentation (README or comments)
Follow least privilege IAM principles

Example Snippet (ECS Task Definition)
container_definitions = jsonencode([
  {
    name      = "hello-node"
    image     = var.container_image
    essential = true
    portMappings = [
      {
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "hello-node"
      }
    }
  }
])

🚀 Deployment Steps Summary

Push Docker image to Amazon ECR
Use Terraform to provision ECS infrastructure
Confirm ECS service is active and ALB target group is healthy
Access your app via the ALB DNS name

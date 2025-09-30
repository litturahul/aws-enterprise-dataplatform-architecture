# Redshift Cluster subnet group
resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${var.environment}-redshift-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name        = "${var.environment}-redshift-subnet-group"
    Environment = var.environment
  }
}

# Security Group for Redshift Cluster: Allow Redshift access only via Bastion and required endpoints
resource "aws_security_group" "redshift_security_group" {
  name        = "${var.environment}-redshift-security-group"
  description = "Security Group for Redshift Cluster"
  vpc_id     = aws_vpc.main.id

  ingress {
    description = "Allow access from Bastion SSH"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_security_group.id]
  }

  ingress {
    description = "Glue/EKS job access"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-redshift-security-group"
    Environment = var.environment
  }
}

# Redshift Cluster
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier       = "${var.environment}-redshift-cluster"
  node_type                 = "dc2.large"
  master_username           = "adminuser"
  master_password           = "AdminUser123"
  cluster_type              = "multi-node"
  number_of_nodes           = 2 # adjust to workload
  publicly_accessible       = false
  iam_roles                 = [aws_iam_role.redshift_role.arn]
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.redshift_security_group.id]

  tags = {
    Name        = "${var.environment}-redshift-cluster"
    Environment = var.environment
  }
}

# IAM Role for Redshift
resource "aws_iam_role" "redshift_role" {
  name = "${var.environment}-redshift-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })

  tags = {
    Name        = "${var.environment}-redshift-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "redshift_s3_access" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
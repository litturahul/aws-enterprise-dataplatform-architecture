# Environment
variable "environment" {
  description = "value for environment used for tagging"
  type        = string
}

# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

# Subnet
variable "public_subnet_cidrs" {
  description = "List of CIDR values for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR values for the private subnets"
  type        = list(string)
}

variable "public_destination_cidr" {
  description = "Destination CIDR for public subnet route table"
  type        = string
}

variable "bastion_host_ssh_cidr" {
  description = "CIDR block for bastion host SSH access"
  type        = string
}

# S3 Bucket Names
variable "s3_landingzone_name" {
  description = "Name of the S3 bucket for landing zone"
  type        = string
}

variable "s3_exportzone_name" {
  description = "Name of the S3 bucket for export zone"
  type        = string
}
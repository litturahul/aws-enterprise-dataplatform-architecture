environment        = "Prod"

aws_region         = "eu-central-1"

vpc_cidr           = "10.0.0.0/16"

availability_zones  = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

public_destination_cidr = "0.0.0.0/0"

bastion_host_ssh_cidr = "203.0.113.0/24"


s3_landingzone_name = "my-landing-zone-bucket"
s3_exportzone_name  = "my-export-zone-bucket"
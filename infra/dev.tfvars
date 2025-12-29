name = "chatbot-milhas"
environment = "dev"
region = "us-east-1"
cidr_block = "172.25.0.0/16"
private_subnets = ["172.25.0.0/20", "172.25.16.0/20"]
public_subnets = ["172.25.48.0/20", "172.25.64.0/20"]
availability_zones = ["us-east-1a", "us-east-1b"]
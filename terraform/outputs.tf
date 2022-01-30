output "vpc_arn" {
  description = "ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "igw_arn" {
  description = "ARN of the IG"
  value       = module.vpc.igw_arn
}

output "igw_id" {
  description = "ID of the IG"
  value       = module.vpc.igw_id
}

output "public_ip_jenkins_master" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = module.jenkins_master.public_ip
}

output "public_ip_prod_server" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = module.prod_server.public_ip
}



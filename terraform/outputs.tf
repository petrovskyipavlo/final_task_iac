vpc_arn

vpc_id

igw_arn

igw_id


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
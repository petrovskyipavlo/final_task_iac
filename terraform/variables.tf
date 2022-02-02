#################
# Credentials
#################
variable "profile" {
  description = "AWS Profile"
  type        = string
  default     = "terraformp"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. "
  type        = string
  default     = "pavelp"
}

variable "region" {
  description = "Region for AWS  network "
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pubsub_a" {
  description = "subnet"
  type        = string
  default     = "10.0.101.0/24"
}

variable "pubsub_b" {
  description = "subnet"
  type        = string
  default     = "10.0.102.0/24"
}

variable "prvsub_a" {
  description = "subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "prvsub_b" {
  description = "subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "name_vpc" {
  description = "VPC name"
  type        = string
  default     = "pavel-vpc"
}

variable "name_jenkins_sg" {
  description = "VPC name"
  type        = string
  default     = "jenkins-master-sg"
}

variable "name_deployment_sg" {
  description = "VPC name"
  type        = string
  default     = "deployment-sg"
}

variable "name_jenkins_master" {
  description = "VPC name"
  type        = string
  default     = "jenkins-master"
}

variable "name_prod_server" {
  description = "VPC name"
  type        = string
  default     = "prod-server"
}


variable "instance_type" {
  description = "Instance Type to use for Jenkins master"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Tags to apply to all the resources"
  type        = map

  default = {
    Terraform = "true"
  }
}

variable "tag_jenkins" {
  description = "Tags to apply to all the resources"
  type        = map

  default = {
    Name = "Jenkins"
  }
}

variable "tag_server" {
  description = "Tags to apply to all the resources"
  type        = map

  default = {
    Name = "Server"
  }
}

##################################################################
variable "identifier_for_rds" {
  default = "demodb"
}

variable "engine_for_rds" {
  default = "mysql"
}

variable "engine_version_for_rds" {
  default = "5.7.19"
}

variable "instance_class_for_rds" {
  default = "db.t2.micro"
}

variable "allocated_storage_for_rds" {
  default = 5
}

variable "db_name" {
  default = ""
}

variable "db_username" {
  default = ""
}

variable "db_password" {
  default = ""
}

variable "db_port" {
  default = "3306"
}

variable "maintenance_window" {
  default = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  default = "03:00-06:00"
}

variable "backup_retention_period" {
  default = 0
}

variable "family" {
  default = "mysql5.7"
}

variable "major_engine_version" {
  default = "5.7"
}


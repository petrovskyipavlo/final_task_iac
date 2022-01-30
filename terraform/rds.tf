module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.identifier_for_rds
  engine            = var.engine_for_rds
  engine_version    = var.engine_version_for_rds
  instance_class    = var.instance_class_for_rds
  allocated_storage = var.allocated_storage_for_rds
  storage_encrypted = false
  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port
  vpc_security_group_ids = [module.db-sg.security_group_id]
  maintenance_window = var.maintenance_window
  backup_window      = var.backup_window
  multi_az = false
  # disable backups to create DB faster
  backup_retention_period = var.backup_retention_period

  tags = {
    Owner       = "Terraform"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = module.vpc.private_subnets

  # DB parameter group
  family = var.family

  # DB option group
  major_engine_version = var.major_engine_version

  # Database Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    }
  ]
}
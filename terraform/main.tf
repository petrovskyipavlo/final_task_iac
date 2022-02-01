module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name_vpc
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]  
  public_subnets  = [var.pubsub_a, var.pubsub_b]
  private_subnets = [var.prvsub_a, var.prvsub_b]

  tags = var.tags
}

module "jenkins_master_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.name_jenkins_sg
  description = "Security group that for Jenkins master"
  vpc_id      = module.vpc.vpc_id

   

  ingress_with_cidr_blocks = [

    {
      rule        = "http-80-tcp"
      description = "From internet"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      rule        = "http-8080-tcp"
      description = "From internet default jenkins port"
      cidr_blocks = "0.0.0.0/0"
    },

    {
      rule        = "https-443-tcp"
      description = "From internet https"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      description = "From internet ssh"
      cidr_blocks = "0.0.0.0/0"
    },
   
  ]

    egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  
  tags = var.tags 
}

module "deployment_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.name_deployment_sg
  description = "Security group that for Jenkins master"
  vpc_id      = module.vpc.vpc_id

   

  ingress_with_cidr_blocks = [

    {
      rule        = "http-80-tcp"
      description = "From internet"
      cidr_blocks = "0.0.0.0/0"
    },

    
    {
      rule        = "https-443-tcp"
      description = "From internet https"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "ssh-tcp"
      description = "From internet ssh"
      cidr_blocks = "0.0.0.0/0"
    },
   
  ]

    egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Internet"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  
  tags = var.tags 
}

module "db-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "sg_for_database"
  description = "Security group for database"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["mysql-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "jenkins_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.name_jenkins_master

  ami                    = data.aws_ami.ubuntu.id  
  instance_type          = var.instance_type
  availability_zone      = "${var.region}a"
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [module.jenkins_master_sg.security_group_id]          
  subnet_id              = module.vpc.public_subnets[0] 

  
  user_data       = <<-EOF
                #!/bin/bash
                #apt install -y git
                apt-add-repository -y ppa:ansible/ansible
                apt update
                apt install -y ansible
                apt update

                apt install -y jq
                
                ansible-galaxy install geerlingguy.java
                ansible-galaxy install geerlingguy.jenkins

                cd ~
                git clone https://github.com/petrovskyipavlo/final_task_iac.git

                #install Jenkins
                cp  ~/final_task_iac/ansible/jenkins.yml ~/.ansible/
                ansible-playbook ~/.ansible/jenkins.yml

                #install docker
                cp -r ~/final_task_iac/ansible/docker ~/.ansible/
                cp  ~/final_task_iac/ansible/docker.yml ~/.ansible/
                ansible-playbook ~/.ansible/docker.yml

                #add jenkins to docker group
                usermod -aG docker jenkins

                reboot                 
                EOF  

  tags = var.tags 
}

module "prod_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.name_prod_server

  ami                    = data.aws_ami.ubuntu.id  
  instance_type          = var.instance_type
  availability_zone      = "${var.region}b"
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [module.deployment_sg.security_group_id]          
  subnet_id              = module.vpc.public_subnets[1] 

  
  user_data       = <<-EOF
                #!/bin/bash
                #apt install -y git
                sudo apt-add-repository -y ppa:ansible/ansible
                sudo apt update
                sudo apt install -y ansible
                sudo apt update

                apt install -y jq
                
                ansible-galaxy install geerlingguy.java
                ansible-galaxy install geerlingguy.jenkins

                cd ~
                git clone https://github.com/petrovskyipavlo/final_task_iac.git

                
                #install docker
                cp -r ~/final_task_iac/ansible/docker ~/.ansible/
                cp  ~/final_task_iac/ansible/docker.yml ~/.ansible/
                ansible-playbook ~/.ansible/docker.yml
                
                reboot                 
                EOF  

  tags = var.tags 
}


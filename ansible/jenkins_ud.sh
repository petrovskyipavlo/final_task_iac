#!bin/bash
set -e # Exit on first error
set -x # Print expanded commands to stdout

#install git
apt install -y git

#install ansible
apt-add-repository -y ppa:ansible/ansible
apt update
apt install -y ansible



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

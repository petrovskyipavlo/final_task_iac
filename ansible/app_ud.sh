#!bin/bash
set -e # Exit on first error
set -x # Print expanded commands to stdout

#install git
apt install -y git

#install ansible
apt-add-repository -y ppa:ansible/ansible
apt update
apt install -y ansible

cd ~
git clone https://github.com/petrovskyipavlo/final_task_iac.git
#install Java
cp  ~/final_task_iac/ansible/docker.yml ~/.ansible/
ansible-playbook ~/.ansible/docker.yml

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

cd ~
git clone https://github.com/petrovskyipavlo/final_task_iac.git
#install Java
cp  ~/final_task_iac/ansible/java.yml ~/.ansible/
ansible-playbook ~/.ansible/java.yml

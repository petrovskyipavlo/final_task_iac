# Final task infrastructure

## Securing Secrets for your IaC using Jenkins, Terraform and Ansible Vault

You can see that all the stagess are executed from a single Jenkins node and has a few important variables. The most important one being:

`load “$JENKINS_HOME/.envvars/.env.groovy”`

This line could be considered a bit unnecessary but is used to set the “VAULT_LOCATION” variable in the Pipeline which is the directory where your password(s) for Ansible Vault is stored. This is an additional step to keep from storing the location of the password file location in plain text in your code repo. “$JENKINS_HOME/.envvars/.env.groovy” will need to be created manually on Jenkins as well as the $VAULT_LOCATION directory.

As Jenkins user:

```sh

mkdir -pv $JENKINS_HOME/.envvars/ && \
mkdir -pv $JENKINS_HOME/.vault && \
touch  $JENKINS_HOME/.envvars/.env.groovy &&  echo "env.VAULT_LOCATION="$JENKINS_HOME/.vault"" >> $JENKINS_HOME/.envvars/.env.groovy

```

The other important variable set here is “envvar”. This is used as not only to assign the environment of in the infrastructure but also as the filename of the plain text password file in the $VAULT_LOCATION directory on the Jenkins node and also the name of the secrets file for terraform. The ${envvar}.txt and ${envvar}-secrets.tfvars gets passed to Ansible Vault as cmd line arguments, which we will see later, for encrypting and decrypting secrets.

As Jenkins user:
```sh
echo "ThisIsOurPasswordForEncrypt&Decrypt" >> $JENKINS_HOME/.vault/prod.txt 

$JENKINS_HOME/.vault/prod-secrets.tfvars <<-EOF
db_name = "sample"
db_username = "sample" 
db_password = "sample"
EOF


```
If you can't login as Jenkins user:

```sh
   sudo -i
   # do something
   chown jenkins -R path/to/directory
   chgrp jenkins -R path/to/directory
```

Encript file:

```sh
   sudo ansible-vault encrypt  --vault-password-file=/var/lib/jenkins/.vault/prod.txt   /var/lib/jenkins/.vault/prod-secrets.tfvars
```

[Securing Secrets for your IaC using Jenkins, Terraform and Ansible Vault] (https://wbassler23.medium.com/securing-secrets-for-your-iac-using-jenkins-terraform-and-ansible-vault-7009e0a7eb32)

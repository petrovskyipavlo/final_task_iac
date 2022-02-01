#!/bin/bash
sudo ansible-vault encrypt  --vault-password-file=/var/lib/jenkins/.vault/prod.txt   /var/lib/jenkins/.vault/prod-secrets.tfvars
sudo chown jenkins -R /var/lib/jenkins/.vault
sudo chgrp jenkins -R /var/lib/jenkins/.vault
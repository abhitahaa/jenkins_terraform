#!/bin/bash
echo "Installing Terraform for ubuntu and debain"

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update && sudo apt-get install terraform -y

sudo terraform --version > /dev/null

if [ "$?" -eq 0 ]; then
  echo "Terraform has been successfully installed"
  location=$(which terraform)
  echo "Terraform install location is:" $location
else
  echo "Terraform has not been deployed successfully try again"
fi



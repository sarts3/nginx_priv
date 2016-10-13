# NGINX_PRIV
Deploying a nginx in an aws private network with terraform, ansible and docker

## How to Prepare
Create a key_pair under root directory with names id_rsa and id_rsa.pub

Create file terraform/key-pairs.tf fillig up aws credential info:

provider "aws" {

  region     = ""

  access_key = ""

  secret_key = ""

}


## How to Execute
$> cd terraform

$> terraform get

$> terraform apply

$> cd ../ansible


You'll need to update hosts and local-sarti.yml in order to adapt recipe to the given aws public ips

$> ansible-playbook foo.yml

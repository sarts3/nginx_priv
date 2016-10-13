# Management vars
variable "project" {
    description = "Project name"
    default     = "project_foo"
}

variable "client" {
    description = "Client name"
    default     = "csarti"
}

variable "app" {
    description = "Application name"
    default = "app_foo"
}

variable "app_id" {
    description = "Application identifier"
    default = "12345678"
}

variable "amis" {
    default = {
        us-west-2 = "ami-9abea4fb"
        eu-west-1 = "ami-f95ef58a"
    }
}

variable "amisnat" {
    default = {
	    us-west-2 = "ami-030f4133"
        eu-west-1 = "ami-30913f47"
    }
}

variable "Env" {
        description = "Env tag"
        default     = "CSF"
}
variable "Billing" {
    description = "Billing tag"
    default     = "CSF"
}
variable "ssh_config" {
    description = "ssh configuration file path to be used later by Ansible"
    default     = "ssh_config"
}

# Instace type
variable "modsec_instance_type" {
    default = "t2.small"
}

# Instace type
variable "server_instance_type" {
    default = "t2.small"
}

# Instace type
variable "probe_instance_type" {
    default = "m1.small"
}

variable "modsec_count" {
    default = "1"
}

variable "server_count" {
    default = "1"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    default = "10.0.0.0/24"
}

variable "server_cidr_block" {
  default = "10.0.1.0/24"
}

variable "enable_dns_support" {
    default = "true"
}
variable "enable_dns_hostnames" {
    default = "true"
}

variable "aws_region" {
    description = "AWS region for credentials"
    default     = "eu-west-1"
}

variable "public_key" {
    default = "/home/csarti/code/terraform_ansible_exercise/id_rsa.pub"
}

# VPC #
resource "aws_vpc" "foovpc" {
        cidr_block = "${var.vpc_cidr}"
        enable_dns_support = "${var.enable_dns_support}"
        enable_dns_hostnames = "${var.enable_dns_hostnames}"
        tags {
                Name    = "${var.Env}-VPC-${var.project}"
                Billing = "${var.Billing}"
                Env     = "${var.Env}"
        }
}

resource "aws_internet_gateway" "default" {
        vpc_id = "${aws_vpc.foovpc.id}"
        tags {
                Name    = "${var.Env}-GW-PUB-${var.project}"
                Billing = "${var.Billing}"
                Env     = "${var.Env}"
        }
}


# PUBLIC SUBNET #

#SUBNET
resource "aws_subnet" "subnet_pub" {
        vpc_id = "${aws_vpc.foovpc.id}"
        cidr_block = "${var.public_subnet_cidr}"
        map_public_ip_on_launch = true
        tags {
                Name    = "${var.Env}-Subnet-PUB-${var.client}-${var.project}-${var.app}-${var.app_id}"
                Billing = "${var.Billing}"
                Env     = "${var.Env}"
        }
}

# ROUTING #

resource "aws_route_table" "pub_routing" {
        vpc_id = "${aws_vpc.foovpc.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.default.id}"
        }
        tags {
                Name    = "${var.Env}-Route-PUB-${var.client}-${var.project}-${var.app}-${var.app_id}"
                Billing = "${var.Billing}"
                Env     = "${var.Env}"
        }
}

resource "aws_route_table_association" "public" {
        subnet_id      = "${aws_subnet.subnet_pub.id}"
        route_table_id = "${aws_route_table.pub_routing.id}"
}

# Security Group #
resource "aws_security_group" "probe" {
    name = "Probe Security Group"
    description = "Probe Security Group"
    vpc_id = "${aws_vpc.foovpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port = 0
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["${aws_subnet.subnet_priv.cidr_block}","${aws_subnet.subnet_pub.cidr_block}"]
    }

    egress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
            Name    = "${var.Env}-SG-${var.client}-${var.project}-${var.app}-${var.app_id}"
            Billing = "${var.Billing}"
            Env     = "${var.Env}"
    }
}

# INSTANCE
resource "aws_instance" "chimera_probe" {
    ami = "${lookup(var.amisnat, var.aws_region)}"
    instance_type = "${var.probe_instance_type}"
    subnet_id = "${aws_subnet.subnet_pub.id}"
    security_groups = ["${aws_security_group.probe.id}"]
    associate_public_ip_address = true
    source_dest_check = 0
    key_name = "${aws_key_pair.deployer.key_name}"
    count = 1
    tags {
            Name    = "${var.Env}-${var.client}-${var.project}-${var.app}-${var.app_id}"
            Billing = "${var.Billing}"
            Env     = "${var.Env}"
    }
}

resource "aws_eip" "chimera_probe" {
    instance = "${aws_instance.chimera_probe.id}"
    vpc = true
}

# Security Group #
resource "aws_security_group" "modsec" {
    name = "ModSec Security Group"
    description = "ModSec Security Group"
    vpc_id = "${aws_vpc.foovpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 54321
        to_port = 54321
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
            Name    = "${var.Env}-SG-${var.project}"
            Billing = "${var.Billing}"
            Env     = "${var.Env}"
    }
}

# INSTANCE
resource "aws_instance" "modsec" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "${var.modsec_instance_type}"
    subnet_id = "${aws_subnet.subnet_pub.id}"
    vpc_security_group_ids = ["${aws_security_group.modsec.id}"]
    associate_public_ip_address = true
    source_dest_check = 0
    key_name = "${aws_key_pair.deployer.key_name}"
    count = "${var.modsec_count}"
    tags {
            Name    = "${var.Env}-modsec-${var.project}"
            Billing = "${var.Billing}"
            Env     = "${var.Env}"
    }
}


# SUBNET

resource "aws_subnet" "subnet_priv" {
        vpc_id = "${aws_vpc.foovpc.id}"
        cidr_block = "${var.server_cidr_block}"
        tags {
                Name    = "${var.Env}-subnet-priv-server-${var.project}"
                Billing = "${var.Billing}"
                Env     = "${var.Env}"
        }
}

#ROUTE
resource "aws_route_table" "table_priv" {
        vpc_id = "${aws_vpc.foovpc.id}"
        route {
                cidr_block  = "0.0.0.0/0"
                instance_id = "${aws_instance.chimera_probe.id}"
        }
        tags {
                Name    = "${var.Env}-Route-tosubpub-server-${var.project}"
                Billing = "${var.Billing}"
                Env     = "${var.Env}"
        }
}

#ROUTE TO PUBLIC SUBNET
resource "aws_route_table_association" "priv" {
        subnet_id       = "${aws_subnet.subnet_priv.id}"
        route_table_id  = "${aws_route_table.table_priv.id}"
}


# Security Group #
resource "aws_security_group" "server" {
    name = "Server Security Group"
    description = "Server Security Group"
    vpc_id = "${aws_vpc.foovpc.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.probe.id}"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["${aws_security_group.modsec.id}"]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        security_groups = ["${aws_security_group.modsec.id}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
            Name    = "${var.Env}-SG-${var.project}"
            Billing = "${var.Billing}"
            Env     = "${var.Env}"
    }
}

# INSTANCE
resource "aws_instance" "server" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "${var.server_instance_type}"
    subnet_id = "${aws_subnet.subnet_priv.id}"
    vpc_security_group_ids = ["${aws_security_group.server.id}"]
    associate_public_ip_address = false
    source_dest_check = 0
    key_name = "${aws_key_pair.deployer.key_name}"
    private_ip = "10.0.1.144"
    count = "${var.server_count}"
    tags {
            Name    = "${var.Env}-server-${var.project}"
            Billing = "${var.Billing}"
            Env     = "${var.Env}"
    }
    #depends_on = "aws_eip.pub_server"
}

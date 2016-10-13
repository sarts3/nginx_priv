resource "aws_key_pair" "deployer" {
    key_name = "${var.client}-${var.project}-${var.app}-${var.app_id}"
    public_key = "${file(var.public_key)}"
}

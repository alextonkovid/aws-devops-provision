data "aws_instance" "k3s_instance" {
  filter {
    name   = "tag:Name"
    values = ["k3s_instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "aws_instance" "nat_instance" {
  filter {
    name   = "tag:Name"
    values = ["nat_instance"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

data "aws_eip" "nat_eip" {
  filter {
    name   = "tag:Name"
    values = ["nat_eip"]
  }
}

resource "terraform_data" "bootstrap-k3s" {
  triggers_replace = [data.aws_instance.k3s_instance.id]

  connection {
    type                = "ssh"
    user                = "ubuntu"
    private_key         = file("~/.ssh/id_ed25519")
    host                = data.aws_instance.k3s_instance.private_ip
    bastion_host        = data.aws_eip.nat_eip.public_ip
    bastion_user        = "ec2-user"
    bastion_private_key = file("~/.ssh/id_ed25519")
  }

  provisioner "file" {
    source      = "data"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/data/bootstrap-k3s.sh",
      "/tmp/data/bootstrap-k3s.sh args",
    ]
  }
  # For local configs copy

  # provisioner "local-exec" {
  #   command = "bash data/copy-kube-conf.sh"

  #   environment = {
  #     PRIVATE_INSTANCE_IP = aws_instance.k3s_instance.private_ip
  #     BASTION_HOST_IP     = aws_eip.nat_eip.public_ip
  #   }
  # }
}

resource "terraform_data" "bootstrap-bastion" {
  triggers_replace = [data.aws_instance.nat_instance.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_ed25519")
    host        = data.aws_eip.nat_eip.public_ip
  }

  provisioner "file" {
    source      = "data/nginx"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx/config-nginx.sh",
      "/tmp/nginx/config-nginx.sh args",
    ]
  }

}


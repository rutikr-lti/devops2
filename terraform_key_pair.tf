provider "aws" {
  region = "ap-south-1"
}

#security group
resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "allow ssh and http"
  #vpc_id      = ""

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
#security group end here

resource "aws_instance" "instance1" {
  ami               = "ami-08718895af4dfa033"
  availability_zone = "ap-south-1a"
  instance_type     = "t2.micro"
  security_groups   = ["${aws_security_group.sg1.name}"]
  /* the key zoomkey must be downloaded in your machine from where
  you are executing this code. So first create the key, download it
  and then use it */
  key_name = "dev"
  #root disk
  root_block_device {
    volume_size           = "8"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  #additional data disk
  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_size           = "6"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<-EOF
        #!/bin/bash
        sudo yum install httpd -y
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "<h1>This is Rutik Rekhawar!</h1>" | sudo tee /var/www/html/index.html
  EOF

  tags = {
    Name     = "instance1"
    Stage    = "na"
    Location = "India"
  }

}
resource "aws_key_pair" "auto-key" {
  key_name   = "auto-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqz5MeSk6iUQveIrriXV5wAIn6RCZdxxC2B9GKmDLzokcCw0o3voMY4ygYVbzYK+XKyfnVdp/fUUX5iZVsb6Y/UdZ4Iyd2h/0OxZRr0+MbSZH7Lcb7YMuFniE3HkMDDKHr3nfv/LFyDWNS/Xdlj+bVymCQKSdXxzUxlYKGBXHTwoiJuDJzW1De5ac6V/5lozriEHJiBczIooWnf2ao8ZI1185yG2H1i7QxY6krDPnYadlfyHIxJ1IWt6olMWlJJCW41PXIZHx9kfii+wCkF1WyOD+5mC786rS5Xc03fUr1G6Cg2HVYJOS+vL6zCrnojWRJD2TQ5hY3p77YkjZYlGsltAxzB1tKPFv+Qna/erLlt0DyAA50gV9Li4rQVO5jZEhKeA2fVZ0T09zc9mZN6Wmm0KtoL3FOBEOGYts/x33SARpTgOLzEtDdhDCOK4AFzV5PBHD/PqO2VFMxtWcBH81YepRaoGUbfJ7saf/SWi3rZ+xcXoYSIZnMpTMPBirimSM= root@terra.example.com"
}
resource "aws_eip" "lb" {
  instance = aws_instance.instance1.id
  #domain   = "vpc"
}

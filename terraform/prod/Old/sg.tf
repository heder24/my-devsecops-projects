
######################### public security groups  ##################################
resource "aws_security_group" "public_sg" {
  name        = "${var.environment}-public-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description = "Allow HTTPS from public IPV4"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "HTTP from public  IPV4"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description      = "HTTPS from public IPV6"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from public IPV6"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]

  }
  egress {
    description = "HTTPS to anywhere IPV4"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP to anywhere IPV4"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description      = "HTTP to anywhere IPV6"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    description      = "HTTPS to anywhere IPV6"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]

  }
  tags = {
    Name        = "${var.environment}-public-sg"
    Env         = var.environment
    Provisioner = var.provisioner
  }
}

######################### private security groups  ##################################
resource "aws_security_group" "private_sg" {
  name        = "${var.environment}-private-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description     = "HTTPS from private IPV4"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]

  }

  ingress {
    description     = "HTTP from private IPV4"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]

  }

  egress {
    description = "HTTPS to anywhere IPV4"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]

  }

  tags = {
    Name        = "${var.environment}-private-sg"
    Env         = var.environment
    Provisioner = var.provisioner
  }
}

######################### bastion security groups  ##################################
resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description = "SSH from anywhere IPV4"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description      = "SSH from anywhere IPV6"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]

  }

  egress {
    description = "SSH to anywhere IPV4"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description      = "SSH to anywhere IPV6"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]

  }


  tags = {
    Name        = "${var.environment}-bastion-sg"
    Env         = var.environment
    Provisioner = var.provisioner
  }
}


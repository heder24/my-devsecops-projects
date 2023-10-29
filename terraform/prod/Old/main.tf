########################## prod VPC ######################

resource "aws_vpc" "prod" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = var.vpc_tags
}

######################## IGW ############################

resource "aws_internet_gateway" "prod" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name        = "${var.environment}-${var.igw_name}"
    Env         = var.environment
    Provisioner = var.provisioner
  }
}
######################## EIP ########################
resource "aws_eip" "prod" {
  #instance = "${aws_instance.web.id}"
  vpc = true
}
######################### NAT #######################

resource "aws_nat_gateway" "prod" {
  allocation_id = aws_eip.prod.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name        = "${var.environment}-ngw"
    Env         = var.environment
    Provisioner = var.provisioner
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prod]
}
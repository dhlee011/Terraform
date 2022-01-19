######################## efs ########################


resource "aws_security_group" "efs_sg" {
  name        = "${var.vpc_name}-efs-sg"
  description = "controls access to efs"

  vpc_id = aws_vpc.default.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    security_groups = [aws_security_group.eks_cluster_sg.id , aws_security_group.eks_nodes.id ]
  }

  tags =  {
      "Name" = "${var.vpc_name}-efs-sg"
    }  
  
}

resource "aws_efs_file_system" "efs" {
encrypted = true

}


resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.efs.id
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count = length(var.availability_zones_without_b) 
  
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(aws_subnet.private.*.id, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}


######################## eks cluster ########################

resource "aws_iam_role" "eks-cluster" {
  name = "terraform-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}


resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-${var.vpc_name}-sg"

  vpc_id      = aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "eks_cluster_inbound" {
  description              = "Allow unmanaged nodes to communicate with control plane (all ports)"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 0
  type                     = "ingress"
}



resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster-${var.vpc_name}"
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    subnet_ids         = aws_subnet.private[*].id
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSVPCResourceController,
  ]
}



######################## eks worknode ########################


resource "aws_iam_role" "eks-node" {
  name = "terraform-eks-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.private[*].id


  remote_access {
  ec2_ssh_key     = var.key_pair
  source_security_group_ids = [aws_security_group.manage-ec2-sg.id]
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}


resource "aws_security_group" "eks_nodes" {
  name        = "eks-worke-node-${var.vpc_name}-sg"

  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.manage-ec2-sg.id]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.manage-ec2-sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


######################## main ########################

resource "aws_vpc" "default" {
  cidr_block           = "10.${var.cidr_numeral}.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.vpc_name}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}


resource "aws_nat_gateway" "nat" {
  count = length(var.availability_zones_without_b)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_internet_gateway.default]

  tags = {
    Name = "NAT-GW${count.index}-${var.vpc_name}"
  }

}

resource "aws_eip" "nat" {
  # Count value should be same with that of aws_nat_gateway because all nat will get elastic ip
  count = length(var.availability_zones_without_b)
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_subnet" "public" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/24"
  availability_zone = element(var.availability_zones_without_b, count.index)


  map_public_ip_on_launch = true

  tags = {
    Name = "public${count.index}-${var.vpc_name}"
    "kubernetes.io/cluster/eks-cluster-${var.vpc_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "publicrt-${var.vpc_name}"
  }
}



resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}



######################## PRIVATE SUBNETS ########################

resource "aws_subnet" "private" {
  count  = length(var.availability_zones_without_b) 
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/24" 
  availability_zone = element(var.availability_zones_without_b, count.index) 

  tags = { 
    Name               = "private${count.index}-${var.vpc_name}"
    Network            = "Private"
  }
}


resource "aws_route_table" "private" {
  count  = length(var.availability_zones_without_b)
  vpc_id = aws_vpc.default.id

  route {
  cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Name    = "private${count.index}rt-${var.vpc_name}"
    Network = "Private"

  }
}


# Route Table Association for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones_without_b)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}


resource "aws_security_group" "manage-ec2-sg" {
  name = "manage-ec2-sg"
  vpc_id = aws_vpc.default.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

   }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks      = ["0.0.0.0/0"]

  }
}




resource "aws_instance" "ec2" {
  ami = "ami-0e4a9ad2eb120e054"
  instance_type = "t2.micro"
  subnet_id = element(aws_subnet.public.*.id, 0)
  key_name = "${var.key_pair}"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.manage-ec2-sg.id]
}



######################## variable ########################



variable "vpc_name" {
  description = "The name of the VPC"
}

variable "cidr_numeral" {
  description = "The VPC CIDR numeral (10.x.0.0/16)" 
}

variable "aws_region" {
  default = "ap-northeast-2"
}

variable "shard_id" {
  default = ""
}

variable "shard_short_id" {
  default = ""
}

variable "cidr_numeral_public" { 
  default = {
    "0" = "0"
    "1" = "16"
    "2" = "32"
  }
}

variable "cidr_numeral_private" {
  default = {
    "0" = "80"
    "1" = "96"
    "2" = "112"
  }
}


variable "cidr_numeral_private_db" {
  default = {
    "0" = "160"
    "1" = "176"
    "2" = "192"
  }
}






variable "availability_zones_without_b" {
  type        = list(string)
  description = "A comma-delimited list of availability zones except for ap-northeast-2b"#["ap-northeast-2a" , "ap-northeast-2c"]
}


variable "key_pair" {
    default = "tests"
}




###################  dev main ###############


module "dev_vpc" {
  source = "/home/ec2-user/terraform/module"
  cidr_numeral = "1"
  vpc_name ="dev"
  availability_zones_without_b = ["ap-northeast-2a", "ap-northeast-2c"]
  cidr_numeral_public = ["0","16","32"]
  cidr_numeral_private = ["100","116","132"]

}


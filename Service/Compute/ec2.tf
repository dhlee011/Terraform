resource "aws_instance" "kubectl_ec2" {
  ami                    = var.Bastion_ami
  instance_type          = "t2.micro"
  subnet_id              = var.eks_subnet[0]
  vpc_security_group_ids = [aws_security_group.eks_cluster_sg.id]
  user_data = file("/terraform/Mod/Svc/Compute/userdata")
  tags = {
    Name = var.Bastion_ec2_name
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "eksClusterRole"
  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  name               = "eksNodeRole"
  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}


resource "aws_eks_cluster" "eks_cluster" {
  name     = var.ekscluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = [
      var.eks_subnet[0],    # EKS Owned ENI Subnet 
      var.eks_subnet[1]
    ]
    endpoint_private_access = true  
    endpoint_public_access  = false 
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"  # 인증 모드 설정 (CONFIG_MAP, EKS API, EKS API 및 CONFIG_MAP)
    bootstrap_cluster_creator_admin_permissions = true          # 클러스터 관리자 액세스 허용
  }

  tags = {
    Name = var.ekscluster_name 
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eksnodegroup_name  
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
      var.eks_subnet[0],    # EKS Owned ENI Subnet 
      var.eks_subnet[1]
    ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }  

  tags = {
    Name = var.eksnodegroup_name   
  }

#  launch_template {
#    id      = aws_launch_template.eks_node_template.id
#    version = "$Latest"  
#  }
}

resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = var.eks_vpc[0]

  ingress {
    from_port   = 1
    to_port     = 65000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.ekscluster_name
  }
}

resource "aws_iam_instance_profile" "eks_instance_profile" {
  name = "eksNodeInstanceProfile"
  role = aws_iam_role.eks_node_role.name
}

resource "aws_launch_template" "eks_node_template" {
  name_prefix   = var.launch_template
  image_id      = var.eksNode_ami 
  instance_type = "t3.medium"

  user_data = base64encode(file("/terraform/Mod/Svc/Compute/userdata"))

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_instance_profile.name
  }

  tags = {
    Name = var.launch_template
  }
}
resource "aws_ec2_tag" "subnet_cluster_tag_1" {
  resource_id = "subnet-0aa88c728d36e67e5"
  key         = "kubernetes.io/cluster/dashboard-app"
  value       = "owned"
}

resource "aws_ec2_tag" "subnet_elb_tag_1" {
  resource_id = "subnet-0aa88c728d36e67e5"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "subnet_cluster_tag_2" {
  resource_id = "subnet-067b756a1fe79b1c4"
  key         = "kubernetes.io/cluster/dashboard-app"
  value       = "owned"
}

resource "aws_ec2_tag" "subnet_elb_tag_2" {
  resource_id = "subnet-067b756a1fe79b1c4"
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

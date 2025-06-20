
# Website on EKS

Deploy a containerized frontend and dashboard site on Amazon EKS using Terraform and Kubernetes manifests, exposed via AWS Application Load Balancer (ALB), with CI/CD friendly setup and centralized logging.

---

## 📦 Repository Contents

- `terraform/` – Terraform IaC to provision:
  - IAM roles (EKS cluster, node group, bastion, ALB Controller, Fluent Bit)
  - EKS cluster and node group
  - Bastion host with `kubectl`, `eksctl`, Docker, and Helm
  - ALB Controller service account with OIDC trust
  - Security groups for secure communication
  - Subnet tagging for Kubernetes load-balancer compatibility

- `k8s-manifests/` – Kubernetes YAMLs:
  - `namespace.yaml` – `appspace` where apps are deployed
  - `frontend-deployment.yaml` + `service.yaml` – Deploy and expose frontend
  - `dashboard-deployment.yaml` + `service.yaml` – Deploy and expose dashboard in `/dashboard` subpath
  - `ingress.yaml` – Configure ALB Ingress with correct path routing
  - `cw_namespace.yaml` – cloudwatch for logging are deployed

---

## 🚀 Deployment Steps

### 1. Provision Infrastructure with Terraform  
```bash
cd terraform
terraform init
terraform apply   -var="cluster_name=website-eks"   -var="region=us-west-2"   -var="subnet_ids=[\"subnet-aaa\",\"subnet-bbb\"]"   -var="vpc_id=vpc-xxxxxx"
```

### 3. Install `kubectl`, `eksctl`, Helm (already in user_data)  
Verify:
```bash
kubectl version --client
helm version
eksctl version
docker --version
```

### 4. Configure `kubectl` for EKS  
```bash
aws eks --region us-west-2 update-kubeconfig --name website-eks
kubectl get nodes
```

# 5 Create IAM OIDC Provider for EKS
```bash
eksctl utils associate-iam-oidc-provider --cluster dashboard-app --region us-west-1 --approve
```

### 6. Apply App Manifests  
```bash
kubectl apply -f ../k8s-manifests/namespace.yaml
kubectl apply -f ../k8s-manifests/frontend-deployment.yaml
kubectl apply -f ../k8s-manifests/dashboard-deployment.yaml
kubectl apply -f ../k8s-manifests/service.yaml
kubectl apply -f ../k8s-manifests/ingress.yaml
kubectl apply -f ../k8s-manifests/cw_namespace.yaml
```

# Install the AWS Load Balancer Controller
```bash
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=dashboard-app \
  --set serviceAccount.create=false \
  --set region=us-west-1 \
  --set vpcId=vpc-074ed8073bb88a2d0 \
  --set serviceAccount.name=aws-load-balancer-controller
```

# Install Fluent Bit via Helm for CloudWatch Logs to Log Group
```bash
helm upgrade --install aws-for-fluent-bit aws-observability/aws-for-fluent-bit \
  --namespace aws-observability \
  --set cloudWatch.enabled=true \
  --set cloudWatch.region=us-west-1 \
  --set cloudWatch.logGroupName=eks-app-logs \
  --set serviceAccount.create=true \
  --set serviceAccount.name=fluent-bit-sa \
  --set cloudWatch.logStreamPrefix=from-fluent-bit-
```
### 7. Verify ALB & Ingress  
```bash
kubectl get ingress -n appspace
# Copy the ALB DNS from ADDRESS column
# Access:
http://<ALB-DNS>/
http://<ALB-DNS>/dashboard
```

### 8. Centralized Logging via Fluent Bit (CloudWatch)  
Already deployed via Terraform Helm values:
- Log group: `eks-app-logs`
- Log streams prefixed with `from-fluent-bit-`

Check logs in [AWS Console → CloudWatch → Log groups]

---

## ✅ Key Features

- **Bastion Host** with `kubectl`/`eksctl`/Docker/Helm pre-configured  
- **ALB Ingress Controller** with correct IRSA and subnet tagging  
- **Routing rules**:
  - `/` → `frontend`
  - `/dashboard` → `dashboard` (served from `/usr/share/nginx/html/dashboard`)
- **Logging**: Fluent Bit DaemonSet sends logs to CloudWatch
- **Security**: Use Terraform-managed IAM roles, SG rules, and IRSA

---

## 🔄 Tips & Troubleshooting

- Use `kubectl rollout restart deployment/dashboard -n appspace` after updating its image.
- If you get HTTP 404 or NGINX Stderr when hitting `/`, ensure dashboard files are under `/dashboard/`.
- To fix missing ALB, re-tag subnets via Terraform (e.g., `kubernetes.io/role/elb = 1`) and rerun `kubectl apply ingress.yaml`.
- If pods are `Pending` → node type likely too small. Use `t3.medium` or larger instead of `t2.micro`.
- Restart ALB Controller after IAM rule changes:
  ```bash
  kubectl rollout restart deployment aws-load-balancer-controller -n kube-system
  ```

---

## 🧩 Library Attribution

This setup is based on practices discussed during conversation, with integration logic referencing AWS official documentation and EKS best practices.

---

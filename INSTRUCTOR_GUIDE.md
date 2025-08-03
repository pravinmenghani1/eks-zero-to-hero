# Kubernetes E-Commerce Lab - Instructor Guide

## 🎯 **Lab Overview**
This hands-on lab teaches Kubernetes fundamentals through deploying a complete e-commerce application with microservices architecture.

**Duration:** 3-4 hours  
**Difficulty:** Intermediate  
**Prerequisites:** Basic Docker knowledge, AWS account access

---

## 📚 **Learning Objectives Covered**

### **Core Kubernetes Concepts:**
- ✅ Namespaces and resource isolation
- ✅ Deployments and ReplicaSets
- ✅ Services and service discovery
- ✅ ConfigMaps for configuration management
- ✅ Jobs for initialization tasks
- ✅ Ingress controllers and external access
- ✅ Persistent storage concepts

### **Real-World Patterns:**
- ✅ Microservices architecture
- ✅ Multi-tier application deployment
- ✅ Database integration
- ✅ Frontend/backend separation
- ✅ Load balancing and scaling

---

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ingress Tier  │    │  Frontend Tier  │    │  Backend Tier   │    │ Database Tier   │
│                 │    │                 │    │                 │    │                 │
│ Nginx Ingress   │    │ Frontend        │    │ User Service    │    │ MongoDB         │
│ Controller      │───▶│ (nginx)         │───▶│ Product Service │───▶│ (EmptyDir)      │
│                 │    │                 │    │ Order Service   │    │                 │
│                 │    │                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
ingress-nginx          ecommerce-frontend     ecommerce-backend      ecommerce-database
```

---

## 🚀 **Pre-Lab Setup**

### **AWS Environment Requirements:**
- EKS cluster creation permissions
- EC2 instance management
- VPC and security group access
- IAM role creation/management
- Load balancer provisioning

### **Student Prerequisites:**
```bash
# Verify tools are installed
aws --version
eksctl version
kubectl version --client
```

### **Estimated Costs:**
- **EKS Cluster:** ~$0.10/hour
- **EC2 Instances:** ~$0.20/hour (2 x t3.medium)
- **Load Balancer:** ~$0.025/hour
- **Total:** ~$0.325/hour per student

---

## 📋 **Lab Execution Guide**

### **Phase 1: Infrastructure Setup (20 minutes)**

**Instructor Demo:**
1. Explain EKS architecture
2. Show cluster creation process
3. Discuss add-ons and their purposes

**Student Activity:**
```bash
./create-eks-cluster.sh
```

**Teaching Points:**
- EKS vs self-managed Kubernetes
- Node groups and scaling
- Add-ons: VPC CNI, CoreDNS, Metrics Server
- OIDC provider for service accounts

### **Phase 2: Application Deployment (45 minutes)**

**Step-by-Step Walkthrough:**

#### **Step 1: Namespaces (5 minutes)**
```bash
kubectl apply -f namespaces/namespaces.yaml
kubectl get namespaces | grep ecommerce
```
**Explain:** Resource isolation, RBAC boundaries, network policies

#### **Step 2: Database Layer (10 minutes)**
```bash
kubectl apply -f database/mongodb.yaml
kubectl get pods -n ecommerce-database -w
```
**Explain:** StatefulSets vs Deployments, persistent storage, emptyDir limitations

#### **Step 3: Backend Services (15 minutes)**
```bash
kubectl apply -f backend/
kubectl get all -n ecommerce-backend
```
**Explain:** Microservices patterns, service discovery, ConfigMaps vs Secrets

#### **Step 4: Data Initialization (5 minutes)**
```bash
kubectl apply -f backend/init-data-job.yaml
kubectl logs job/init-sample-data -n ecommerce-backend
```
**Explain:** Jobs vs CronJobs, initialization patterns, idempotency

#### **Step 5: Frontend (10 minutes)**
```bash
kubectl apply -f frontend/
kubectl get pods -n ecommerce-frontend
```
**Explain:** nginx configuration, reverse proxy, static content serving

### **Phase 3: External Access (30 minutes)**

#### **Ingress Controller Setup:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s
```

#### **Ingress Resource:**
```bash
kubectl apply -f ingress/ingress-controller.yaml
kubectl get ingress -n ecommerce-frontend
```

**Teaching Points:**
- Ingress vs LoadBalancer services
- AWS Load Balancer Controller vs nginx
- DNS propagation and SSL termination

### **Phase 4: Hands-On Exploration (60 minutes)**

**Guided Exercises:**

#### **Exercise 1: Scaling (10 minutes)**
```bash
kubectl scale deployment frontend --replicas=5 -n ecommerce-frontend
kubectl get pods -n ecommerce-frontend -w
```
**Discuss:** HPA, resource requests/limits, cluster autoscaling

#### **Exercise 2: Service Discovery (15 minutes)**
```bash
kubectl exec -it deployment/user-service -n ecommerce-backend -- /bin/sh
# Inside pod:
nslookup mongodb-service.ecommerce-database.svc.cluster.local
wget -qO- http://product-service:3002/products
```
**Discuss:** DNS resolution, service types, network policies

#### **Exercise 3: Configuration (10 minutes)**
```bash
kubectl get configmaps -n ecommerce-backend
kubectl describe configmap user-service-config -n ecommerce-backend
```
**Discuss:** ConfigMaps vs Secrets, volume mounts vs env vars

#### **Exercise 4: Troubleshooting (15 minutes)**
```bash
kubectl describe pod <failing-pod> -n <namespace>
kubectl logs -f deployment/<deployment> -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```
**Discuss:** Common failure modes, debugging strategies

#### **Exercise 5: Application Testing (10 minutes)**
- Access the application via Load Balancer URL
- Test user registration, product browsing, cart, checkout
- Demonstrate end-to-end functionality

### **Phase 5: Cleanup (15 minutes)**
```bash
bash cleanup.sh
bash cleanup-eks-cluster.sh
```
**Emphasize:** Cost management, resource cleanup importance

---

## 🎓 **Teaching Tips**

### **Key Concepts to Emphasize:**
1. **Declarative vs Imperative:** Show both `kubectl apply` and `kubectl create`
2. **Resource Hierarchy:** Namespace → Deployment → ReplicaSet → Pod
3. **Service Types:** ClusterIP, NodePort, LoadBalancer, ExternalName
4. **Configuration Management:** ConfigMaps, Secrets, environment variables
5. **Networking:** Pod-to-pod, service discovery, ingress

### **Common Student Questions:**
**Q:** "Why use namespaces instead of separate clusters?"  
**A:** Cost efficiency, resource sharing, simplified management

**Q:** "When to use Deployments vs StatefulSets?"  
**A:** Stateless vs stateful applications, persistent identity needs

**Q:** "How does service discovery work?"  
**A:** DNS resolution, environment variables, service mesh

**Q:** "What's the difference between ConfigMaps and Secrets?"  
**A:** Secrets are base64 encoded and have additional security features

### **Troubleshooting Common Issues:**

#### **Pods Stuck in Pending:**
- Check node resources: `kubectl describe nodes`
- Verify PVC binding: `kubectl get pvc -A`
- Check scheduling constraints

#### **Services Not Accessible:**
- Verify endpoints: `kubectl get endpoints`
- Check service selectors match pod labels
- Test from within cluster first

#### **Ingress Not Working:**
- Confirm ingress controller is running
- Check ingress class annotations
- Verify DNS propagation (can take 2-3 minutes)

---

## 📊 **Assessment Rubric**

### **Basic Understanding (60%):**
- [ ] Can explain namespace purpose
- [ ] Understands deployment vs pod relationship
- [ ] Knows how services enable communication
- [ ] Can use basic kubectl commands

### **Intermediate Skills (30%):**
- [ ] Can troubleshoot failing pods
- [ ] Understands ConfigMap usage
- [ ] Can scale applications
- [ ] Explains ingress functionality

### **Advanced Concepts (10%):**
- [ ] Discusses production considerations
- [ ] Suggests improvements to architecture
- [ ] Understands security implications
- [ ] Can design similar applications

---

## 🔧 **Lab Variations**

### **Extended Version (Add 1-2 hours):**
- Add Helm charts
- Implement network policies
- Add monitoring with Prometheus
- Implement autoscaling (HPA/VPA)

### **Simplified Version (Reduce 1 hour):**
- Use single namespace
- Pre-built container images
- Skip ingress setup
- Use NodePort services

### **Advanced Version (Add 2-3 hours):**
- Add service mesh (Istio)
- Implement GitOps with ArgoCD
- Add security scanning
- Multi-region deployment

---

## 📚 **Additional Resources for Students**

### **Documentation:**
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

### **Practice Environments:**
- [Katacoda Kubernetes Scenarios](https://www.katacoda.com/courses/kubernetes)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [EKS Workshop](https://www.eksworkshop.com/)

---

## 🎯 **Learning Outcomes Assessment**

By the end of this lab, students should be able to:

1. **Deploy** a multi-tier application on Kubernetes
2. **Explain** the relationship between pods, services, and deployments
3. **Troubleshoot** common Kubernetes issues
4. **Scale** applications based on demand
5. **Configure** applications using ConfigMaps
6. **Expose** applications to external traffic
7. **Clean up** resources to manage costs

This lab provides a solid foundation for students to continue their Kubernetes journey and apply these concepts in real-world scenarios.
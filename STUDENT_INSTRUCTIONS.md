# Kubernetes E-Commerce Learning Lab
## Step-by-Step Instructions for Students

### 🎯 **Learning Objectives**
By completing this lab, you will understand:
- Kubernetes namespaces and resource isolation
- Deployments, ReplicaSets, and pod management
- Services and internal communication
- ConfigMaps for configuration management
- Persistent storage concepts
- Ingress controllers and external access
- Microservices architecture patterns

---

## 📋 **Prerequisites**

### **Required Tools:**
- AWS CLI configured with appropriate permissions
- `eksctl` installed
- `kubectl` installed
- Basic understanding of Docker and containers

### **AWS Permissions Needed:**
- EKS cluster creation/deletion
- EC2 instance management
- VPC and networking resources
- IAM role management

---

## 🚀 **Lab Setup**

### **Step 1: Clone the Repository**
```bash
# Navigate to your working directory
cd ~/Documents
mkdir kubernetes-lab && cd kubernetes-lab

# Copy the provided files to this directory
# (Your instructor will provide the eks folder)
```

### **Step 2: Create EKS Cluster**
```bash
cd eks
chmod +x create-eks-cluster.sh
./create-eks-cluster.sh
```

**⏱️ Expected Time:** 15-20 minutes

**🎓 Learning Points:**
- EKS cluster architecture
- Node groups and worker nodes
- Add-ons (VPC CNI, CoreDNS, etc.)
- OIDC provider setup

---

## 🏗️ **E-Commerce Application Deployment**

### **Step 3: Deploy the Application**
```bash
cd ecommerce-k8s/scripts
chmod +x deploy-step-by-step.sh
./deploy-step-by-step.sh
```

**📚 What You'll Learn at Each Step:**

#### **Step 1: Namespaces** 
```bash
kubectl get namespaces | grep ecommerce
```
- **Concept:** Resource isolation and organization
- **Practice:** See how different application tiers are separated

#### **Step 2: Database Layer**
```bash
kubectl get pods -n ecommerce-database
kubectl describe pod <mongodb-pod-name> -n ecommerce-database
```
- **Concept:** Persistent storage, deployments
- **Practice:** Examine pod specifications and volume mounts

#### **Step 3: Backend Services**
```bash
kubectl get deployments -n ecommerce-backend
kubectl get services -n ecommerce-backend
kubectl get configmaps -n ecommerce-backend
```
- **Concept:** Microservices, service discovery, configuration management
- **Practice:** See how services communicate within the cluster

#### **Step 4: Sample Data**
```bash
kubectl get jobs -n ecommerce-backend
kubectl logs job/init-sample-data -n ecommerce-backend
```
- **Concept:** Kubernetes Jobs for one-time tasks
- **Practice:** Understand initialization patterns

#### **Step 5: Frontend**
```bash
kubectl get pods -n ecommerce-frontend
kubectl describe service frontend-service -n ecommerce-frontend
```
- **Concept:** Web tier, nginx configuration, reverse proxy
- **Practice:** Examine multi-container patterns

#### **Step 6: Ingress**
```bash
kubectl get ingress -n ecommerce-frontend
kubectl get service ingress-nginx-controller -n ingress-nginx
```
- **Concept:** External access, load balancing
- **Practice:** Understand how traffic reaches your application

---

## 🔍 **Hands-On Exploration**

### **Exercise 1: Scaling Applications**
```bash
# Scale frontend to 5 replicas
kubectl scale deployment frontend --replicas=5 -n ecommerce-frontend

# Watch pods being created
kubectl get pods -n ecommerce-frontend -w

# Scale back to 3
kubectl scale deployment frontend --replicas=3 -n ecommerce-frontend
```

### **Exercise 2: Service Discovery**
```bash
# Exec into a backend pod
kubectl exec -it deployment/user-service -n ecommerce-backend -- /bin/sh

# Test internal service communication
wget -qO- http://mongodb-service.ecommerce-database.svc.cluster.local:27017
wget -qO- http://product-service:3002/products
exit
```

### **Exercise 3: Configuration Management**
```bash
# View ConfigMaps
kubectl get configmaps -n ecommerce-backend
kubectl describe configmap user-service-config -n ecommerce-backend

# Edit configuration (demo only - don't save)
kubectl edit configmap user-service-config -n ecommerce-backend
```

### **Exercise 4: Monitoring and Troubleshooting**
```bash
# Check pod status
kubectl get pods --all-namespaces | grep ecommerce

# View logs
kubectl logs -f deployment/user-service -n ecommerce-backend

# Describe resources for troubleshooting
kubectl describe deployment user-service -n ecommerce-backend

# Check events
kubectl get events -n ecommerce-backend --sort-by='.lastTimestamp'
```

---

## 🌐 **Application Testing**

### **Step 7: Access the Application**
```bash
# Get the Load Balancer URL
kubectl get ingress ecommerce-ingress -n ecommerce-frontend

# Wait for DNS propagation (2-3 minutes)
# Then access the URL in your browser
```

### **Test the E-Commerce Features:**
1. **User Registration:** Create a new account
2. **Product Browsing:** View products with images
3. **Shopping Cart:** Add/remove items
4. **Checkout Process:** Place an order
5. **Order History:** View past orders

---

## 📊 **Understanding the Architecture**

### **Namespace Structure:**
```
ecommerce-frontend    → Web interface (nginx + HTML/JS)
ecommerce-backend     → API services (Node.js microservices)
ecommerce-database    → Data storage (MongoDB)
ecommerce-ingress     → External access (unused, ingress in default)
ingress-nginx         → Ingress controller
```

### **Service Communication Flow:**
```
Internet → Load Balancer → Ingress → Frontend Service → Frontend Pods
                                  ↓
Frontend → nginx proxy → Backend Services → Database Service → MongoDB
```

### **Key Kubernetes Resources:**
- **4 Namespaces** for tier isolation
- **7 Deployments** for application workloads
- **6 Services** for internal communication
- **8 ConfigMaps** for configuration and code
- **1 Job** for data initialization
- **1 Ingress** for external access

---

## 🧪 **Advanced Exercises**

### **Exercise 5: Resource Management**
```bash
# Check resource usage
kubectl top pods -n ecommerce-backend
kubectl top nodes

# View resource requests and limits
kubectl describe deployment user-service -n ecommerce-backend
```

### **Exercise 6: Rolling Updates**
```bash
# Update a deployment (example)
kubectl set image deployment/frontend frontend=nginx:1.21-alpine -n ecommerce-frontend

# Watch the rolling update
kubectl rollout status deployment/frontend -n ecommerce-frontend

# Rollback if needed
kubectl rollout undo deployment/frontend -n ecommerce-frontend
```

### **Exercise 7: Network Policies (Optional)**
```bash
# View current network access (all open)
kubectl get networkpolicies --all-namespaces

# This demonstrates why network policies are important in production
```

---

## 🧹 **Cleanup**

### **Step 8: Clean Up Resources**
```bash
# Clean up the application
cd ecommerce-k8s/scripts
bash cleanup.sh

# Delete the EKS cluster
cd ../../
bash cleanup-eks-cluster.sh
```

**⚠️ Important:** Always clean up to avoid AWS charges!

---

## 📝 **Lab Report Questions**

Answer these questions to demonstrate your understanding:

1. **Namespaces:** Why are different application tiers separated into different namespaces?

2. **Services:** How do backend services discover and communicate with each other?

3. **ConfigMaps:** What are the advantages of using ConfigMaps vs. hardcoding configuration?

4. **Scaling:** What happens when you scale a deployment? How does Kubernetes ensure availability?

5. **Ingress:** Explain the path a user request takes from the internet to the database.

6. **Troubleshooting:** What commands would you use to debug a failing pod?

7. **Architecture:** How does this microservices architecture compare to a monolithic application?

---

## 🎓 **Key Takeaways**

After completing this lab, you should understand:

✅ **Kubernetes Fundamentals:**
- Pods, Deployments, Services, ConfigMaps
- Namespaces for resource organization
- Ingress for external access

✅ **Microservices Patterns:**
- Service-to-service communication
- Configuration management
- Data initialization strategies

✅ **Production Concepts:**
- Scaling and high availability
- Monitoring and troubleshooting
- Rolling updates and rollbacks

✅ **Real-World Application:**
- Multi-tier application deployment
- Database integration
- External load balancing

---

## 🆘 **Troubleshooting Guide**

### **Common Issues:**

**Pods in Pending State:**
```bash
kubectl describe pod <pod-name> -n <namespace>
# Check for resource constraints or scheduling issues
```

**Services Not Accessible:**
```bash
kubectl get endpoints <service-name> -n <namespace>
# Verify service has healthy endpoints
```

**Application Not Loading:**
```bash
kubectl logs -f deployment/<deployment-name> -n <namespace>
# Check application logs for errors
```

**Ingress Not Working:**
```bash
kubectl describe ingress <ingress-name> -n <namespace>
# Verify ingress controller is running and configured
```

---

## 📚 **Additional Resources**

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [EKS User Guide](https://docs.aws.amazon.com/eks/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

**🎉 Congratulations!** You've successfully deployed and managed a complete microservices application on Kubernetes. This hands-on experience provides a solid foundation for working with Kubernetes in production environments.
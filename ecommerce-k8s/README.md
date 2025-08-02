# E-Commerce Kubernetes Learning Demo

A comprehensive e-commerce application designed to demonstrate Kubernetes concepts step-by-step for educational purposes.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Ingress Tier  │    │  Frontend Tier  │    │  Backend Tier   │    │ Database Tier   │
│                 │    │                 │    │                 │    │                 │
│ AWS Load        │    │ Frontend        │    │ User Service    │    │ MongoDB         │
│ Balancer        │───▶│ (nginx)         │───▶│ Product Service │───▶│ (Persistent)    │
│ Controller      │    │                 │    │ Order Service   │    │                 │
│                 │    │                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
ecommerce-ingress      ecommerce-frontend     ecommerce-backend      ecommerce-database
```

## Features Demonstrated

### Kubernetes Concepts
- **Namespaces**: Separate namespaces for each application tier
- **Deployments**: Scalable application deployments
- **ReplicaSets**: Automatic pod management
- **Services**: Internal service discovery and communication
- **ConfigMaps**: Configuration management
- **Persistent Volumes**: Database storage
- **Ingress**: External access and load balancing

### Application Features
- **User Management**: Registration and authentication
- **Product Catalog**: Product listing and search
- **Shopping Cart**: Add/remove items
- **Order Management**: Place and track orders
- **Microservices**: Separate services for different functionalities

## Quick Start

### Prerequisites
- EKS cluster running (use the cluster creation script)
- kubectl configured
- Helm installed

### Deploy the Application
```bash
cd scripts
chmod +x deploy-step-by-step.sh
./deploy-step-by-step.sh
```

### Access the Application
1. Get the Load Balancer URL:
   ```bash
   kubectl get ingress ecommerce-ingress -n ecommerce-frontend
   ```

2. Wait for the Load Balancer to be provisioned (2-3 minutes)

3. Access the application using the provided URL

### Cleanup
```bash
cd scripts
chmod +x cleanup.sh
./cleanup.sh
```

## Learning Path

The deployment script demonstrates concepts in this order:

1. **Namespace Creation** - Resource isolation
2. **Database Deployment** - Persistent storage, StatefulSets
3. **Backend Services** - Microservices, ConfigMaps, Service discovery
4. **Data Initialization** - Application bootstrapping
5. **Frontend Deployment** - Web tier, nginx configuration
6. **Ingress Setup** - External access, load balancing
7. **Verification** - Monitoring and troubleshooting

## Services

### User Service (Port 3001)
- `POST /register` - User registration
- `POST /login` - User authentication

### Product Service (Port 3002)
- `GET /products` - List products with search
- `GET /products/:id` - Get product details
- `POST /products` - Add new product
- `POST /init-products` - Initialize sample data

### Order Service (Port 3003)
- `GET /cart/:userId` - Get user's cart
- `POST /cart/:userId/add` - Add item to cart
- `DELETE /cart/:userId/remove/:productId` - Remove from cart
- `POST /orders` - Create order
- `GET /orders/:userId` - Get user's orders

## Monitoring Commands

```bash
# Check all pods
kubectl get pods --all-namespaces | grep ecommerce

# Check services
kubectl get services --all-namespaces | grep ecommerce

# Check ingress
kubectl get ingress -n ecommerce-frontend

# View logs
kubectl logs -f deployment/frontend -n ecommerce-frontend
kubectl logs -f deployment/user-service -n ecommerce-backend

# Scale deployments
kubectl scale deployment frontend --replicas=5 -n ecommerce-frontend
```

## Troubleshooting

### Common Issues
1. **Pods not starting**: Check resource limits and node capacity
2. **Service communication**: Verify service names and namespaces
3. **Database connection**: Ensure MongoDB is ready before backend services
4. **Ingress not accessible**: Wait for Load Balancer provisioning

### Debug Commands
```bash
# Describe resources
kubectl describe pod <pod-name> -n <namespace>
kubectl describe service <service-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Test service connectivity
kubectl exec -it <pod-name> -n <namespace> -- curl <service-url>
```

This demo provides hands-on experience with real-world Kubernetes patterns and best practices!
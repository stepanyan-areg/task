# Secure Deployment of MongoDB Outside of Kubernetes Worker Nodes

## Introduction
As part of the Kubernetes migration project, one of our clients will migrate all of its applications to Kubernetes. However, the database services such as MongoDB (self-managed on EC2 instances) will continue to run outside of the Kubernetes worker nodes, still within the same VPC. The client's requirement is to restrict access to the MongoDB database only to the services that need it.

## Passwordless Authentication with AWS IAM (For Atlas)
If MongoDB was hosted on MongoDB Atlas, we could set up passwordless authentication with AWS IAM to ensure secure access without managing multiple secrets. Here’s a brief overview of the process:

### Create IAM Roles:

- Create IAM roles in AWS that allow access to MongoDB Atlas without requiring username or password fields.
- These roles present a secret key for authentication, which does not get sent over the wire to Atlas and is not persisted by the driver.

### Assign these roles to the AWS services that need to access MongoDB (e.g., AWS Lambda, ECS, EC2, EKS).
 For AWS EKS, you must first assign the IAM role to your pod to set up the following environment variables in that pod:

- `AWS_WEB_IDENTITY_TOKEN_FILE` - contains the path to the web identity token file.

- `AWS_ROLE_ARN` - contains the IAM role that you want to use to connect to your cluster.

### Assign IAM Role to Pod:

- First, create a Kubernetes service account and annotate it with the IAM role:

### Define the pod specification to use the service account:

[`Detailed Steps`](https://www.mongodb.com/docs/atlas/security/passwordless-authentication/#std-label-passwordless-auth-aws-no-saml) 

## Secure Access for Self-Hosted MongoDB

### Using Security Groups for Pods to Secure Access to MongoDB

By using Security Groups for Pods in Amazon EKS, you can define rules that control inbound and outbound traffic to and from specific Kubernetes pods, ensuring that only authorized pods can access the MongoDB instance on the EC2 instance.

### Steps to Implement Security Groups for Pods

1. Create a Security Group for MongoDB
2. In the AWS Management Console, go to the EC2 Dashboard.
3. Under "Network & Security," click on "Security Groups."
4. Click "Create security group."
5. Name it mongodb-sg and provide a description.
6. Add an inbound rule to allow traffic on port 27017 from the security group that will be associated with your EKS pods.

### Attach the Security Group to MongoDB EC2 Instance:

1. Find your MongoDB EC2 instance.
2. Modify the instance's security groups to include the newly created mongodb-sg.

### Create a Security Group for EKS Pods

1. In the AWS Management Console, go to the EC2 Dashboard.
2. Under "Network & Security," click on "Security Groups."
3. Click "Create security group."
4. Name it eks-pods-sg and provide a description.
5. You do not need to add any inbound rules here; just note the security group ID.

### Enable Security Groups for Pods in EKS

Check VPC CNI Plugin Version:
```shell
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3
```
If your version is earlier than 1.7.7, update the plugin to version 1.7.7 or later.
### Attach Required IAM Policy:

Attach the `AmazonEKSVPCResourceController` policy to your cluster's IAM role:
```shell
cluster_role=$(aws eks describe-cluster --name my-cluster --query cluster.roleArn --output text | cut -d / -f 2)
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEKSVPCResourceController --role-name $cluster_role
```

### Enable Pod ENI:

Enable the VPC CNI plugin to manage network interfaces for pods:
```shell
kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
```

### Configure Pod Security Group Enforcing Mode:

Set the enforcing mode to standard:
```shell
kubectl set env daemonset aws-node -n kube-system POD_SECURITY_GROUP_ENFORCING_MODE=standard
```

### Associate the Security Group with EKS Pods

- Create a SecurityGroupPolicy:

Define a `SecurityGroupPolicy` that associates your pods with the security group:
```shell
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
metadata:
  name: mongodb-sg-policy
  namespace: your-namespace
spec:
  podSelector:
    matchLabels:
      access: backend
  securityGroups:
    groupIds:
      - sg-xxxxxxxx  # Replace with your eks-pods-sg ID
```

Apply the policy:

### Edit Your Deployments to Add Labels:

Edit your deployment to include the labels that match the SecurityGroupPolicy:

### Important: Ensure that the labels in the podSelector of the SecurityGroupPolicy match the labels in your pod deployment. This ensures that the correct pods are associated with the security group.:


## Via secrets and network policies
For the self-hosted MongoDB on an EC2 instance, we can also use Kubernetes Secrets for credentials and Network Policies to restrict access.

1. Create Kubernetes Secrets:

Store MongoDB credentials in Kubernetes secrets:

2. Reference Secrets in Pods:

Reference these secrets in the pods that require access to MongoDB:

## Implementing Network Policies

1. Define Network Policies:

- Create network policies that allow egress traffic only to the MongoDB instance’s IP address.

2. Label Pods:

- Label the pods that need access to MongoDB with a specific label (e.g., backend).

3. Apply Network Policies:

- Apply the network policies to restrict access so that only labeled pods can communicate with MongoDB:
```shell
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-mongodb-access
  namespace: your-namespace
spec:
  podSelector:
    matchLabels:
      access: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: "your.mongodb.ip/32"
    ports:
    - protocol: TCP
      port: 27017
```

## Conclusion
By associating security groups with your EKS pods, you can use AWS security group rules to control access to your MongoDB instance running on an EC2 instance. This method leverages existing AWS security group functionalities, allowing for a more integrated and secure access control mechanism. Ensure that the labels in your deployments and security group policies match to apply the correct security rules to your pods. Additionally, by using Kubernetes Secrets for managing credentials and implementing Network Policies to control access, we can further ensure that only the necessary services have access to the MongoDB instance. If MongoDB was hosted on Atlas, utilizing AWS IAM for passwordless authentication would further enhance security by reducing the need to manage multiple secrets.

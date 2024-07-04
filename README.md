# Access to AWS EKS with IAM Users

These instructions will guide you on how to access AWS Elastic Kubernetes Service (EKS) with IAM users.

## Step 1: Request EKS Admin Access

Contact the EKS admin and request to be added to the cluster with a suitable role.

## Step 2: Install and Configure AWS CLI

- Install the AWS CLI by following the [installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) for your operating system.
- Configure your IAM access and secret key by running the following command and following the prompts:
```
aws configure [--profile ...]
```
- Test the configuration by running the command:
```
aws sts get-caller-identity [--profile ...]
```
Note: Replace `[--profile ...]` with the profile name if you are using named profiles.

## Step 3: Install and Configure kubectl

- Install `kubectl` by following the [installation instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for your operating system.
- Run the following command to update the kubeconfig file:
```
aws eks update-kubeconfig --name staging --region us-east-2 [--profile ...]
```
Note: Replace `staging` with the actual name of your EKS cluster, `us-east-2` with the appropriate AWS region, and `[--profile ...]` with the profile name if applicable.

## Step 4: Verify the Configuration

Run the following command to verify the configuration and check if the nodes are available in your cluster:
```
kubectl get node
```
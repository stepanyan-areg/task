## Running a Pod/Deployment on x86 or Graviton Instance Inside the Cluster

### Building Docker Images for x86 and Graviton

Because the architectures are different, the Docker images need to be built separately for x86 (amd64) and ARM64 (Graviton) instances. Here’s how you can do it:

- x86_64 Docker Image

```shell
docker build -t <your-repo>/your-app:latest .
````

```shell
docker push <your-repo>/your-app:latest
````

- ARM64 Docker Image

```shell
docker buildx create --use
````
```shell
docker buildx build --platform linux/arm64 -t <your-repo>/your-app:latest-arm64 --push .
````

### Deploying Docker Images for x86 and Graviton

Deployment for x86_64
Create a file named deployment-x86.yaml with the following content:

```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-x86
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-x86
  template:
    metadata:
      labels:
        app: app-x86
    spec:
      containers:
      - name: app
        image: <your-repo>/your-app:latest
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/arch: amd64
```

Deployment for ARM64
Create a file named deployment-arm64.yaml with the following content:

```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-arm64
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-arm64
  template:
    metadata:
      labels:
        app: app-arm64
    spec:
      containers:
      - name: app
        image: <your-repo>/your-app:latest-arm64
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/arch: arm64
```

Applying the Deployments

To deploy your applications on the respective architectures, run the following commands:

```shell
kubectl apply -f deployment-x86.yaml
```
```shell
kubectl apply -f deployment-arm64.yaml
```

## Testing Karpenter with nginx images

If you want to test if Karpenter works as expected, you can use the below deployment manifests. These manifests will create pods that request specific node architectures (x86 and ARM64). Karpenter should provision the appropriate nodes based on these requests.

### Deployment for x86_64

Create a file named `deployment-x86.yaml` with the following content:

```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-x86
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-x86
  template:
    metadata:
      labels:
        app: nginx-x86
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/arch: amd64
```

### Deployment for ARM64

Create a file named deployment-arm64.yaml with the following content:

```shell
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-arm64
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-arm64
  template:
    metadata:
      labels:
        app: nginx-arm64
    spec:
      containers:
      - name: nginx
        image: arm64v8/nginx:latest
        ports:
        - containerPort: 80
      nodeSelector:
        kubernetes.io/arch: arm64
```

### Applying the Deployments
To deploy NGINX on the respective architectures, run the following commands:

```shell
kubectl apply -f deployment-x86.yaml
kubectl apply -f deployment-arm64.yaml
```

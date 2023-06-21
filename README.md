# MY-NODE-APP

This is a Node.js application packaged with Docker and Helm, ready for deployment to a Kubernetes cluster.

## Application

The application is a simple Express.js application that responds to HTTP requests. It includes the Prometheus client library to expose the metrics at `/metrics` endpoint. This will increment a counter each time a request is received on the main endpoint ('/').


## Docker

### Build

Use Docker to build an image of the application:

```shell
docker build -t <your-image-name> .
```

Run
Run the Docker image:


```shell
docker run -p 3000:3000 <your-image-name>
```

You can then access the application on [http://localhost:3000](http://localhost:3000) in your web browser.



## Test Docker Image

We use Google's Container Structure Test tool for basic validation and tests against our created Docker image. The structure-test.yaml file includes several tests like file existence tests and command tests.

* File existence test checks for the existence of our main app.js file in the correct path inside the image.
* Command tests check for the correct version of Node.js and npm.
* It also checks whether 'express' dependency exists in package.json.
* Metadata tests validate the metadata of the Docker image like exposed ports, cmd etc.

You can test it with the structure tests defined in structure-test.yaml using the Container Structure Test tool. Run the following command:

```shell
container-structure-test test --image <your-image-name> --config structure-test.yaml
```

After running the command, you should see an output similar to the following:

Text
```shell
============================================
====== Test file: structure-test.yaml ======
============================================
=== RUN: Command Test: Node version
--- PASS
duration: 635.001958ms
stdout: v14.21.3

=== RUN: Command Test: npm version
--- PASS
duration: 1.659739625s
stdout: 6.14.18

=== RUN: Command Test: Check express is in package.json
--- PASS
duration: 384.474042ms
stdout:     "express": "^4.18.2",

=== RUN: Command Test: Check express is in package.json
--- PASS
duration: 326.817583ms
stdout:     "express": "^4.18.2",

=== RUN: File Existence Test: Check app.js exists
--- PASS
duration: 0s
=== RUN: Metadata Test
--- PASS
duration: 0s

=============================================
================== RESULTS ==================
=============================================
Passes:      6
Failures:    0
Duration:    3.006033208s
Total tests: 6
```

Each line represents a separate test from the structure-test.yaml file, and "PASS" indicates that the test was successful. If a test fails, you would see a "FAIL" message, and the test tool would provide more information about the failure


## Deploying the Application

### Prerequisites

* A running Kubernetes cluster
* kubectl and helm installed and configured to interact with your cluster

### Enforce Security Policies with Gatekeeper

Add the Gatekeeper chart repository to your helm client:

```shell
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
```

Install Gatekeeper to your cluster in a chosen namespace:

```shell
helm install gatekeeper/gatekeeper --generate-name -n <namespace>
```
### Applying Constraints

Next, you will apply two custom constraint templates(provided in the source code): "NoUseOfDefaultServiceAccount" and "NoRootContainers".

The NoUseOfDefaultServiceAccount constraint prevents pods from using the default service account:

```shell
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: nouseofdefaultserviceaccount
spec:
  crd:
    spec:
      names:
        kind: NoUseOfDefaultServiceAccount
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8siam
        violation[{"msg": msg}] {
          input.review.kind.kind == "Pod"
          input.review.object.spec.serviceAccountName == "default"
          msg := "usage of the default service account is not allowed"
        }
        violation[{"msg": msg}] {
          input.review.kind.kind == "Pod"
          not input.review.object.spec.serviceAccountName
          msg := "usage of the default service account is not allowed"
        }
```

The NoRootContainers constraint prevents pods from running containers as root:

```shell
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: norootcontainers
spec:
  crd:
    spec:
      names:
        kind: NoRootContainers
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package norootcontainers
        violation[{"msg": msg}] {
          input.review.kind.kind == "Pod"
          container := input.review.object.spec.containers[_]
          container.securityContext.runAsUser == 0
          msg := sprintf("Container %v is running as root", [container.name])
        }
```
Apply the constraint templates with kubectl apply -f "filename"

### Enforcing Constraints

Finally, create constraint objects to enforce the constraint templates you've created:

To enforce NoUseOfDefaultServiceAccount:

```shell
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: NoUseOfDefaultServiceAccount
metadata:
  name: deny-default-service-account
spec:
  enforcementAction: deny
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]

```

To enforce NoRootContainers:

```shell
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: NoRootContainers
metadata:
  name: pods-must-not-have-root-containers
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```
Again, apply the constraint enforcement with kubectl apply -f "filename"

With these policies in place, Kubernetes will reject any pod that tries to use the default service account or run a container as root. Adjust your pod specifications accordingly to comply with these security best practices.


### Push to Repository

Before deploying the application to a Kubernetes cluster, the Docker image needs to be accessible in a Docker repository. This can be a public repository, like DockerHub, or a private repository like Amazon ECR.

Assuming you have already set up an ECR repository, you can tag and push the Docker image with the following commands:

```shell
docker tag <your-image-name> <your-ecr-repo-url>:<tag>
docker push <your-ecr-repo-url>:<tag>
```

Replace <your-ecr-repo-url> with the URL of your ECR repository and <tag> with a suitable tag for your image.

### Install

Install the Helm chart:

Set your current directory to the helm/ directory:

```shell
cd helm/
```

```shell
helm install <release-name> . -n <namespace>
```
Replace <release-name> with a name for your Helm release.
Replace <namespace> with a name for your namespace.

Helm Test
The Helm chart includes a simple test to verify the deployed application. The test simply makes a request to the main endpoint of the application and checks the response.

To run the test:

```shell
helm test <release-name> -n <namespace>
```
You should see a "PASSED" message if the test is successful. If the test fails, you would see a "FAILED" message and some additional information about the error.

### Database Migration Job

The database migration job is defined in the migration-job.yaml file. This job uses a specific Docker image that includes a migration script. When the job runs, it starts a Pod with this image and runs the migration script.

The job is configured to run after the Helm chart is installed, thanks to the post-install Helm hook. If the job completes successfully, Helm will delete it.

```shell
apiVersion: batch/v1
kind: Job
metadata:
  name: myapp-migration-job
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: myapp-migration-job
    spec:
      containers:
      - name: myapp-migration
        image: "{{ .Values.ContainerImageBase }}/{{ .Values.RepositoryName }}:{{ .Values.ContainerTag }}"
        command: ["/path/to/your/migration/script.sh"]
      restartPolicy: Never
```









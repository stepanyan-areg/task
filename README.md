markdown
Copy code
# MY-NODE-APP

This is a Node.js application packaged with Docker and Helm, ready for deployment to a Kubernetes cluster.

## Application

The application is a simple Express.js application that responds to HTTP requests. It includes Prometheus client library to expose the metrics at `/metrics` endpoint. This will increment a counter each time a request is received on the main endpoint ('/').

## Docker Build and Run

Use Docker to build an image of the application:

```bash
docker build -t <your-image-name> .
Run the Docker image:

bash
Copy code
docker run -p 3000:3000 <your-image-name>
You can then access the application on localhost:3000 in your web browser.

Test Docker Image
Test it with the structure tests defined in structure-test.yaml using the Container Structure Test tool. Run the following command:

bash
Copy code
container-structure-test test --image <your-image-name> --config structure-test.yaml
Deploying the Application
Set your current directory to the helm/ directory:

bash
Copy code
cd helm/
Install the Helm chart:

bash
Copy code
helm install <release-name> .
Replace <release-name> with a name for your Helm release.

Run Helm tests:

bash
Copy code
helm test <release-name>

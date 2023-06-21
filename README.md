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

Set your current directory to the helm/ directory:

```shell
cd helm/
```

Install
Install the Helm chart:

```shell
helm install <release-name> .
```
Replace <release-name> with a name for your Helm release.

Helm Test
The Helm chart includes a simple test to verify the deployed application. The test simply makes a request to the main endpoint of the application and checks the response.

To run the test:

```shell
helm test <release-name>
```
You should see a "PASSED" message if the test is successful. If the test fails, you would see a "FAILED" message and some additional information about the error.



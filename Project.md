Camunda’s Infrastructure as Code Coding Challenge

🎬 Introduction 
In this coding challenge, you will need to implement Terraform modules that will create a test infrastructure cluster for a simple S3 App and deploy it there.


You don’t start from scratch, as we provide you with a boilerplate code to begin with.


The implementation you need to work on consists of two layers (two Terraform workspaces):

Infrastructure: A local k8s cluster created with kind, a mock of an S3 bucket (with the help of Localstack, and a configuration file placed in the bucket
Deployment: An ingress-nginx controller that is configured and deployed in the kind cluster, and the simple S3 App that is deployed in the cluster and available locally via an Ingress (the S3 App already exists; you don’t need to develop it)

This challenge should typically not take you more than 180 minutes to complete. It’s totally fine if you need more time; everyone works at their own pace.


We highly recommend you read the whole document before starting the task.


Good luck, and we hope you enjoy this challenge 💪

🛂 Prerequisites
Please take your time to install and configure the required tools before starting the challenge.

🔧 Tools
We’ve tried to make the flow as easy for you as possible by letting you focus on completing the task rather than making the auxiliary aspects work (which we did for you, like configuring a linter).


We’ve tested the challenge flow on Linux and macOS. We cannot guarantee that this setup works on other platforms, especially non-Unix (e.g., Windows).


You will need to have the following tools installed on your machine:

Name

Minimal required version

Docker

27.0.0

kubectl

1.33.2

kind

0.29.0

Terraform

1.12.2

GNU Make

3.81

bash

4.2

curl

8.9.0

jq

1.7.1

Coreutils binaries (on Linux)


There’s a good chance the setup would also work with older versions of the mentioned tools; however, we cannot guarantee this.

👩‍💻 Coding Challenge
📂 Download the Challenge Project
Download the ZIP archive here

It contains the required boilerplate to start implementing the solution.


Check out the README.md and run make help for a quick start.

🤔 The Problem and the Scope
In the downloaded archive, you will find the following file structure:

01-cluster-create
This Terraform workspace is using the module in modules/infrastructure to:
Create a kind[1] cluster
Create a S3 bucket (in Localstack[2], running locally)
Place an object (file) in the bucket
The main.tf file is calling a local module (modules/infrastructure), but the module is lacking implementation
02-app-deploy
This Terraform workspace is using the module in modules/deploy to:
Create a namespace for nginx-ingress controller and deploy it using the Helm provider with the given settings
Create a namespace for the S3 app and deploy it using Kubernetes provider (so it’s available via an Ingress locally
The main.tf file is calling a local module (modules/deploy), but the module is lacking implementation
modules
deploy ← you will need to implement the code of this module and add a readme to it
infrastructure ← you will need to implement the code of this module and add a readme to it

See the files in the modules directory for the file structure you need to follow and the hints.


You can think about it as a contract implementation: you know the interface of the module (based on how the 01-cluster-create and 02-app-deploy workspaces use them; you know the input variables and output parameters of it), and what is missing is the logic to make them work as per the contract.


Components composition:




Terraform workspaces structure:

14

☁️ S3 App
This app is developed by Camunda and packaged in a Docker image. It accepts multiple environment variables for the configuration (see env_vars in 02-app-deploy/main.tf) and acts as a simple HTTP server running on a port specified by env var PORT. When getting a request, it tries to connect to a Localstack S3 service to:

Check that the bucket (specified by the env var S3_BUCKET) exists
Check that the file with a given name (specified by the env var S3_OBJECT) exists in the bucket
Check that the file's contents have the same checksum as expected (specified by the env var S3_CONTENT_CHECKSUM).

👉 If you did everything correctly, then after applying the two workspaces (01-cluster-create and 02-app-deploy), the app will be available on http://localhost:8086/s3-app with the following example output:


{

  "status": "OK",

  "s3_endpoint": "http://host.docker.internal:4566",

  "bucket_found_status": true,

  "file_found_status": true,

  "file_content_correct_status": true,

  "file_path": "s3://test-bucket/test-file",

  "file_content_checksum": "df5210863d3dea0dcac4a3232bd833b3",

  "file_content_checksum_control": "df5210863d3dea0dcac4a3232bd833b3"

}


(s3_endpoint will vary based on whether you use Linux or MacOS and represents the host address from the perspective of a pod running in the k8s kind cluster).

☁️ LocalStack
For this challenge, you need to have Localstack running. For development purposes we extracted the commands:


make localstack-start


The Localstack’s S3 service will be used in the challenge. We will use a free Docker version of Localstack; no configuration or credentials are needed.


If you want to stop Localstack, run:


make localstack-stop


Stopping the Localstack container also erases all its temporary data (e.g., the created S3 buckets and the files in them will be lost).


During make full-test the LocalStack container will automatically be started and stopped.

💪 What You Need to Do
✅ Checklist
Before you submit your challenge, please make sure the following points are covered:


Implement the Terraform code for:
Modules:
modules/infrastructure
modules/deploy
Write a readme for both Terraform modules (README.md) as you would expect your teammates to do.
Address and fix all TODOs
make full-test is passing
⚠️ This is the exact command we will use to check that your solution works before doing any code review. We discard submissions that do not pass this check.
🔁 Feedback for Us (Optional)
In case something is not working as expected (e.g., you’ve found an error in one of our testing scripts or k8s manifests), please let us know about it, and feel free to fix it in your submission and mention it in Feedback.md

📦 Deliverables
You’ll need to send us the whole camunda-infrastructure-experience-interview folder in a ZIP file through the link we shared with you via email.


IMPORTANT: Please ensure to avoid including local files such as .terraform cache or .tfstate* files. Including these will prevent your solution from working when tested on another machine/architecture, leading to a rejection.

🔬 How Do We Evaluate Your Submission?
👀 What Are We Looking At
Most importantly, we want to see a working solution. It’s much better to have a functional (yet not perfect) code than the one that does not work but looks great.


Your code must work in a way that the workspaces 01-cluster-create and 02-app-deploy can be terraform apply-ed one after another, and the S3 app is deployed there and available from localhost via localhost:8086/s3-app. The app should be able to read the given file from a Localstack S3 bucket.


Check that the essential tests are passing by running a make full-test (this is the same way we will check if your submission works).

✅ Checklist
Here’s how Camunda engineers will evaluate your submission:

Running the make full-test command
The testing framework is run, demonstrating whether the basic tests are passing.
⚠️ If the basic tests are not passing (e.g., the S3 app cannot get a file from the Localstack bucket), we consider your solution not functional and stop the evaluation (we submit an empty scorecard)
Filling the scorecard by giving a score to different aspects of the solution. In the scorecard, we answer the following points:
Meta
Tests → is this a functioning solution (make full-test passing)?
Can the kind cluster be successfully created?
Can the Localstack S3 bucket and the file in it be created?
Can the Nginx ingress controller be deployed into the kind cluster with the given configuration?
Can the S3 app be deployed into the kind cluster with the given configuration?
Is the app accessible via an Ingress, and can it get the file from the Localstack S3 bucket?
Terraform Module: Infrastructure
Module Configurability → are the Terraform resource attribute values correctly taken from the module variables (they are not all hard-coded)
Module Outputs → are outputs correctly defined and set based on the module usage?
Module Variables → are variables correctly defined based on the module usage? Are variables defined with the correct variable types?
Kind Cluster → is it created and configured in Terraform with the requested settings?
S3 → is the bucket and an object in it created as requested?
Documentation → is it well explained how to use and configure the app in README.md? Are the docs not too sparse?
Terraform Module: Deploy
Module Configurability → are the Terraform resource attribute values correctly taken from the module variables (they are not all hard-coded)?
Module Outputs → are the outputs correctly defined and set based on the module usage?
Module Variables → are the variables correctly defined based on the module usage? are the variables defined with the correct variable types?
Nginx Ingress Controller → is the Helm values template file correctly rendered with parameters for the Nginx Helm chart configuration?
S3 App → are all the Kubernetes primitives for the app to run correctly chosen and defined (e.g., Ingress), and their attribute values are correctly taken from the module variables (they are not all hard-coded)
Documentation → is it well explained how to use and configure the module in README.md? Are the docs not too sparse?
🎯 What to Focus On
If you’re wondering whether you should focus on something, please refer to the scorecard points in ✅ Checklist. You don’t need to care about something if it's not mentioned there.


We recommend staying quite far from the extremes on the sloppy-perfect spectrum.

🚀 Results
If your solution gets a good score, you will be invited to the next stage of the interview.


We have an internal SLA of 2 working days to evaluate your submission.

❓ Q&A
Q: What if it takes me longer than 180 minutes to complete the task?
A: That’s totally fine. Everyone works at their own pace; this is just an average ballpark figure.


We would appreciate your sharing how long it took you to complete the task with us. That helps us to improve the challenge continuously (e.g., when we notice that the candidates lose a lot of time in the same place, we optimize it for a better experience)

🐞 Troubleshooting
AWS provider warnings
When you run Terraform, the AWS provider will show you warnings when working with Localstack:




│ Warning: AWS account ID not found for provider

│

│   with provider["registry.terraform.io/hashicorp/aws"],

│   on main.tf line 18, in provider "aws":

│   18: provider "aws" {

│

│ See https://www.terraform.io/docs/providers/aws/index.html#skip_requesting_account_id for implications.



This is totally expected; nothing needs to be done.

The S3 app cannot connect to Localstack from the kind cluster
Localstack is running on your machine, and if the S3 app needs to connect to it but it cannot use localhost (the kind cluster pods are running in a different network, so localhost for the app in the kind cluster != localhost for your machine).


Therefore, the S3 app has the following logic:

Try to connect to host.docker.internal (hostname for pods when running kind in Docker on MacOS), and fallback to 172.17.0.1 otherwise (on Linux)

If, for any reason, your host instance is not available for the pods in the kind cluster under either of the two addresses above, you can pass the S3_ENDPOINT_HOSTNAME env var to the S3 app. This will let you override the hostname of the Localstack S3 service to which the S3 app will connect (it can be any FQDN or an IP address)

The kind Cluster test-cluster already exists
This can happen if kind couldn’t properly clean up the environment or a kind cluster creation failed during a terraform run.

In this case, you can remove the existing cluster manually via kind by running:


kind delete clusters test-cluster

Helm repo update required
By default, the Helm Terraform provider will use the locally existing helm installation, and if none is installed, it uses a fallback. A Helm repo update may be required to be run if you have outdated charts present:


helm repo update

Fish Shell
When using the Fish shell instead of Bash, the destroy operation part of the make full-test could hang indefinitely: typing y unlocks the situation.


Finished workspace 02-app-deploy could not be applied
Depending on your environment, it can happen that a local .kube/config in your home directory blocks the execution. If this happens to you, you can temporarily rename the file for the 01-cluster-create to recreate it.



[1] Kind is a tool that allows one to run k8s clusters locally, as a docker container

[2] Localstack is a tool that allows one to emulate working with AWS services locally
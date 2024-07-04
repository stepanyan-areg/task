# build-terragrunt-environments

## How do you deploy the infrastructure in this repo?

### Pre-requisites

1. Fill in your AWS account variables in `terragrunt-environments/opsfleet-task/account.hcl`.
1. Fill in your AWS region in `terragrunt-environments/opsfleet-task/us-east-2/infra/region.hcl`.

### Deploying a single module

1. `cd` into the module's folder (e.g. `cd terragrunt-environments/opsfleet-task/us-east-2/infra/vpc`).
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.

Deploy/destroy one resource of environment:

`cd opsfleet-task/us-east-2/infra/<resource>`
```shell
terragrunt plan
```
```shell
terragrunt apply
```
```shell
terragrunt plan -destroy
```
```shell
terragrunt destroy
```

### Deploying all modules in an environment

1. `cd` into the environment folder (e.g. `cd terragrunt-environments/opsfleet-task/us-east-2/infra`).
1. Run `terragrunt plan-all` to see all the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply-all`.

Deploy/destroy all resources of environment:
```shell
cd terragrunt-environments/opsfleet-task/us-east-2/infra
```
```shell
terragrunt plan-all
```
```shell
terragrunt apply-all
```
```shell
terragrunt plan-all -destroy
```
```shell
terragrunt destroy-all
```
## Creating and using root (project) level variables

In the situation where you have multiple AWS accounts or regions, you often have to pass common variables down to each
of your modules. Rather than copy/pasting the same variables into each `terragrunt.hcl` file, in every region, and in every environment, you can inherit them from the `inputs` defined in the root `terragrunt.hcl` file.
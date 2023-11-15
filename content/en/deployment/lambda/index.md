---
title: AWS Lambda Deployment Overview
linktitle: AWS Lambda Overview
weight: 1
description: >
 Learn what an Armory CD-as-a-Service deployment to AWS Lambda is, how CD-as-a-Service connects to your AWS Account, and how deployment works.
---


## What a deployment is

A _deployment_ encompasses the manifests, artifacts, configuration, and actions that deliver your code to remote environments. You can configure a deployment to deliver your [AWS Lambda](https://docs.aws.amazon.com/lambda) function to a single environment or multiple environments, either in sequence or in parallel depending on your [deployment configuration]({{<ref "deployment/create-deploy-config" >}}).

You define your CD-as-a-Service deployment configuration in a YAML file, which you store within your source control, enabling code-like management. You trigger deployments using the Armory CLI, either from your CI system or your workstation. Although CD-as-a-Service requires a separate deployment configuration file for each app, you can deploy multiple Kubernetes Deployment objects together as part of a single app. 

## How deployment works

{{< figure src="lambda-deploy.webp" width=80%" height="80%" >}}

CD-as-a-Service starts a deployment with a target environment, which is a combination of AWS account and region. such as development, that does not depend on another environment. Then deployment progresses through the steps, conditions, and environments defined in your deployment process. 

CD-as-a-Service automatically rolls back when:

  * There is an error deploying your Lambda function
  * Deployment fails to finish within 30 minutes
  * A webhook fails
  * You configured your retrospective analysis step to automatically rollback
  * A user fails to issue a configured manual approval within a specified time frame
  * A deployment target constraint is not met

## How CD-as-a-Service integrates with AWS

{{< include "lambda/iam-role.md" >}}

You need to store your function zip files in an S3 bucket, and the S3 bucket should be in the same region you deploy to (this is an AWS limitation). For example, if you plan to deploy to three regions, you need three S3 buckets, one for each region. CD-as-a-Service deploys your Lambda function's archive from your S3 bucket.

| AWS Accounts | ArmoryRole | Regions | S3 Buckets |
|--------------|-----------|---------|------------|
| 1            | 1         | 4       | 4          |
| 4            | 4         | 1       | 1          |
| 4            | 4         | 4       | 4          |
| 2            | 2         | 6       | 6          |


<!--
@TODO NEED MORE INFO ON THIS APPROACH CUZ IT DIDN'T WORK FOR ME
Alternately, you can create a bucket policy that makes the bucket accessible to all AWS accounts in your AWS organization.

<details><summary>Click for example</summary>

This example makes a bucket read-only and available to an entire AWS organization.

Replace `<bucket>` with your bucket's name and `<orgid>` with your AWS organization's ID.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:List*",
                "s3:Get*"
            ],
            "Resource": [
                "arn:aws:s3:::<bucket>",
                "arn:aws:s3:::<bucket>/*"
            ],
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": "<orgid>"
                }
            }
        }
    ]
}
```

See the [Identity and Access Management](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-access-control.html) of the AWs S3 docs for more information.

</details>
-->

For each Lambda function you want to deploy, CD-as-a-Service needs the following:

1. **ArmoryRole** ARN
1. Region
1. S3 path to the function zip file
1. The ARN of your [Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
1. Your function's [runtime](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) and handler method

This basic example deploys one function to one region in one account:

```yaml
version: v1
kind: lambda
application: potatoless-facts
description: awsLambda
targets:
  us-east-1:
    account: armory-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-1
    strategy: allAtOnce
strategies:
  allAtOnce:
    canary:
      steps:
        - setWeight:
            weight: 100
artifacts:
  - functionName: potatolessFacts
    path: s3://armory-docs-dev-us-east-1/potatolessfacts-justsweetpotatoes.zip
    type: zipFile
providerOptions:
  lambda:
    - name: potatolessFacts
      target: us-east-1
      runAsIamRole: arn:aws:iam::111111111111:role/lamdaExecutionRole
      handler: index.handler
      runtime: nodejs18.x
```

## How to trigger a deployment

* [Use the CLI]({{< ref "cli" >}}) in your terminal or with any CI system by installing the CLI natively or running it in Docker.
* [Use the GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}) in your GitHub workflow.


## Define your deployment

CD-as-a-Service enables you to declare your deployment configuration outcome in a YAML file. 

For an AWS Lambda deployment, you only need to provide the following pieces of information:

* The target you want to deploy to
* The Lambda function you want to deploy
* Provider options for that Lambda function
* The canary strategy you want to use for the deployment

## Elements of a deployment

### Targets

Within a deployment, you define _targets_ that are equivalent to the environments you are deploying to - a unique combination of AWS account (ArmoryRole ARN) and region. 

The following example has multiple region-based targets in a single AWS account:

```yaml
targets:
  Prod-East-1:
    account: armory-prod
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-1
    strategy: allAtOnce
  Prod-West-2:
    account: armory-prod
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-west-2
    strategy: allAtOnce
```

This example has targets that are separate AWS Accounts:

```yaml
targets:
  Lab:
    account: armory-lab
    deployAsIamRole: "arn:aws:iam::111111111111:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
  Staging:
    account: armory-core
    deployAsIamRole: "arn:aws:iam::222222222222:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
  Audit:
    account: armory-audit
    deployAsIamRole: "arn:aws:iam::333333333333:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
  ITSec:
    account: armory-itsec
    deployAsIamRole: "arn:aws:iam::444444444444:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
```

#### Target constraints

You can also configure your deployment targets to use constraints that prevent a deployment from beginning or completing until certain conditions are met. For example, you can configure your deployment to wait for your code to be deployed to your staging environment before promoting that code to production.

You can set `beforeDeployment` or `afterDeployment` constraints depending on your use case. 

CD-as-a-Service offers you multiple constraint options including: 

*  `dependsOn`  
   Use `dependsOn` to specify a target deployment that must successfully complete prior to starting this target's deployment.
*  `pause`  
   Use `pause` to pause a deployment for a set period of time or until an authorized user issues an approval.

This example has multiple targets and illustrates `dependsOn`, `beforeDeployment`, and `afterDeployment` constraints.

```yaml
targets:
  Lab:
    account: armory-lab
    deployAsIamRole: "arn:aws:iam::111111111111:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
  Staging:
    account: armory-core
    deployAsIamRole: "arn:aws:iam::222222222222:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn: 
        - Lab
      afterDeployment:
        - runWebhook:
            name: Integration-Tests
  Audit:
    account: armory-audit
    deployAsIamRole: "arn:aws:iam::333333333333:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn:
        - Lab
      afterDeployment:
        - runWebhook:
            name: Audit-Analysis
  ITSec:
    account: armory-itsec
    deployAsIamRole: "arn:aws:iam::444444444444:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn:
        - Lab
      afterDeployment:
        - runWebhook:
            name: Security-Scans            
  Prod-West-2:
    account: armory-prod
    deployAsIamRole: "arn:aws:iam::555555555555:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn:
        - Staging
        - Audit
        - ITSec
      beforeDeployment:
        - runWebhook:
            name: Send-Slack-Deployment-Approval-Required
        - pause:
            untilApproved: true
```

### Artifacts

An _artifact_ is your Lambda function name and the S3 path to the function's archive. 

```yaml
artifacts:
  - functionName: hello-world-python
    path: s3://armory-demos-us-west-2/hello-world-python.zip
    type: zipFile
```

### Provider options

This section is where you provide additional information about your function. Each target has an entry. 

```yaml
providerOptions:
  lambda:
    - target: Lab
      name: hello-world-python
      runAsIamRole:  arn:aws:iam::111111111111:role/LambdaExecutionRole
      handler: lambda_function.lambda_handler
      runtime: python3.10
    - target: Staging
      name: hello-world-python
      runAsIamRole:  arn:aws:iam::222222222222:role/LambdaExecutionRole
      handler: lambda_function.lambda_handler
      runtime: python3.10
    - target: Audit
      name: hello-world-python
      runAsIamRole:  arn:aws:iam::333333333333:role/LambdaExecutionRole
      handler: lambda_function.lambda_handler
      runtime: python3.10
    - target: ITSec
      name: hello-world-python
      runAsIamRole:  arn:aws:iam::444444444444:role/LambdaExecutionRole
      handler: lambda_function.lambda_handler
      runtime: python3.10
    - target: Prod-West-2
      name: hello-world-python
      runAsIamRole:  arn:aws:iam::555555555555:role/LambdaExecutionRole
      handler: lambda_function.lambda_handler
      runtime: python3.10
```

### Strategies

A deployment strategy is the method by which CD-as-a-Service deploys your changes to a target. Strategies can use different techniques to allow for rapid rollback should a problem be discovered, minimizing the impact of potential issues to a small subset of users. You could also use a strategy optimized for speed.

For Lambda, CD-as-a-Service supports a canary deployment strategy, which involves releasing a new software version to a small subset of users or systems while leaving the majority on the current version. This strategy allows for real-world testing and monitoring of the new version's performance and stability. 
If the canary users experience positive results, the new version can be gradually rolled out to a wider audience.

```yaml
strategies:
  allAtOnce:
    canary:
      steps:
        - setWeight:
            weight: 100
```

## {{% heading "nextSteps" %}}

* Work through the [AWS Lambda Quickstart]({{< ref "get-started/lambda" >}}) to deploy a sample function to your AWS Account.
* Learn how you can [monitor your deployment]({{< ref "deployment/monitor-deployment" >}}) using the UI or the CLI.

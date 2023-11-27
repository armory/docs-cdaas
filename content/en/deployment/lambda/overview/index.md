---
title: AWS Lambda Deployment Overview
linktitle: Overview
weight: 1
description: >
 Learn what an Armory CD-as-a-Service deployment to AWS Lambda is, how CD-as-a-Service connects to your AWS Account, and how deployment works.
---


## What a deployment is

A _deployment_ encompasses the artifacts, configuration, and actions that deliver your code to remote environments. You can configure a deployment to deliver your [AWS Lambda](https://docs.aws.amazon.com/lambda) function to a single environment or multiple environments, either in sequence or in parallel depending on your [deployment configuration]({{<ref "deployment/create-deploy-config" >}}).

You define your CD-as-a-Service deployment configuration in a YAML file, which you store within your source control, enabling code-like management. You trigger deployments using the Armory CLI, either from your CI system or your workstation.

## How deployment works

{{< figure src="lambda-deploy.webp" width=80%" height="80%" >}}

CD-as-a-Service starts a deployment with a target environment, which is a combination of AWS account and region. The first target in a deployment does not depend on other targets. Then deployment progresses through the steps, conditions, and targets defined in your deployment process. 

CD-as-a-Service automatically rolls back when:

  * There is an error deploying your Lambda function
  * Deployment fails to finish within 30 minutes
  * A webhook fails
  * You configured your retrospective analysis step to automatically rollback
  * A user fails to issue a configured manual approval within a specified time frame
  * A deployment target constraint is not met

How CD-as-a-Service performs rollbacks:

* If you have specified an [AWS Lambda alias](https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html) to use for routing traffic, CD-as-a-Service points the alias to the old version.
* If you have not specified an alias to use for routing traffic, CD-as-a-Service publishes a new version with the old configuration, so that the 'latest' version of your Lambda function has the same configuration as before the deployment started.

## How CD-as-a-Service integrates with AWS

{{< include "lambda/iam-role.md" >}}

You need to store your function zip files in an S3 bucket, and the S3 bucket should be in the same region you deploy to (this is an AWS limitation). For example, if you plan to deploy to three regions, you need three S3 buckets, one for each region. CD-as-a-Service deploys your Lambda function's archive from your S3 bucket.

| AWS Accounts | ArmoryRole | Regions | S3 Buckets |
|--------------|-----------|---------|------------|
| 1            | 1         | 4       | 4          |
| 4            | 4         | 1       | 1          |
| 4            | 4         | 4       | 4          |
| 2            | 2         | 6       | 6          |

For each Lambda function you want to deploy, CD-as-a-Service needs the following:

1. **ArmoryRole** ARN
1. Region
1. S3 path to the function zip file
1. The ARN of your [AWS Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)
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

With CD-as-a-Service, you declare your deployment configuration outcome in a YAML file. 

For an AWS Lambda deployment, you only need to provide the following pieces of information:

* The target you want to deploy to
* The AWS Lambda function you want to deploy
* Provider options for that AWS Lambda function
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

{{< include "overview-target-constraints.md" >}}

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

An _artifact_ is your AWS Lambda function name and the S3 path to the function's archive. 

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

For AWS Lambda, CD-as-a-Service supports a canary deployment strategy, which involves releasing a new software version to a small subset of users or systems while leaving the majority on the current version. This strategy allows for real-world testing and monitoring of the new version's performance and stability. 
If the canary users experience positive results, the new version can be gradually rolled out to a wider audience.

This example **routes 100% of traffic** to the **new version**. You’d use this `allAtOnce` strategy to initially deploy your function to AWS Lambda when the function does not exist in the AWS Lambda console. **This strategy is also useful in non-production environments such as staging.**

```yaml
strategies:
  allAtOnce:
    canary:
      steps:
        - setWeight:
            weight: 100
```

For subsequent deployments, you could use a canary strategy that splits traffic. CD-as-a-Service uses your function's AWS Lambda [alias](https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html) when splitting traffic between versions. 

>You must create the alias in the AWS Lambda console before using the alias in your CD-as-a-Service deployment.

This example uses a canary strategy that splits traffic. You declare your function's alias in the `trafficManagement` section. There are two entries in the `trafficManagement` section since both staging and prod targets use the traffic split strategy.

{{< readfile  file="/includes/code/lambda-traffic-split-snippet.yaml" code="true" lang="yaml" >}}


## {{% heading "nextSteps" %}}

* Work through the [AWS Lambda Quickstart]({{< ref "get-started/lambda" >}}) to deploy a sample function to your AWS Account.
* Learn how you can [monitor your deployment]({{< ref "deployment/monitor-deployment" >}}) using the UI or the CLI.
* View the deployment config file [reference]({{< ref "reference/deployment/config-file" >}}).

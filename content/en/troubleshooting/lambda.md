---
title: Troubleshoot AWS Lambda Deployment
linkTitle: AWS Lambda
weight: 1
description: >
  Solutions for issues you might encounter while deploying AWS Lambda functions using the Armory CD-as-a-Service.
---

## AWS Lamba Troubleshooting

CD-as-a-Service returns errors thrown by AWS Lambda. If you encounter an error, be sure to check the AWS Lambda docs' [troubleshooting section](https://docs.aws.amazon.com/lambda/latest/dg/lambda-troubleshooting.html).

## InvalidParameterValueException / PermanentRedirect

```yaml
AWSCreateLambdaError: operation error 
Lambda: CreateFunction, https response error 
StatusCode: 400, 
RequestID: ce98341e-8aa6-4c42-99e1-544245303295, 
InvalidParameterValueException: Error occurred while GetObject. 
S3 Error Code: PermanentRedirect. 
S3 Error Message: The bucket is in this region: us-east-2. Please use this region to retry the request
```

You need to have an S3 bucket with your function archive in the region you want to deploy your function to. This is an AWS constraint.

For example (same AWS Account):

| Function        | Target and Region | S3 Bucket Region | Bucket Name   | Function Path                      | 
|-----------------|-------------------|------------------|---------------|------------------------------------|
| hello-world.zip | Dev: us-east-1       | us-east-1        | lambda-us-east-1 | s3://lambda-us-east-1/hello-world.zip | 
| hello-world.zip | Staging: us-east-2  | us-east-2          | lambda-us-east-1 | s3://lambda-us-east-2/hello-world.zip | 
| hello-world.zip | Infosec: us-west-1   | us-west-1           | lambda-us-east-1 | s3://lambda-us-west-1/hello-world.zip |
| hello-world.zip | Prod: us-west-2      | us-west-2           | lambda-us-east-1 | s3://lambda-us-west-2/hello-world.zip |
| hello-world.zip | Prod: eu-central-1      | eu-central-1            | lambda-eu-central-1  | s3://lambda-eu-central-1/hello-world.zip |

For more details, see the AWS Lambda [InvalidParameterValueException](https://docs.aws.amazon.com/lambda/latest/dg/troubleshooting-deployment.html#troubleshooting-deployment-InvalidParameterValueException1) and [PermanentRedirect](https://docs.aws.amazon.com/lambda/latest/dg/troubleshooting-deployment.html#troubleshooting-deployment-PermanentRedirect) troubleshooting docs.

## ResourceConflictException

```yaml
AWSUpdateLambdaError: operation error
Lambda: UpdateFunctionCode, https response error
StatusCode: 409, 
RequestID: 8027c7ee-0762-4027-a238-2c636a716d48, 
ResourceConflictException: Conflict due to concurrent requests on this function. Please try this request again.
```

You see this error when you have concurrent deployments to same region.

For example, deploying this config results in a `ResourceConflictException` error. The `staging` and `audit` targets both deploy to `us-east-2` and depend on `dev`, so CD-as-a-Service deploys them concurrently. 

```yaml
version: v1
kind: lambda
application: Sweet Potato Lambda
description: Sweet Potato facts from a Lambda function
deploymentConfig:
  timeout:
    unit: minutes
    duration: 10
targets:
  dev:
    account: armory-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-1
    strategy: allAtOnce
  staging:
    account: armory-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-2
    strategy: allAtOnce
    constraints:
      dependsOn:
        - dev
  audit:
    account: armory-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-2
    strategy: allAtOnce
    constraints:
      dependsOn:
        - dev
```

The fix for this is to deploy `audit` to a different region or a different AWS Account.
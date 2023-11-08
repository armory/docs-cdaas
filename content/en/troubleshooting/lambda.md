---
title: Troubleshoot Lambda Deployment
linkTitle: Lambda
weight: 1
description: >
  Solutions for issues you might encounter while deploying AWS Lambda functions using the Armory CD-as-a-Service.
---



## InvalidParameterValueException

```yaml
AWSCreateLambdaError: operation error 
Lambda: CreateFunction, https response error 
StatusCode: 400, 
RequestID: ce98341e-8aa6-4c42-99e1-544245303295, 
InvalidParameterValueException: Error occurred while GetObject. 
S3 Error Code: PermanentRedirect. 
S3 Error Message: The bucket is in this region: us-east-2. Please use this region to retry the request
```

Duplicate functionName in deploy config file

You need to have an S3 bucket with your function archive in the region you want to deploy your function to.

For example:

| Function        | Target and Region | S3 Bucket Region | Bucket Name   | Function Path                      | 
|-----------------|-------------------|------------------|---------------|------------------------------------|
| hello-world.zip | Dev: us-east-1       | us-east-1        | lambda-us-east-1 | s3://lambda-us-east-1/hello-world.zip | 
| hello-world.zip | Staging: us-east-1   | us-east-1           | lambda-us-east-1 | s3://lambda-us-east-1/hello-world.zip | 
| hello-world.zip | Infosec: us-east-1   | us-east-1           | lambda-us-east-1 | s3://lambda-us-east-1/hello-world.zip |
| hello-world.zip | Prod: us-east-1      | us-east-1           | lambda-us-east-1 | s3://lambda-us-east-1/hello-world.zip |
| hello-world.zip | Prod: us-east-2      | us-east-2           | lambda-us-east-2 | s3://lambda-us-east-2/hello-world.zip |
| hello-world.zip | Prod: us-west-1      | us-west-1           | lambda-us-west-1 | s3://lambda-us-west-1/hello-world.zip |
| hello-world.zip | Prod: us-west-2      | us-west-2           | lambda-us-west-2 | s3://lambda-us-west-2/hello-world.zip |




## ResourceConflictException

AWSUpdateLambdaError: operation error Lambda: UpdateFunctionCode, https response error StatusCode: 409, RequestID: 8027c7ee-0762-4027-a238-2c636a716d48, ResourceConflictException: Conflict due to concurrent requests on this function. Please try this request again.

 Concurrent deployments to same region


2 concurrent targets in same region

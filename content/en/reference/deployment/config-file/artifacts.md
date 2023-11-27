---
title: Artifacts and Provider Options (AWS Lambda)
description: >
  Declare your AWS Lambda artifacts (functionName, path, type) and provider options.
---

**AWS Lambda Only**

## Artifacts

This section defines the AWS Lambda artifacts you are deploying. The artifacts reach all target for which there is a provider option block for that function name.

```yaml
artifacts:
  - functionName: <function-name>
    path: <path-to-function>
    type: zipFile
```

* `functionName`: A unique name for each entry in the `artifacts` collection. You also use this value for `providerOptions.lambda.name` and `trafficManagement.alias.functionName`.
* `path`: The S3 path to your function's zip file
* `type`: This value is always `zipFile`. CD-as-a-Service does not support deploying AWS Lambda containers.

If you want to deploy to multiple regions in the same AWS Account, your `functionName` should be unique for the region.

In this example, you deploy a function called `just-sweet-potatoes` to four regions in the same AWS Account:

```yaml
targets:
  dev:
    account: <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-east-1
    strategy: allAtOnce
  staging:
    account:  <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-east-2
    strategy: allAtOnce
    constraints:
      dependsOn:
        - dev
  prod-west-1:
    account:  <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-west-1
    strategy: allAtOnce
    constraints:
      dependsOn:
        - staging
  prod-west-2:
    account:  <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-west-2
    strategy: allAtOnce
    constraints:
      dependsOn:
        - staging
artifacts:
  - functionName: just-sweet-potatoes-us-east-1
    path: s3://armory-demo-east-1/just-sweet-potatoes.zip
    type: zipFile
  - functionName: just-sweet-potatoes-us-east-2
    path: s3://armory-demo-east-2/just-sweet-potatoes.zip
    type: zipFile
  - functionName: just-sweet-potatoes-prod-west-1
    path: s3://armory-demo-west-1/just-sweet-potatoes.zip
    type: zipFile
  - functionName: just-sweet-potatoes-prod-west-2
    path: s3://armory-demo-west-2/just-sweet-potatoes.zip
    type: zipFile
```

## Provider options

This section defines options specific to the cloud provider to which you are deploying. You need to populate provider options for each deployment target.

```yaml
providerOptions:
  lambda:
    - name: <function-name>
      target: <target-name>
      runAsIamRole: <lambda-execution-role>
      handler: <function-handler> 
      runtime: <function-runtime>      
```

{{< include "dep-file/lambda-provider-options.md" >}}

```yaml
targets:
  dev:
    account: <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-east-1
    strategy: allAtOnce
  staging:
    account:  <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-east-2
    strategy: allAtOnce
    constraints:
      dependsOn:
        - dev
  prod-west-1:
    account:  <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-west-1
    strategy: allAtOnce
    constraints:
      dependsOn:
        - staging
  prod-west-2:
    account:  <account-name>
    deployAsIamRole: <armory-role-arn>
    region: us-west-2
    strategy: allAtOnce
    constraints:
      dependsOn:
        - staging
artifacts:
  - functionName: just-sweet-potatoes-us-east-1
    path: s3://armory-demo-east-1/just-sweet-potatoes.zip
    type: zipFile
  - functionName: just-sweet-potatoes-us-east-2
    path: s3://armory-demo-east-2/just-sweet-potatoes.zip
    type: zipFile
  - functionName: just-sweet-potatoes-prod-west-1
    path: s3://armory-demo-west-1/just-sweet-potatoes.zip
    type: zipFile
  - functionName: just-sweet-potatoes-prod-west-2
    path: s3://armory-demo-west-2/just-sweet-potatoes.zip
    type: zipFile
providerOptions:
  lambda:
    - name: just-sweet-potatoes-us-east-1
      target: dev
      runAsIamRole: <execution-role-arn>
      handler: index.handler
      runtime: python3.10
    - name: just-sweet-potatoes-us-east-2
      target: staging
      runAsIamRole: <execution-role-arn>
      handler: index.handler
      runtime: python3.10
    - name: just-sweet-potatoes-prod-west-1
      target: prod-west-1
      runAsIamRole: <execution-role-arn>
      handler: index.handler
      runtime: python3.10
    - name: just-sweet-potatoes-prod-west-2
      target: prod-west-2
      runAsIamRole: <execution-role-arn>
      handler: index.handler
      runtime: python3.10
```

## Multiple AWS Account example

This illustrates deploying a function to the same region in multiple AWS Accounts.

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
artifacts:
  - functionName: hello-world-python
    path: s3://armory-demos-us-west-2/hello-world-python.zip
    type: zipFile
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

The S3 bucket has a policy that makes it accessible to multiple accounts in the same organization.

---
title: Provider Options (Lambda)
description: >
  Declare your Lambda provider options.
---

## Provider options

This section defines options specific to the cloud provider to which you are deploying.

```yaml
providerOptions:
  lambda:
    - handler: <function-handler>  # typically index.handler
      name: <function-name>
      runAsIamRole: <lambda-execution-role>
      runtime: <function-runtime>  # nodejs18.x, Python, etc
      target: <target-name>
```


- `handler`: Lambda function handler name, such as `index.handler`
- `name`: The name of your function; this is the same as `artifacts.functionName`
- `runAsIamRole`: The name of the [AWS Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html) for your function
- `runtime`: Your function's [runtime identifier](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html), such as `python3.22` or `nodejs18.x`
- `target`: CD-as-a-Service [target]({{< ref "reference/deployment/config-file/targets" >}})
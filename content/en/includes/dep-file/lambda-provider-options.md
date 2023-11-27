* `target`:  CD-as-a-Service deployment [target]({{< ref "reference/deployment/config-file/targets" >}}) name
* `name`: This is the same value as `artifacts.functionName` and `trafficManagement.alias.functionName` for the target region. This function name appears on your AWS Lambda **Functions** list page.
* `runAsIamRole`: Replace `<execution-role-arn>` with the ARN of your [AWS Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html), which is **not** the ArmoryRole ARN.
* `handler`: The function's handler method, such as `index.handler`. This value is written to the **Runtime settings** section in the AWS Lambda function details page.
* `runtime`: [runtime identifier](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html), such as `python3.22` or `nodejs18.x`. This value is written to the **Runtime settings** section in the AWS Lambda function details page.

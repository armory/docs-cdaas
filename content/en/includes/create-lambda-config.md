1. Create a YAML file with this basic content:

   ```yaml
   version: v1
   kind: lambda
   application: <application-name>
   strategies:
     canary:
       steps:
         - setWeight:
             weight: 100
   targets:
     <target-name>:
       account: <aws-account-name>
       deployAsIamRole: <armory-role-arn>
       region: <aws-region>
       strategy: canary
   artifacts:
     - functionName: <function-name>
       path: <s3-path-to-function-zip>
       type: zipFile
   providerOptions:
    lambda:
      - target: <target-name>
        name: <function-name>   
        runAsIamRole: <execution-role-arn>
        handler: <handler-function>
        runtime: <runtime>
   ```

   These sections are the minimum you need to declare to deploy an AWS Lambda function.

1. Customize your deployment file by setting the following minimum set of parameters:

   - `application`: The name of your function. This appears in the **Deployments** list page.
   - `targets.<target-name>`: A descriptive name for your deployment. 

      * `account`: A descriptive name for the AWS Account this target resides in, such as `armory-docs-dev`.
      * `deployAsIamRole`: The ARN of the [ArmoryRole]({{< ref "deployment/lambda/create-iam-role-lambda" >}}) that 
        CD-as-a-Service assumes to deploy your function.
      * `region`: The AWS Region to deploy your function to.
  
   * `artifacts`

      * `functionName`: A unique name for each entry in the `artifacts` collection.
      * `path`: The S3 path to your function's zip file.

   * `providerOptions.lambda`

      {{< include "dep-file/lambda-provider-options.md" >}}

1. (Optional) Ensure there are no YAML issues with your deployment file.

   Since a hidden tab in your YAML can cause your deployment to fail, it's a good idea to validate the structure and syntax in your deployment file. There are several online linters, IDE-based linters, and command line linters such as `yamllint` that you can use to validate your deployment file.

> You can view detailed configuration options in the {{< linkWithTitle "reference/deployment/config-file/_index.md" >}} section.

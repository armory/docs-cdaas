---
title: Quickstart AWS Lambda Deployment
linktitle: Quickstart AWS Lambda
description: >
  Quickly get started using Armory CD-as-a-Service to deploy to AWS Lambda. Install the CLI, connect to AWS Lambda with a single command, and deploy a sample app. Learn deployment file syntax.
weight: 2
categories: ["Get Started", "Guides"]
tags: ["Deployment", "Quickstart"]
---


## Learning objectives

1. [Sign up for CD-as-a-Service](#sign-up-for-cd-as-a-service).
1. [Install the CD-as-as-Service CLI](#install-the-cd-as-as-service-cli) on your Mac, Linux, or Windows workstation.
1. 


## {{% heading "prereq" %}}

* You are familiar with CD-as-a-Service's [key components]({{< ref "architecture.md" >}}).
* You should be familiar with [AWS Lambda](https://aws.amazon.com/lambda/) and have a [Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html).
* You have read the {{< linkWithTitle "deployment/lambda/index.md" >}}.

## Sign up for CD-as-a-Service

{{< include "register.md" >}}

## Install the CD-as-as-Service CLI

{{< include "cli/install-cli-tabpane.md" >}}

### Log in with the CLI

```shell
armory login
```

Confirm the device code in your browser when prompted. Then return to this guide.    

## Create the Armory IAM role

{{< include "lambda/iam-role.md" >}}

1. In your default browser, log in to your AWS Account. You must have permissions to configure IAM roles.
1. In your terminal, execute the following:

   ```bash
   armory aws create-role
   ```

   Type "Y" in the terminal to continue with Stack creation. This opens your browser to the CloudFormation page of your AWS Console. You complete the rest of this process in your browser.

1. Review the resources that CD-as-a-Service is creating in your AWS account. The default IAM Role name is **ArmoryRole**.
1. Click **Create** on the AWS CloudFormation page and wait for Stack creation to finish.
1. After the CloudFormation Stack creation finishes, locate the created role ARN in the **Outputs** section. You can find it under the key **RoleArnOutput**. Make note of the ARN since you use it in your deployment config file.

## Create S3 buckets

You need to store your Lambda function as a zip file in an S3 bucket, and S3 bucket needs to be in the same region you deploy to. For this guide, you are going to deploy the Lambda function to four regions so you need to create four buckets:


| Region | Bucket Name | 
| ---------|----------|
| us-east-1 | armory-demo-east-1 | 
| us-east-2 | armory-demo-east-2 | 
| us-west-1 | armory-demo-west-1 | 
| us-west-2 | armory-demo-west-2 |

Use the default values for the rest of the fields. 

After you have finished, you should have four buckets.

{{< figure src="s3-buckets.webp" >}}

## Upload the Lambda function to your buckets

Armory provides a basic Lambda function called `just-sweet-potatoes` for you to deploy.

<details><summary>Expand to see the code</summary>

`index.js` has the following content:

```js
exports.handler = async (event) => {
    
  const randomFact = potatolessFacts[Math.floor(Math.random() * potatolessFacts.length)];

  // Prepare the response
  const response = {
    statusCode: 200,
    body: randomFact,
  };

  return response;
};

const potatolessFacts = [
    "Sweet potatoes are a great source of vitamin A, which is important for vision health.",
    "There are over 400 varieties of sweet potatoes around the world.",
    "Sweet potatoes are not related to regular potatoes; they belong to the morning glory family.",
    "Sweet potatoes are high in fiber, making them good for digestion.",
    "Sweet potatoes come in different colors, including orange, purple, and white.",
    "Sweet potatoes are one of the oldest vegetables known to man.",
    "North Carolina is the largest producer of sweet potatoes in the United States.",
    "Sweet potatoes are often used in Thanksgiving dishes like casseroles and pies.",
  ];
```

</details>

1. <a href="/get-started/lambda/files/just-sweet-potatoes.zip" download>Download the Lambda zip file</a>
1. Upload the file to your `armory-demo-lambda-deploy` S3 bucket.
1. Make a note of each bucket's S3 path to the lambda function. They should be:
  
  * `s3://armory-demo-east-1/just-sweet-potatoes.zip`
  * `s3://armory-demo-east-2/just-sweet-potatoes.zip`
  * `s3://armory-demo-west-1/just-sweet-potatoes.zip`
  * `s3://armory-demo-west-2/just-sweet-potatoes.zip`

## Create your deployment config file

First create a file called `deploy.yaml` with the following contents:

{{< highlight yaml "linenos=table, hl_lines=2 3 4" >}}
version: v1
kind: lambda
application: just-sweet-potatoes
description: A demo function for deployment using CD-as-a-Service
{{< /highlight >}}

* `kind`: `lambda` tells CD-as-a-Service the deployment type
* `application`: This is the unique name of your deployment and appears in the **Deployments** list.
* `description`: Brief description of your function (optional)

### Add targets


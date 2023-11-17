---
title: Create an Armory IAM Role for AWS Lambda Deployment
linkTitle: Create Armory IAM Role
weight: 5
description: >
  Create the Armory IAM Role that CD-as-a-Service assumes when it deploys your AWS Lambda function.
---

## {{% heading "prereq" %}}

Make sure you have [installed the CD-as-a-Service CLI]({{< ref "cli" >}}), which you can use to generate a deployment template.

## Create the Armory IAM role

{{< include "lambda/iam-role.md" >}}

{{< include "lambda/iam-role-steps.md" >}}

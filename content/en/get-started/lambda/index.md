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
1. [Connect your Kubernetes cluster](#connect-your-cluster) to CD-as-a-Service.


## {{% heading "prereq" %}}

* You are familiar with CD-as-a-Service's [key components]({{< ref "architecture.md" >}}).
* You should be familiar with [AWS Lambda](https://aws.amazon.com/lambda/) and have a [Lambda execution role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html).


## Sign up for CD-as-a-Service

{{< include "register.md" >}}

## Install the CD-as-as-Service CLI

{{< include "cli/install-cli-tabpane.md" >}}

### Log in with the CLI

```shell
armory login
```

Confirm the device code in your browser when prompted. Then return to this guide.    

## Create the Armory role
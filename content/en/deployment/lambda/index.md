---
title: AWS Lambda Deployment Overview
linktitle: AWS Lambda Overview
weight: 1
description: >
 Learn what an Armory CD-as-a-Service deployment to AWS Lambda is, how CD-as-a-Service connects to your AWS Account, and how deployment works.
---


## What a deployment is

A _deployment_ encompasses the manifests, artifacts, configuration, and actions that deliver your code to remote environments. You can configure a deployment to deliver your Lambda function to a single environment or multiple environments, either in sequence or in parallel depending on your [deployment configuration]({{<ref "deployment/create-deploy-config" >}}).

You define your CD-as-a-Service deployment configuration in a YAML file, which you store within your source control, enabling code-like management. You trigger deployments using the Armory CLI, either from your CI system or your workstation. Although CD-as-a-Service requires a separate deployment configuration file for each app, you can deploy multiple Kubernetes Deployment objects together as part of a single app. 

## How deployment works

{{< figure src="lambda-deploy.webp" width=80%" height="80%" >}}

CD-as-a-Service starts a deployment with a target environment, which is a combination of AWS account and region. such as development, that does not depend on another environment. Then deployment progresses through the steps, conditions, and environments defined in your deployment process. 


CD-as-a-Service automatically rolls back when:
  * There is an error deploying your Lambda function
  * Deployment fails to finish within 30 minutes
  * A webhook fails
  * You configured your retrospective analysis step to automatically rollback
  * A user fails to issue a configured manual approval within a specified time frame
  * A deployment target constraint is not met

## How CD-as-a-Service integrates with AWS

ArmoryRole per account

S3 bucket per region

zip in region bucket that matches target deploy region

4 accounts all deploy to 1 region, only need 1 S3 bucket

1 account deploy to 4 regions, need 4 S3 buckets

## How to trigger a deployment

* [Use the GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}) in your GitHub workflow.
* [Use the CLI]({{< ref "cli" >}}) with any CI system by installing the CLI natively or running it in Docker.


## Define your deployment

CD-as-a-Service enables you to declaratively define your deployment configuration outcome in a YAML file. 
At its core, you only need to provide only three pieces of information:

* The target you want to deploy to
* The Lambda function you want to deploy
* The deployment strategy you want to use for the deployment

An example of a simple deployment may look like this:
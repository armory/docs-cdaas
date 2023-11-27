---
title: How to Get Started using Armory CD-as-a-Service
linkTitle: Overview
description: >
  Learn what you need to get started deploying your AWS Lambda function or an app to Kubernetes.
weight: 1
---

## What you need to use CD-as-a-Service

You need a Mac, Linux, or Windows workstation and access to a Kubernetes cluster or AWS Lambda. 

If you need a Kubernetes cluster, consider installing a local [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/) cluster. Your cluster's API endpoint does not need to be publicly accessible to use CD-as-a-Service. Alternately, you can use a interactive learning environment like [Killercoda](https://killercoda.com/learn).


## AWS Lambda

### Deploy a sample app provided by Armory

  * Written [Quickstart guide]({{< ref "get-started/lambda.md" >}}) deploying a sample function to your AWS account

## Kubernetes

### Deploy a sample app provided by Armory

  * [Guided UI tour](https://console.cloud.armory.io/getting-started) using an Armory sandbox cluster
  * Written [Quickstart guide]({{< ref "get-started/quickstart.md" >}}) deploying a sample app to your own cluster

### Deploy your own app to your cluster

  * [Guided UI tour](https://console.cloud.armory.io/getting-started?gettingStartedPane=InstallFlowPane)
  * Written [Deploy Your Own App]({{< ref "get-started/deploy-your-app.md" >}}) guide
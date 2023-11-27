---
title: Deployment Config File Reference
linkTitle: Deployment Config File
weight: 1
description: >
  The deployment config file is where you configure your AWS Lambda function or Kubernetes app for deployment by Armory CD-as-a-Service. This config file includes application, artifacts, provider options, deploymentConfig, targets, manifests, strategies, analysis, webhooks, and trafficManagement definitions.
---

## Deployment config file examples

### AWS Lambda

{{< include "dep-file/lambda-skeleton-config.md" >}}

### Kubernetes

{{< include "dep-file/k8s-skeleton-config.md" >}}

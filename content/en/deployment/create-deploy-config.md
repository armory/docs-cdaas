---
title: Create a Deployment Config File
linkTitle: Create Deploy Config
weight: 2
categories: ["Deployment", "Guides"]
tags: ["Deploy Config"]
description: >
  Create a config file to deploy your app to your Kubernetes cluster using CD-as-a-Service.
---

## {{% heading "prereq" %}}

Make sure you have [installed the CD-as-a-Service CLI]({{< ref "cli" >}}), which you can use to generate a deployment template.

## How to create a deployment config file

{{< include "create-config.md" >}}

## Deployment config file example

{{< include "dep-file/skeleton-config.md" >}}

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "reference/deployment/config-file/_index.md" >}}

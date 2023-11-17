---
title: Create a Deployment Config File
linkTitle: Create Deploy Config
weight: 3
description: >
  Create a config file to deploy your app to your Kubernetes cluster using CD-as-a-Service.
---

## {{% heading "prereq" %}}

Make sure you have [installed the CD-as-a-Service CLI]({{< ref "cli" >}}), which you can use to generate a deployment template.

## How to create a deployment config file

{{< tabpane text=true right=true >}}
{{% tab header="**Platform:**" disabled=true /%}}
{{% tab header="Kubernetes" %}}
{{< include "create-k8s-config.md" >}}
{{% /tab %}}
{{% tab header="AWS Lambda" %}}
{{< include "create-lambda-config.md" >}}
{{% /tab %}}
{{< /tabpane >}}

## Deployment config file examples

### Kubernetes

{{< include "dep-file/k8s-skeleton-config.md" >}}

### AWS Lambda

{{< include "dep-file/lambda-skeleton-config.md" >}}


## {{% heading "nextSteps" %}}

* {{< linkWithTitle "reference/deployment/config-file/_index.md" >}}

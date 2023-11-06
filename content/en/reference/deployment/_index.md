---
title: Deployment Reference
linkTitle: Deployment
weight: 1
no_list: true
description: >
  Create a deployment config file to use with Armory CD-as-a-Service. Browse the deployment config file reference. Learn how to configure preview links and role-based manual approvals.
categories: ["Reference"]
tags: ["Deployment", "Deploy Config"]
---

## Deployment config file reference overview

The deployment config file is what you use to define how and where Armory CD-as-a-Service deploys your app.

Make sure you have [installed the CD-as-a-Service CLI]({{< ref "cli" >}}), which you can use to generate a deployment template.

## Templates

You can generate a Kubernetes deployment config file template by running the following command with the CLI:

Basic template:

```bash
armory template kubernetes [command]
```
where `command` is the type of template.
</br>

Automated canary analysis template:

```bash
armory template kubernetes canary -f automated
```

Blue/green deployment template:

```bash
armory template kubernetes bluegreen
```

To use a template, output it to a file and modify it to suit your needs:

```bash
armory template kubernetes [template-type] > deployment-template.yaml
```


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
* {{< linkWithTitle "reference/deployment/config-preview-link.md" >}}
* {{< linkWithTitle "reference/deployment/config-role-based-manual-approval.md" >}}
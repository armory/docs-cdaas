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

@TODO or change `no_list` to false to simply list pages in this section

## Deployment config file reference overview

The deployment config file is what you use to define how and where Armory CD-as-a-Service deploys your app.

Make sure you have [installed the CD-as-a-Service CLI]({{< ref "cli" >}}), which you can use to generate a deployment template.

## Templates

You can generate a template file by running the following command with the CLI:

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

{{< include "create-config.md" >}}


<details><summary>Show me an example deployment file</summary>
This file is in the <a href="https://github.com/armory/docs-cdaas-sample" target="_blank">armory/docs-cdaas-sample repo</a>.

{{< github repo="armory/docs-cdaas-sample" file="/deploy.yml" lang="yaml" options="" >}}
</details><br>

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "reference/deployment/config-file/_index.md" >}}
* {{< linkWithTitle "reference/deployment/config-preview-link.md" >}}
* {{< linkWithTitle "reference/deployment/config-role-based-manual-approval.md" >}}
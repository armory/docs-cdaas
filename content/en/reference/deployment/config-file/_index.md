---
title: Deployment Config File Reference
linkTitle: Deployment Config File
weight: 1
description: >
  The deployment (deploy) file is where you configure your app for deployment by Armory CD-as-a-Service. This config file includes deployment artifact, target, strategy, and traffic management definitions.
categories: ["Reference"]
tags: ["Deployment", "Deploy Config"]
---

## Deployment config file reference overview

The deployment config file is what you use to define how and where Armory CD-as-a-Service deploys your app.

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

<details><summary>Show me an example deployment file</summary>
This file is in the <a href="https://github.com/armory/docs-cdaas-sample" target="_blank">armory/docs-cdaas-sample repo</a>.

{{< github repo="armory/docs-cdaas-sample" file="/deploy.yml" lang="yaml" options="" >}}
</details><br>











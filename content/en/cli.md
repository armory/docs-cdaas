---
title: Install and Upgrade the CD-as-a-Service CLI
linkTitle: CLI
weight: 10
categories: ["CLI", "Tools"]
tags: ["CLI"]
description: >
  Install the Armory Continuous Deployment-as-a-Service CLI natively on Linux or Mac or use a Docker image. 
---

## CLI overview

You can install the CLI (`armory`) on your Mac, Linux, or Windows workstation. Additionally, you can run the CLI in Docker. 

On Mac, you can also download, install, and update the CLI using the Armory Version Manager (AVM). The AVM includes additional features such as the ability to list installed CLI versions and to declare which version of the CLI to use.

{{< include "cli/install-cli-tabpane" >}}

## Upgrade the CLI

{{< tabpane text=true right=true >}}
{{% tab header="**Method**:" disabled=true /%}}
{{% tab header="Homebrew" %}}
```bash
brew upgrade armory-cli
```
{{% /tab %}}
{{% tab header="AVM" %}}
```bash
avm install
```
{{% /tab %}}

{{< /tabpane >}}
---
title: Install a Remote Network Agent in Your Cluster Using the CLI
linktitle: Install - CLI
weight: 1
description: >
  Install a CD-as-a-Service Remote Network Agent in your Kubernetes cluster.
categories: ["Guides"]
tags: [ "Networking", "Remote Network Agent", "CD-as-a-Service Setup"]
---

## {{% heading "prereq" %}}

* You have access to your own Kubernetes cluster.

>You do not need to create **Client Credentials** for this option. The CLI does that for you.

## Steps

1. Install the CLI if you haven't already.

   {{< include "install-cli.md" >}}

1. Log in using the CLI.

   ```shell
   armory login
   ```

1. Make sure you are connected to your cluster.

1. Install the RNA in your cluster.

   ```shell
   armory agent create
   ```

   You choose your cluster and provide an **agent identifier** (cluster name) for the RNA during the installation process.
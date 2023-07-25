---
title: Configure Remote Network Agent Advanced Options
linktitle: Install - Advanced Config
weight: 6
description: >
  Use Helm or Kubernetes manifests to configure and install a Remote Network Agent in your Kubernetes cluster. Configure a proxy 
categories: ["Guides"]
tags: [ "Networking", "Remote Network Agent", "CD-as-as-Service Setup"]
---

## Remote Network Agent installation methods

By default, you install a Remote Network Agent (RNA) with full access to your cluster. At a minimum, the RNA needs permissions to create, edit, and delete all `kind` objects that you plan to deploy with CD-as-a-Service, in all namespaces you plan to deploy to. The RNA also requires network access to any monitoring solutions or webhook APIs that you plan to forward through it.

{{% alert title="Important" color="warning" %}}
If you are coming to this guide from the UI **Install a Remote Network Agent** screen because you want to manually install the RNA, follow the [Helm instructions](#install-using-helm). Use the cluster name you created to identify your RNA. Copy the **Client ID** and **Client Secret** from the UI.

_Do not close the pop-up window in the UI until you have completed RNA installation. The credentials in the pop-up window are deleted if you close the window before the RNA has connected._
{{% /alert %}}
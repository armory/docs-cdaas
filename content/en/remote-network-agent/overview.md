---
title: Remote Network Agent Installation Overview
linktitle: Overview
weight: 1
categories: ["Remote Network Agent", "Features", "Concepts"]
tags: ["Remote Network Agent"]
description: >
  Learn about the various methods to install an Armory CD-as-a-Service Remote Network Agent in your Kubernetes cluster: kubectl, Helm, Armory CLI, or a UI wizard.
---

## Remote Network Agent installation methods

By default, you install a Remote Network Agent (RNA) with full access to your cluster. At a minimum, the RNA needs permissions to create, edit, and delete all `kind` objects that you plan to deploy with CD-as-a-Service, in all namespaces you plan to deploy to. The RNA also requires network access to any monitoring solutions or webhook APIs that you plan to forward through it.

You can install the Remote Network Agent (RNA) in your Kubernetes cluster using one of the following:

* [**UI wizard**]({{< ref "remote-network-agent/install-agent-ui" >}})
  * Use a UI wizard to generate an install script that includes **Client Credentials**
  * Install using default configuration
  * Not recommended for production environments
* [**CLI**]({{< ref "remote-network-agent/install-agent-cli" >}})
  * Install using default configuration
  * Not recommended for production environments
* [**kubectl**]({{< ref "remote-network-agent/install-agent-kubectl" >}})
  * Install using default configuration
  * Not recommended for production environments
* [**Helm**]({{< ref "remote-network-agent/install-agent-helm" >}})
  * Install using default or advanced configuration
  * Recommended for production environments

{{% alert title="Important" color="warning" %}}
If you are coming to this guide from the UI **Install a Remote Network Agent** screen because you want to manually install the RNA, follow the [kubectl instructions]({{< ref "remote-network-agent/install-agent-kubectl" >}}) or the [Helm instructions]({{< ref "remote-network-agent/install-agent-helm" >}}). Use the cluster name you created to identify your RNA. Copy the **Client ID** and **Client Secret** from the UI.

_Do not close the pop-up window in the UI until you have completed RNA installation. The credentials in the pop-up window are deleted if you close the window before the RNA has connected._
{{% /alert %}}

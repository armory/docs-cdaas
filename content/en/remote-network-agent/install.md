---
title: Remote Network Agent Installation
linktitle: Install
weight: 2
description: >
  Install and Configure Armory's Remote Network Agent.
---


{{< tabpane text=true right=true >}}
{{% tab header="**Method**:" disabled=true /%}}

{{% tab header="CLI" %}}
## {{% heading "prereq" %}}

* You have access to your own Kubernetes cluster.

>You do not need to create **Client Credentials** for this option. The CLI does that for you.

## Steps

1. Install the CLI if you haven't already.

   {{< include "install-cli.md" >}}

2. Log in using the CLI.

   ```shell
   armory login
   ```

3. Make sure you are connected to your cluster.

4. Install the RNA in your cluster.

   ```shell
   armory agent create
   ```

   You choose your cluster and provide an **agent identifier** (cluster name) for the RNA during the installation process.
{{% /tab %}}

{{% tab header="Helm" %}}
## {{% heading "prereq" %}}

* You have access to your own Kubernetes cluster.
* You have a role that allows you to create **Client Credentials** and connect a Remote Network Agent.

  <details><summary>Show me how</summary>
  {{< include "client-creds.md" >}}
  </details>

## Steps

{{< include "rna/rna-install-helm.md" >}}
{{% /tab %}}

{{% tab header="kubectl" %}}

## {{% heading "prereq" %}}

* You have access to your own Kubernetes cluster.
* You have a role that allows you to create **Client Credentials** and connect a Remote Network Agent.

  <details><summary>Show me how</summary>
   {{< include "client-creds.md" >}}
  </details>

## Steps

{{< include "rna/rna-install-kubectl.md" >}}
{{% /tab %}}

{{% tab header="UI" %}}
## Generate install script using a UI wizard

>You do not need to create **Client Credentials** for these options. The UI does that for you.

### Option 1

1. In the CD-as-a-Service Console, navigate to the **Welcome to Continuous Deployment-as-a-Service** [Configuration page](https://console.cloud.armory.io/configuration).
1. Click **Connect your Kubernetes Cluster**.
1. In the **Select Installation Method** window, select either **Connect Cluster Using Helm** or **Connect Cluster Using Kubectl**.
1. In the **Identify Your Cluster** window, enter an agent identifier for your Remote Network Agent (RNA) in the **Cluster Name** field. You install this RNA in the cluster where you want to deploy your app, so create a meaningful identifier.
1. Click **Continue**.
1. Copy the script from the **Connect New Remote Network Agent** window and run it locally.

### Option 2

1. In the CD-as-a-Service Console, navigate to the [Configuration page](https://console.cloud.armory.io/configuration).
1. Access the **Networking** > **Agents** screen.
1. Click **Add an Agent**.
1. In the **Name New Remote Network Agent** window, enter a name for your Remote Network Agent (RNA) in **Agent Identifier**. You install this RNA in the cluster where you want to deploy your app, so create a meaningful name.
1. Choose **I want to use my own cluster.** in the **Choose Cluster Type** window.
1. Copy the script in the **Install a Remote Network Agent** window and run it locally using kubectl.
{{% /tab %}}

{{< /tabpane >}}
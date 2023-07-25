---
title: Install a Remote Network Agent in Your Cluster
linktitle: Install - Basic
weight: 5
description: >
  Use the CD-as-a-Service Console, the CLI, Helm, or kubectl to install a CD-as-a-Service Remote Network Agent in your Kubernetes cluster. 
categories: ["Guides"]
tags: [ "Networking", "Remote Network Agent", "CD-as-as-Service Setup"]
---

<!-- The CDaaS UI links to this page. Do not change the title. -->

## {{% heading "prereq" %}}

You are familiar with [what a a Remote Network Agent is and its core features]({{< ref "remote-network-agent/overview" >}}).

## Remote Network Agent installation methods

By default, you install a Remote Network Agent (RNA) with full access to your cluster by using one of the following:

* [**UI wizard**](#generate-install-script-using-a-ui-wizard)
  * Use a UI wizard to generate an install script that includes Client Credentials 
  * Install using default configuration
  * Not recommended for production environments
* [**CLI**](#install-manually-using-the-cli)
  * Install using default configuration
  * Not recommended for production environments
* [**kubectl**](#install-manually-using-kubectl)
  * Install using default or [advanced configuration]({{< ref "remote-network-agent/install-advanced" >}}).
  * Advanced configuration recommended for production environments
* [**Helm**](#install-manually-using-helm)
  * Install using default or [advanced configuration]({{< ref "remote-network-agent/install-advanced" >}}).
  * Recommended for production environments


## {{% heading "prereq" %}}

* You have a role that allows you to create [Client Credentials]({{< ref "iam/manage-client-creds" >}}) and connect a Remote Network Agent.

  * For the UI and CLI methods, you **do not** need to create Client Credentials. Those methods create Client Credentials for you.
  * For the kubectl and Helm methods, you **do** need to create Client Credentials.

    <details><summary>Show me how to create Client Credentials</summary>
    {{< include "client-creds.md" >}}
    </details></br> 

* You have access to your own Kubernetes cluster.

## Install with default configuration

Default configuration:

* Namespace: `armory-rna`
* Permissions: Full access to your cluster
</br>

{{< tabpane text=true right=true >}}
{{% tab header="**Method**:" disabled=true /%}}
{{% tab header="UI Wizard" %}}

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
{{% tab header="CLI"  %}}

{{< include "rna/rna-install-cli" >}}

{{% /tab %}}
{{% tab header="kubectl"  %}}

{{< include "rna/rna-install-kubectl.md" >}}

{{% /tab %}}
{{% tab header="Helm"  %}}

You have [Client Credentials]({{< ref "iam/manage-client-creds" >}}) with Remote Network Agent permissions.

1. Set your `kubectl` [context](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-set-context-em-) to connect to the cluster where you want to deploy the RNA:

   ```bash
   kubectl config use-context <NAME>
   ```

1. Create the namespace for the RNA:

   ```bash
   kubectl create ns armory-rna
   ```

1. Create secrets from your Client ID and Client Secret:

   ```bash
   kubectl --namespace armory-rna create secret generic rna-client-credentials --type=string --from-literal=client-secret=<your-client-secret> --from-literal=client-id=<your-client-id>
   ```

   The examples use Kubernetes secrets to encrypt the value. You supply the encrypted values in the Helm command to install the RNA.

1. Install the RNA with default permissions and values.

   Use the `agentIdentifier` parameter to give your RNA a unique name. When you deploy your app, you specify which RNA to use, so Armory recommends creating a meaningful name that identifies the cluster.

   The encrypted values for `clientId` and `clientSecret` reference the Kubernetes secrets you generated in an earlier step.

   ```bash
   helm upgrade --install armory-rna armory/remote-network-agent \
        --set agentIdentifier=<rna-name> \
        --set 'clientId=encrypted:k8s!n:rna-client-credentials!k:client-id' \
        --set 'clientSecret=encrypted:k8s!n:rna-client-credentials!k:client-secret' \
        --namespace armory-rna
   ```

{{% /tab %}}
{{< /tabpane >}}


You can go to the [Agents page](https://console.cloud.armory.io/configuration/agents) in the CD-as-a-Service Console to verify that your RNA has been installed and is communicating with CD-as-a-Service. If you do not see the RNA, check your cluster logs to see if the RNA is running.


## {{% heading "nextSteps" %}}

* [View your connected Remote Network Agents]({{< ref "remote-network-agent/monitor-agents" >}}) to see data such as the last time CD-as-a-Service detected a heartbeat.
* [Install with advanced configuration options]({{< ref "remote-network-agent/install-advanced" >}}).
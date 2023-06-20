---
title: Install a Remote Network Agent Using the CD-as-a-Service Console
linktitle: Install - UI
description: >
  Install a CD-as-a-Service Remote Network Agent in your Kubernetes cluster.
categories: ["Guides"]
tags: [ "Networking", "Remote Network Agent", "CD-as-a-Service Setup"]
---

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





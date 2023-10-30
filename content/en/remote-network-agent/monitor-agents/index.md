---
title: View Connected Remote Network Agents in the CD-as-a-Service Console
linktitle: View RNAs
weight: 10
description: >
  View your connected Remote Network Agents using the Armory Continuous Deployment-as-a-Service Console.
categories: ["Remote Network Agent", "Features", "Guides"]
tags: ["Remote Network Agent", "UI"]
---

## How CD-as-a-Service monitors connected Remote Network Agents

The Agent Hub and the RNAs perform periodic healthchecks to ensure that the connection between the Agent Hub and your target deployment cluster is working. If the healthcheck fails, CD-as-a-Service removes the RNA from the list. When a subsequent check passes, CD-as-a-Service adds back the RNA and its cluster to the list with the **Connected At** column showing when the connection was re-established.

## View connected agents

[**Networking > Agents**](https://console.cloud.armory.io/configuration/agents)

The **Agents** page shows you the list of agents that are connected if the credentials they use have the `connect:agentHub` scope.

> Note that you may see a "No Data" message when first loading the **Agents** page even if there are successfully connected RNAs.

{{< figure src="ui-rna-status.jpg" alt="The Connected Remote Network Agents page shows connected agents and the following information: Agent Identifier, Agent Version, Connection Time when the connection was established, Last Heartbeat time, Client ID, and IP Address." >}}


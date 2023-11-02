---
title: Remote Network Agent Overview
linktitle: Overview
weight: 1
categories: ["Remote Network Agent", "Features", "Concepts"]
tags: ["Remote Network Agent"]
description: >
  Learn how Armory CD-as-a-Service uses a logicless network relay to integrate with privately networked resources such as Jenkins, Prometheus, and Kubernetes clusters.
---

## What Remote Network Agent is

Armory's Remote Network Agent (RNA) is a simple, lightweight, and reliable agent that resides within your privately networked Kubernetes cluster. RNA enables seamless communication with resources within your private network, enabling CD-as-a-Service use cases such as executing Prometheus queries or initiating Jenkins jobs from within the cluster. An RNA supports both `amd64` and `arm64` based architectures, ensuring compatibility across a range of systems.

An RNA is installed with a logical name, allowing for easy identification of a cluster. This name is then used as an `account` when defining `targets` in your deployment configuration. Armory recommends installing a single agent per Kubernetes cluster to maintain simplicity and consistency.

You need to install an RNA to get started with CD-as-a-Service or when adding a new deployment target without an existing RNA. After you have installed an RNA, there is no need for further interaction with that RNA. CD-as-a-Service takes care of the rest, seamlessly handling your deployments.

Refer to the [Architecture]({{< ref "architecture" >}}) page for more details on how the RNA fits in with the rest of the CD-as-a-Service core components.

## Remote Network Agent benefits

- Doesn't require an open port in your network to relay network requests
- Is multi-target, so you can install it into multiple networks
- Integrates with Armory's OIDC authorization server to authenticate and authorize requests to deployment targets

## Core features

### Kubernetes cluster mode

When installed into a Kubernetes cluster, an RNA can register the cluster as a deployment target from within CD-as-a-Service.

An RNA is installed with a ServiceAccount, and CD-as-a-Services uses those credentials when orchestrating Kubernetes deployments.

### Relaying traffic to private networks

When you install the RNA configured with Armory credentials into your private network, the RNA connects to Armory's Agent Hub and registers the private network with an **Agent Identifier**.

Agent Hub routes network traffic from internal, authenticated Armory services to your privately networked resources via a multi-target network relay that pipes data through encrypted gRPC tunnels to the RNA, which forwards the data to its destination.

{{< centeredImage src="rna-arch.png" alt="CD-as-a-Service Remote Network Agent Architecture Diagram" caption="Remote Network Agent securely integrates your on-prem tools with CD-as-a-Service." >}}

In Armory's secure private network, Agent Hub is an [(RFC 1929)](https://datatracker.ietf.org/doc/html/rfc1929) SOCKS5 compliant proxy [(RFC 1928)](https://www.rfc-editor.org/rfc/rfc1928.html). Agent Hub knows how to execute socks proxy requests through a bidirectional gRPC tunnel that is established by an RNA.

## {{% heading "nextSteps" %}}

* You can use the CLI, kubectl commands, or Helm to install a Remote Network Agent in your cluster. See the [Installation guide]({{< ref "remote-network-agent/install" >}}) for details.
* You can [view all of your connected RNAs]({{< ref "remote-network-agent/monitor-agents/index.md" >}}) on a single UI screen that displays data such as the last time CD-as-Service detected a heartbeat.
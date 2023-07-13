---
title: Remote Network Agent Overview
linktitle: Overview
weight: 1
categories: ["Remote Network Agent", "Features", "Concepts"]
tags: ["Remote Network Agent"]
description: >
  a logicless network relay that enables CD-as-a-Service to integrate with privately networked resources such as Jenkins, Prometheus, Kubernetes clusters, etc.
---

## Overview

Armory's Remote Network Agent (RNA) is a simple, lightweight, and reliable agent that resides within your privately networked Kubernetes cluster. It facilitates the orchestration of deployments by providing CD-as-a-Service. RNA enables seamless communication with resources within your private network, empowering CD-as-a-Service to enable use cases such as executing Prometheus queries or initiating Jenkins jobs from within the cluster. RNA supports both `amd64` and `arm64` based architectures, ensuring compatibility across a range of systems.

The RNA is installed with a logical name, allowing for easy identification of a cluster. This name is then used as an `account` when defining `targets` in your deployment configuration. Armory recommends installing a single agent per Kubernetes cluster to maintain simplicity and consistency.

To get started with CD-as-a-Service or when adding a new deployment target without an existing RNA, you need to install the RNA. Once installed, there is no need for further interaction with the RNA. CD-as-a-Service takes care of the rest, seamlessly handling your deployments.

Refer to the [Architecture]({{< ref "architecture" >}}) page for more details on how the RNA fits in with the rest of the CD-as-a-Service core components.

## Core features

### Kubernetes Cluster Mode

When installed into a Kubernetes cluster, RNA can register the cluster as a deployable target from within CD-as-a-Service.

RNA is installed with a service account and its credentials are used by CD-as-a-Service when orchestrating Kubernetes deployments.

See the [Installation Guide](/remote-network-agent/install) to get started and [Production Configuration and Use](/remote-network-agent/production-configuration-and-use) for advanced configuration, such as configuring the service account permissions or opting out of this mode.

### Relaying Traffic to Private Networks

When you install the agent configured with Armory credentials into your private network(s). The agent connects to Armory's Agent Hub registering the private network with an agent identifier.

Agent Hub can route network traffic from internal authenticated Armory services to your privately networked 
resources via a multi-target network relay that pipes data through encrypted gRPC tunnels to their destination through the remote network agent.

{{< centeredImage src="/images/cdaas/rna-arch.png" alt="CD-as-a-Service Remote Network Agent Architecture Diagram" caption="Remote Network Agent securely integrates your on-prem tools with CD-as-a-Service." >}}

In Armory's secure private network, Agent Hub is an [(RFC 1929)](https://datatracker.ietf.org/doc/html/rfc1929) SOCKS5 compliant proxy [(RFC 1928)](https://www.rfc-editor.org/rfc/rfc1928.html) that knows how to execute socks proxy requests through a bi-directional gRPC tunnel that is established by an agent.

A couple of things that make Agent Hub plus Remote Network Agent (RNA) special:
1. They don't require an open port in your network when relaying network requests.
1. They are multi-target, so you can install it into multiple networks.
1. They integrate with Armory's OIDC authorization server to authenticate and authorize requests to target agents.

---
title: Armory CD-as-a-Service Architecture
linkTitle: Architecture
weight: 10
description: >
 Learn how Armory Continuous Deployment-as-a-Service works and how its key components orchestrate continuous deployment to your Kubernetes clusters.
---



## Key components

### Command Line Interface (CLI)

The CLI is the primary means of interacting with CD-as-a-Service. You can use the CLI directly or with machine-to-machine credentials to automate deployments in your CI system.

Armory distributes the CLI as native binaries (amd64 and arm64) for Linux, Mac, and Windows as well as a Docker image.

See {{< linkWithLinkTitle "cli.md" >}} for details.

### Cloud Console (UI)

_Cloud Console_ is the browser-based UI for CD-as-a-Service. You can visually monitor and interact with your deployments on the **Deployments** screen. If you're an Admin, you can use the **Configure** screens to perform tasks such as:

 - Configuring integrations with external services such as Prometheus, New Relic, and Datadog
 - Creating machine-to-machine credentials
 - Creating secrets
 - Configuring RBAC
 - Inviting users
 - Monitoring your Kubernetes Remote Network Agents



## Kubernetes components

{{< include "cdaas-explained-how-k8s.md" >}}

### CD-as-a-Service control plane

The control plane is the set of services comprising the CD-as-a-Service platform. This control plane utilizes Remote Network Agents to talk to your networked resources such as Kubernetes APIs, Jenkins, and Prometheus, as well as external services like New Relic and Datadog.

### Remote Network Agent (RNA)

The RNA is a logicless network relay that enables CD-as-a-Service to integrate with privately networked resources such as Jenkins, Prometheus, and Kubernetes clusters. For Kubernetes, the CD-as-a-Service control plane uses an RNA's ServiceAccount credentials to automatically register the cluster the RNA is installed in as a deployment target. Once you install the RNA in your cluster, you don't need to update it beyond security updates since deployment logic is encapsulated in CD-as-a-Service's centralized control plane.

See the [Remote Network Agent]({{< ref "remote-network-agent/overview.md" >}}) overview for details.

### Agent Hub

_Agent Hub_ routes deployment commands to RNAs and caches data received from them. Agent Hub does not require direct network access to the RNAs since they connect to Agent Hub through an encrypted, long-lived gRPC HTTP2 connection. Agent Hub uses this connection to send deployment commands to the RNA for execution.

## Networking

{{< include "req-networking-k8s.md" >}}

---
title: Armory CD-as-a-Service Architecture
linkTitle: Architecture
weight: 10
description: >
 Learn how Armory Continuous Deployment-as-a-Service works and how its key components orchestrate continuous deployment to your Kubernetes clusters.
---

{{< include "cdaas-explained-how.md" >}}

## Key components

### Armory CD-as-a-Service API (Control Plane)
The control plane is the set of services comprising the Armory CD-as-a-Service APIs.

It's where the business logic for CD-as-a-Service lives, and it utilizes Remote Network Agents to talk to customer's privately networked resources such as Kubernetes APIs, Jenkins, Prometheus, etc., as well as external services, such as New Relic, Datadog, and more.

### Remote Network Agent (RNA)

The RNA is a logicless network relay that enables CD-as-a-Service to integrate with privately networked resources such as Jenkins, Prometheus, and Kubernetes clusters.

As an enhancement for Kubernetes, the Control Plane uses the agent's Service Account credentials to automatically register any cluster it's installed in as a deployable target.

Once you install the RNA in your cluster, you don't need to update it beyond security updates since deployment logic is encapsulated in Armory's centralized control plane.

See the [Remote Network Agent](/remote-network-agent/overview) section of the docs for more details.


### Command Line Interface (CLI)

The CLI is the primary means of interacting with the Armory CD-as-a-Service.

You can use the CLI directly or with machine-to-machine credentials to automate deployments in your CI system.

Armory distributes the CLI as native binaries (amd64 and arm64) for Linux, Mac, and Windows as well as a Docker image.

See the [CLI](/cli) section of the docs for more details.

### Cloud Console (UI)

_Cloud Console_ is the browser-based UI for CD-as-a-Service. You can visually monitor and interact with your deployments on the **Deployments** screen. If you're an Admin, you can use the **Configure** screens to perform tasks such as:

 - Configuring integrations with external services such as Prometheus, New Relic, and Datadog
 - Creating machine-to-machine credentials
 - Creating secrets
 - Configuring RBAC
 - Inviting users
 - Monitoring your Remote Network Agents

## Networking

{{< include "req-networking.md" >}}

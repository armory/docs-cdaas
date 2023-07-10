---
title: Armory CD-as-a-Service Architecture
linkTitle: Architecture
weight: 10
description: >
  In this high-level overview, learn how Armory Continuous Deployment-as-a-Service works and about its key components.
---

{{< include "cdaas-explained-how.md" >}}

## Key components

### Armory CD-as-a-Service API (Control Plane)
The control plane is the set of services comprising the Armory CD-as-a-Service APIs.

It's where the business logic for CD-as-a-Service lives, and it utilizes Remote Network Agents to talk to customer's privately networked resources such as Kubernetes APIs, Jenkins, Prometheus, etc., as well as external services, such as New Relic, Datadog, and more.

### Remote Network Agent (RNA)

The RNA is a logic-less network relay that enables Armory CD-as-a-Service to integrate with privately networked resources such as Jenkins, Prometheus, Kubernetes clusters, etc.

As an enhancement for Kubernetes, the Control Plane uses the agent's Service Account credentials to automatically register any cluster it's installed in as a deployable target.

Once you install the RNA in your cluster, you don't need to update it beyond security updates since deployment logic is encapsulated in Armory's centralized control plane.

See the [Remote Network Agent](/remote-network-agent/overview) section of the docs for more details.


### Command Line Interface (CLI)

The CLI is the primary means of interacting with the Armory CD-as-a-Service.

Users and Machines can use the CLI directly or use it in CI to automate deployments.

We distribute the CLI as native binaries (amd64 and arm64) for Linux, Mac, and Windows as well as docker image.

See the [CLI](/cli) section of the docs for more details.

### Cloud Console (UI)

Cloud Console is the browser-based UI for Armory CD-as-a-Service. It allows users to visually monitor and interact with deployments. Admins can use it to configure integrations with external services like New Relic and Datadog, secrets and more. 

## Networking

{{< include "req-networking.md" >}}

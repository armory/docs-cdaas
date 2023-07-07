---
title: Armory CD-as-a-Service Architecture
linkTitle: Architecture
weight: 10
---

{{< include "cdaas-explained-how.md" >}}

## Key components

### Armory CDaaS API (Control Plane)
The services that comprise the Armory CDaaS APIs.

It's where the business logic for CDaaS lives, and it utilizes Remote Network Agents to talk to customer privately networked resources such as Kubernetes APIs, Jenkins, Prometheus, etc.

The control plane also integrates with external services as well such as New Relic, Datadog, and more.

### Remote Network Agent (RNA)

The RNA is a logic-less network relay that enables Armory CD-as-a-Service to communicate with privately networked resources such as Jenkins, Prometheus, or the Kubernetes API for a cluster.

As an enhancement for Kubernetes, the agent is capable of letting the Armory CDaaS Control Plane use the agents Service Account credentials to automatically register any cluster it's installed in as a deployable target.

Once you install the RNA in your cluster, you don't need to update it beyond security updates. Deployment logic is encapsulated in Armory's centralized control plane.

See the [Remote Network Agent](/remote-network-agent/overview) section of the docs for more details.


### Command Line Interface (CLI)

The CLI is considered the primary means interacting with the Armory CDaaS Control Plane.

Users and Machines can use the CLI directly or use it in CI to automate deployments.

Our official CI integrations are actually just wrappers around the CLI.

We distribute the CLI as a native binary's (amd64 and arm64) for Linux, Mac, and Windows as well as docker image.

See the [CLI](/cli) section of the docs for more details.

### Cloud Console (UI)

Cloud Console is the browser based UI for Armory CDaaS. It allows users to visually monitor and interact with deployments. Admins can use it to configure integrations with external services like New Relic and Datadog, secrets and more. 

## Networking

{{< include "req-networking.md" >}}

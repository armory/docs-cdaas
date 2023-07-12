## How Armory CD-as-a-Service works

Armory CD-as-a-Service is a centralized control plane that utilizes flexible promotion constraints to safely rollout software/config changes across multiple clusters, environments, and/or regions.

{{< figure src="/images/cdaas/cdaas-arch.png" alt="CD-as-a-Service High-Level Architecture" height="75%" width="75%" >}}

CD-as-a-Service uses secure logic-less Remote Network Agents to access privately networked resources and Kubernetes clusters via Service Accounts, you do not need upgrade agents for new features.

Armory's Remote Network Agents connect to CD-as-a-Service to establish gRPC via HTTP/2 connections secured with TLS and OIDC client credentials. This means that you don't need to open any ports to grant the Armory CDaaS control plane access to your Kubernetes clusters or privately networked resources.

With CD-as-a-Service:
1. You build and publish your containers where and how you want, from dockerhub to a private registry that is only accessible in your network.
2. You render your kubernetes manifests how you want (Helm, Kustomize, Mustache, raw manifests, etc).
3. You define your software delivery requirements, traffic shaping, canary analysis, webhooks, manual approvals, etc, through our [declarative deployment configuration file](/deployment/overview).

Start your deployment by sending the deployment configuration file and rendered manifests to CD-as-a-Service using the [Armory CLI](/cli) or automatically with a CI integration like our [GitHub Action](/integrations/ci-systems/gh-action).

The control plane executes the deployments with constraints defined in your deployment config, converting Kubernetes deployment objects into CD-as-a-Service managed ReplicaSets, handling traffic management, scaling and more. Remote Network Agents integrate with internal tools by securely relaying network calls and using their configurable service account credentials to communicate with your clusters API.

Then simply monitor your deployment's progress through the UI or CLI.

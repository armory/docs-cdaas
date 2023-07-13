## How CD-as-a-Service works

CD-as-a-Service is a centralized control plane that utilizes flexible promotion constraints to safely deploy software and/or config changes across multiple clusters, environments, and/or regions. 

CD-as-a-Service uses secure, logicless Remote Network Agents to access privately networked resources and Kubernetes clusters via ServiceAccounts. You do not need to upgrade agents for new features since business logic is encapsulated in the CD-as-as-Service control plane.

Remote Network Agents connect to CD-as-a-Service to establish gRPC via HTTP/2 connections secured with TLS and OIDC client credentials. You don't need to open any ports to grant CD-as-a-Service access to your Kubernetes clusters or privately networked resources.

{{< figure src="/images/cdaas/how-cdaas-works.png" alt="How CD-as-a-Service Works" height="75%" width="75%" >}}

1. You create your deployment artifact and push to your artifact store.
2. You create a CD-as-a-Service deployment config file in which you define your deployment constraints and include the path to your Kubernetes manifests.
3. You start your deployment by sending the deployment config file to CD-as-a-Service using the [Armory CLI]({{< ref "cli" >}}) or automatically with a CI integration like CD-as-a-Service's [GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}). 

The CD-as-a-Service control plane executes the deployments with constraints defined in your deployment config file, converting Kubernetes deployment objects into CD-as-a-Service managed ReplicaSets, handling traffic management and scaling. Remote Network Agents integrate with internal tools by securely relaying network calls and using their configurable service account credentials to communicate with your clusters API.

Then monitor your deployment's progress through the UI or CLI.

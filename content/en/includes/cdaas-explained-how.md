## How CD-as-a-Service works

CD-as-a-Service is a centralized control plane that utilizes flexible promotion constraints to safely deploy software and/or config changes across multiple clusters, environments, and/or regions. 

CD-as-a-Service uses secure, logicless Remote Network Agents to access privately networked resources and Kubernetes clusters via ServiceAccounts. You do not need to upgrade agents for new features since business logic is encapsulated in the CD-as-as-Service control plane.

Remote Network Agents connect to CD-as-a-Service to establish gRPC via HTTP/2 connections secured with TLS and OIDC client credentials. You don't need to open any ports to grant CD-as-a-Service access to your Kubernetes clusters or privately networked resources.

{{< figure src="/media/how-cdaas-works.png" alt="How CD-as-a-Service Works" height="75%" width="75%" >}}

1. You render your Kubernets manifests using the tools you want. You build and publish your containers where and how you want, from DockerHub to a private registry on your network.
2. You create a CD-as-a-Service deployment config file in which you define your deployment: canary and/or blue/green strategy; traffic shaping; deployment constraints such as manual judgments; external automation using webhooks; and retrospective analysis. You include the path to your Kubernetes manifests in the deployment config file. CD-as-a-Service can deploy any Kubernetes object that you define in your Kubernetes manifest.
3. You start your deployment by sending the deployment config file to CD-as-a-Service using the [Armory CLI]({{< ref "cli" >}}), which you can run locally or in a Docker container. You can trigger deployments automatically from any CI system. If you're using GitHub, Armory provides a [GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}) for triggering deployments from your GitHub workflow.

The CD-as-a-Service control plane executes the deployments with constraints defined in your deployment config file, converting Kubernetes deployment objects into CD-as-a-Service managed ReplicaSets, handling traffic management and scaling. Remote Network Agents integrate with internal tools by securely relaying network calls and using their configurable ServiceAccount credentials to communicate with your clusters API.

Then monitor your deployment's progress through the UI or CLI.

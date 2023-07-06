---
title: Armory Continuous Deployment-as-a-Service
linkTitle: Documentation
type: "docs"
cascade:
- _target:
    path: "/**"
    kind: "page"
  type: "docs"
- _target:
    path: "/**"
    kind: "section"
  type: "docs"
- _target:
    path: "/**"
    kind: "section"
  type: "home"
no_list: true
---

## What is Continuous Deployment-as-a-Service?
Armory Continuous Deployment-as-a-Service (CDaaS) is a centralized control plane that allows you to deploy to multiple Kubernetes clusters using our secure agent architecture. CDaaS enables multi-environment, multi-region application rollouts with promotion constraints and advanced deployment strategies, such as canary and blue/green.

## Why Continuous Deployment-as-a-Service?
Modern software delivery requires sophisticated control of delivery speed, traffic management, and integration with external tools and verification processes. 

Software Delivery is rarely single environment. Most workflows require promotion from one environment or region to another after some set of constraints has been met, such as test execution, manual approval, CI workflows, canary analysis, etc.

CDaaS is a declarative developer experience that represents how engineers actually want their software deployed. CDaaS is easy to integrate with the tools you already use via custom web-hooks and a flexible CLI. No more need for custom scripts and duct-taped solutions.

## How does Continuous Deployment-as-a-Service work?
At a high level, CDaaS is a centralized control plane that utilizes flexible promotion constraints to safely roll-out software/config changes across multiple clusters, environments, and/or regions.

CDaaS uses secure Remote Network Agents to access privately networked resources and Kubernetes clusters via Service Accounts.

Armory's Remote Network Agents connect to CDaaS to establish gRPC via HTTP/2 connections secured with TLS and OIDC client credentials. This means that you don't need to open any ports to grant the Armory CDaaS control plane access to your Kubernetes clusters or privately networked resources.

With CDaaS:
- You build and publish your containers where and how you want, from dockerhub to a private registry that is only accessible in your network.
- You render your kubernetes manifests how you want (Helm, Kustomize, Mustache, raw manifests, etc) 
- You define your software delivery requirements, traffic shaping, canary analysis, webhooks, manual approvals, etc, through our [declarative deployment configuration file]().

Start your deployment by sending the deployment configuration file and rendered manifests to the CDaaS control plane using the Armory CLI or automatically with a CI integration like GitHub Actions.

The CDaaS control plane executes the steps and constraints defined in your deployment config, converting Kubernetes deployment objects into CDaaS-managed replicasets, handling traffic management, scaling and more. Remote network agents integrate with internal tools by securely relaying network calls and using their configurable service account credentials to communicate with your clusters API.

Then simply monitor your deployment's progress through the CDaaS UI or CLI.

## Additional Information


<!-- linkWithLinkTitle didn't render correctly inside the cardpane cards so hard-code link title and use ref -->

{{< cardpane >}}

{{% card header="Get Started" %}}
[Quickstart]({{< ref "get-started/quickstart" >}})</br>
[Deploy Your Own App]({{< ref "get-started/deploy-your-app" >}})</br>
[Install a Remote Network Agent]({{<  ref "remote-network-agent/_index.md" >}})</br>
{{% /card %}}

{{% card header="Learn About CD-as-a-Service" %}}
[Key Components]({{<  ref "architecture.md" >}})</br>
[Tenants, Users, RBAC]({{<  ref "iam/_index.md" >}})</br>

{{% /card %}}

{{% card header="Set Up Your Organization" %}}
[Add Tenants]({{<  ref "iam/manage-tenants.md" >}})</br>
[Create Roles]({{<  ref "iam/manage-rbac-roles.md" >}})</br>
[Invite Users]({{<  ref "iam/manage-users.md" >}})</br>
[Create Machine Credentials]({{< ref "iam/manage-client-creds" >}})</br>
[Create and Use Secrets]({{< ref "iam/manage-secrets" >}})</br>
[Create and Manage RBAC Roles Tutorial]({{<  ref "tutorials/tutorial-rbac-users" >}})</br>
{{% /card %}}

{{< /cardpane >}}

{{< cardpane >}}
{{% card header="Strategies" %}}
[Blue/Green Deployment]({{< ref "deployment/strategies/blue-green" >}})</br>
[Canary Analysis]({{< ref "deployment/strategies/canary" >}})</br>
[Construct Retrospective Analysis Queries]({{< ref "canary-analysis/create-canary-queries" >}})</br>
[Integrate Datadog, New Relic, Prometheus]({{< ref "canary-analysis/integrate-metrics-provider" >}})</br>
[Canary Analysis Query Reference]({{< ref "reference/canary-analysis-query.md" >}})</br>
{{% /card %}}

{{% card header="Deployment" %}}
[Create a Deployment Config File]({{< ref "reference/deployment/_index.md" >}})</br>
[Deployment Config File Reference]({{< ref "reference/deployment/config-file/_index.md" >}})</br>
[Deploy Using Credentials]({{< ref "deployment/deploy-with-creds.md" >}})</br>
[Add Context Variables]({{< ref "deployment/add-context-variable" >}})</br>

{{% /card %}}

{{% card header="Traffic Management" %}}
[Configure Istio]({{< ref "traffic-management/istio" >}})</br>
[Configure Linkerd]({{< ref "traffic-management/linkerd" >}})</br>
{{% /card %}}

{{< /cardpane >}}

{{< cardpane >}}

{{% card header="Tools" %}}
[CLI]({{< ref "cli" >}})</br>
{{% /card %}}

{{% card header="CI Systems" %}}

[Deploy Using GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}})</br>

{{% /card %}}

{{% card header="Webhooks" %}}
[Webhook-Based Approvals]({{< ref "webhooks/_index.md" >}})</br>
[Configure a Webhook]({{< ref "webhooks/webhook-approval" >}})</br>
[GitHub Webhook-Based Approval Tutorial]({{<  ref "tutorials/tutorial-webhook-github" >}})</br>
{{% /card %}}

{{< /cardpane >}}


 <style>
li #m-deployment-li {
  border-bottom: 1px solid #CECFD1; /* Set the color and thickness of the divider */
  margin-bottom: 12px; !important

}
</style>



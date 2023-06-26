---
title: Armory Continuous Deployment-as-a-Service Docs
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
description: >
  Armory CD-as-a-Service is a single control plane that enables deployment to multiple Kubernetes clusters using CD-as-a-Service's secure, one-way Kubernetes agents. These agents facilitate multi-cluster orchestration and advanced deployment strategies, such as canary and blue/green, for your apps.
---

Armory CD-as-a-Service delivers intelligent deployment-as-a-service that supports advanced deployment strategies so developers can focus on building great code rather than deploying it. By automating code deployment across all of your Kubernetes environments, Armory CD-as-a-Service removes demands on developers and reduces the risk of service disruptions due to change failures. It does this by seamlessly integrating pre-production verification tasks with advanced production deployment strategies. This mitigates risks by providing deployment flexibility while limiting blast radius, which leads to a better customer experience. Best of all, Armory CD-as-a-Service doesn’t require migrating to a new deployment platform. It easily plugs into any existing SDLC. The [Armory CD-as-a-Service (CDaaS)](https://www.armory.io/products/continuous-deployment-as-a-service/) product page contains a full list of features and pricing.

<!-- Anna in product marketing asked specifically for the "CDaaS" text in the link to the product page -->

{{< figure src="/images/cdaas/cdaas-arch.png" alt="CD-as-a-Service High-Level Architecture" height="75%" width="75%" >}}

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



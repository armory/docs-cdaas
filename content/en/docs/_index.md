---
title: Armory Continuous Deployment-as-a-Service
linkTitle: Documentation
no_list: true
description: >
  Armory CD-as-a-Service is a single control plane that enables deployment to multiple Kubernetes clusters using CD-as-a-Service's secure, one-way Kubernetes agents. These agents facilitate multi-cluster orchestration and advanced deployment strategies, such as canary and blue/green, for your apps.
---

Armory CD-as-a-Service delivers intelligent deployment-as-a-service that supports advanced deployment strategies so developers can focus on building great code rather than deploying it. By automating code deployment across all of your Kubernetes environments, Armory CD-as-a-Service removes demands on developers and reduces the risk of service disruptions due to change failures. It does this by seamlessly integrating pre-production verification tasks with advanced production deployment strategies. This mitigates risks by providing deployment flexibility while limiting blast radius, which leads to a better customer experience. Best of all, Armory CD-as-a-Service doesn’t require migrating to a new deployment platform. It easily plugs into any existing SDLC.

{{< figure src="/images/cdaas/cdaas-arch.png" alt="CD-as-a-Service High-Level Architecture" height="75%" width="75%" >}}

The [Armory CD-as-a-Service (CDaaS)](https://www.armory.io/products/continuous-deployment-as-a-service/) product page contains a full list of features and pricing.

{{< cardpane >}}

{{% card header="Get Started" %}}
[Quickstart]({{< ref "docs/setup/quickstart" >}})</br>
[Deploy Your Own App]({{< ref "docs/setup/deploy-your-app" >}})</br>
[Deploy Using GitHub Action]({{< ref "docs/setup/gh-action" >}})</br>
[Install an Agent]({{<  ref "docs/tasks/networking/install-agent.md" >}})</br>
{{% /card %}}

{{% card header="Learn About CD-as-a-Service" %}}
[Key Components]({{<  ref "docs/concepts/architecture/key-components.md" >}})</br>
[Orgs, Tenants, and Users]({{<  ref "docs/concepts/architecture/orgs-tenants.md" >}})</br>
[RBAC]({{<  ref "docs/concepts/iam/rbac.md" >}})</br>

{{% /card %}}

{{% card header="Set Up Your Organization" %}}
[Add Tenants]({{<  ref "docs/tasks/tenants/add-tenants.md" >}})</br>
[Create Roles]({{<  ref "docs/tasks/iam/create-role.md" >}})</br>
[Invite Users]({{<  ref "docs/tasks/iam/invite-users.md" >}})</br>
{{% /card %}}

{{< /cardpane >}}

{{< cardpane >}}
{{% card header="Strategies" %}}
[Blue/Green Deployment]({{< ref "docs/setup/blue-green" >}})</br>
[Canary Analysis]({{< ref "docs/setup/canary" >}})</br>
[Query Reference Guide]({{< ref "docs/reference/ref-queries.md" >}})</br>
[Integrate a Metrics Provider]({{< ref "docs/tasks/canary/add-integrations" >}})</br>
[Construct Retrospective Analysis Queries]({{< ref "docs/tasks/canary/retro-analysis" >}})</br>
{{% /card %}}



{{% card header="Deployment" %}}
[Create a Deployment Config File]({{< ref "docs/tasks/deploy/create-deploy-config" >}})</br>
[Deployment Config File Reference]({{< ref "docs/reference/ref-deployment-file.md" >}})</br>
[Deploy Using Credentials]({{< ref "docs/tasks/deploy/deploy-with-creds.md" >}})</br>
[Add Context Variables]({{< ref "docs/tasks/deploy/add-context-variable" >}})</br>
[Create and Use Secrets]({{< ref "docs/tasks/secrets/secrets-create" >}})</br>
{{% /card %}}

{{% card header="Traffic Management" %}}
[Traffic Management Using Istio]({{<  ref "docs/concepts/deployment/traffic-management/istio.md" >}})</br>
[Traffic Management Using Linkerd]({{<  ref "docs/concepts/deployment/traffic-management/smi-linkerd.md" >}})</br>
[Configure Istio]({{< ref "docs/tasks/deploy/traffic-management/istio" >}})</br>
[Configure Linkerd]({{< ref "docs/tasks/deploy/traffic-management/linkerd" >}})</br>
{{% /card %}}

{{< /cardpane >}}

{{< cardpane >}}


{{% card header="Webhooks" %}}
[Webhook-Based Approvals]({{< ref "docs/concepts/external-automation" >}})</br>
[Configure a Webhook]({{< ref "docs/tasks/webhook-approval" >}})</br>
[GitHub Webhook-Based Approval Tutorial]({{<  ref "docs/tutorials/external-automation/webhook-github" >}})</br>
{{% /card %}}

{{% card header="Tools" %}}
[CLI]({{< ref "docs/tasks/cli" >}})</br>
{{% /card %}}

{{% card header="Tutorials" %}}

[Create and Manage RBAC Roles]({{<  ref "docs/tutorials/access-management/rbac-users" >}})</br>
[Deploy a Sample App]({{<  ref "docs/tutorials/deploy-sample-app" >}})</br>


{{% /card %}}
{{< /cardpane >}}

<!-- Anna asked for this link to be here -->
The [Armory CDaaS](https://www.armory.io/products/continuous-deployment-as-a-service/) product page contains a full list of features and pricing.

<!--
## Docs organization

* [Get Started]({{< ref "docs/setup" >}}): This section contains guides to quickly get you started using core CD-as-a-Service functionality.
* [Concepts]({{< ref "docs/concepts" >}}): These pages explain aspects of CD-as-a-Service. The content is objective, containing architecture, definitions, rules, and guidelines. Rather than containing a sequence of steps, these pages link to related tasks and tutorials.
* [Guides]({{< ref "docs/tasks" >}}): Pages in the this section show you how to perform discreet tasks (single procedures) by following a short series of steps that produce an intended outcome. Task content expects a minimum level of background knowledge, and each page links to conceptual content that you should be familiar with before you begin the task.
* [Tutorials]({{< ref "docs/tutorials" >}}): A tutorial is an end-to-end example of how to do accomplish a goal and is comprised of several tasks performed in sequence. For example, a tutorial might show you how to deploy an demo app by cloning a repo, logging in using the CLI, creating a deployment file, and finally deploying the app. Like a task, a tutorial should link to content you should know and items you should complete before starting the tutorial.
* [Reference]({{< ref "docs/reference" >}}): This section contains both manually maintained and autogenerated reference material such as a breakdown of the deployment file, canary analysis queries, and CLI command options.
* [Release Notes]({{< ref "docs/release-notes" >}})
 -->

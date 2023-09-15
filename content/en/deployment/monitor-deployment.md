---
title: Monitor Deployments
linkTitle: Monitor Deployments
weight: 10
description: >
  Monitor the status of your CD-as-s-Service deployments and approve or roll back deployments. View information such as deployment status, pull request lineage, deployment triggers, and target details.
categories: ["Deployment", "Guides"]
tags: ["Monitor"]
---


## Monitor deployments using the UI

When you navigate to the **Deployments** tab of the UI, you land on the **All Deployments** page, which shows all the deployments for a specific tenant. If you don't see a deployment that you're expecting to see, verify the tenant the deployment belongs to. You can switch tenants in the top right menu by clicking on your username.

On the **All Deployments** page, you can select a specific deployment to go a page that shows a graphical representation of the target that you defined in your deployment config file. If your deployment contains only one target, clicking the deployment takes you straight to the target overview page.

## View the deployment graph

The deployment graph page gives you a general idea of the state of the deployment and what target CD-as-a-Service is currently deploying to. This graph uses nodes to represent key aspects of your deployment, gives a dynamic view of the execution of a deployment as it promotes through targets, and offers a historical view of a selected past deployment, including those that were canceled or rolled back. The connections between the nodes illustrate the promotion relationships and if applicable, current progress of an inflight deployment.

{{< figure src="/images/cdaas/deploy/multitarget-ghaTrigger.jpg" >}}

{{< figure src="/images/cdaas/deploy/multitarget-cliTrigger.jpg" >}}

## Deployment graph node types

The graph begins with a trigger node and then displays target nodes that correspond to the targets you declared in your deployment config file.

### Trigger node

A trigger node marks the moment a deployment plan is set in motion. These nodes communicate the following information:

* The system which triggered the deployment to start
* The person who initiated the trigger
* The type of trigger

Common trigger types include the following:

* pull_request
* push
* workflow_dispatch
* Armory CLI deploy

In some scenarios, you can see additional details:

* Source context for the artifacts involved in the deployment plan
* Context variables injected at runtime using [this process](https://developer.armory.io/docs/deployment/add-context-variable)

Source context is visible if the trigger source is the Armory GitHub Action, and includes the following details.

* Pull request title
* Pull request number
* Actor (person who triggered the deployment)
* Source and target branch
* Commit SHA (most recent from the PR, or that which maps to push)
* Repository
* Tag (when the trigger is a push tag)

Context variables are visible if you have configured them at the time the deployment plan is triggered.

**Examples**


{{% cardpane %}}
{{% card header="**Pull Request**" %}}

**Source**: Armory GitHub Action<br>
**Type**: `pull_request`<br>
**Context Variables**: Declared in GitHub Action<br>

{{< figure src="/images/cdaas/deploy/triggers/pr-contextvars.png" >}}

{{% /card %}}
{{% card header="**Push**" %}}

**Source**: Armory GitHub Action<br>
**Type**:  `push` (or `push` with tag)<br>
**Context Variables**: None<br>

{{< figure src="/images/cdaas/deploy/triggers/pr.png" >}}

{{% /card %}}
{{% /cardpane %}}


{{% cardpane %}}
{{% card header="**Workflow Dispatch**" %}}

**Source**: Armory GitHub Action<br>
**Type**: `workflow_dispatch`<br>
**Context Variables**:  Present, passed through CLIn<br>

{{< figure src="/images/cdaas/deploy/triggers/deploy.png" >}}

{{% /card %}}
{{% card header="**Armory CLI**" %}}

**Source**: Armory CLI<br>
**Type**: deploy<br>
**Context Variables**: none<br>

{{< figure src="/images/cdaas/deploy/triggers/cli.png" >}}

{{% /card %}}
{{% /cardpane %}}



### Target node

A target node corresponds to a target you defined in your deployment config file. Clicking on a specific target takes you to the an overview page for that single target, where you can view details and take additional action if needed.

{{< figure src="/images/cdaas/deploy/ui-fulldetails.jpg" >}}




## {{% heading "nextSteps" %}}

You can [monitor deployment status using the CLI]({{< ref "cli#monitor-deployments" >}}).
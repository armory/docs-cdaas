---
title: Monitor Deployments
linkTitle: Monitor Deployments
weight: 10
description: >
  Monitor the status of your CD-as-a-Service deployments and approve or roll back deployments. View information such as deployment status, pull request lineage, deployment triggers, and target details.
categories: ["Deployment", "Guides"]
tags: ["Monitor"]
---


## Monitor deployments using the UI

When you navigate to the **Deployments** tab of the UI, you land on the **All Deployments** page, which shows all the deployments for a specific tenant. If you don't see a deployment that you're expecting to see, verify the tenant the deployment belongs to. You can switch tenants in the top right menu by clicking on your username.

On the **All Deployments** page, you can select a specific deployment to go a page that shows a graphical representation of the target that you defined in your deployment config file. If your deployment contains only one target, clicking the deployment takes you straight to the target overview page.

## View the deployment graph

The deployment graph page gives you a general idea of the state of the deployment and what target CD-as-a-Service is currently deploying to. This graph uses nodes to represent key aspects of your deployment, gives a dynamic view of the execution of a deployment as it promotes through targets, and offers a historical view of a selected past deployment, including those that were canceled or rolled back. The connections between the nodes illustrate the promotion relationships and if applicable, current progress of an inflight deployment.

{{< figure src="multitarget-ghaTrigger.jpg" >}}

{{< figure src="multitarget-cliTrigger.jpg" >}}

## Deployment graph node types

The graph begins with a trigger node and then displays deployment target nodes that correspond to the targets you declared in your deployment config file.

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
* [Context variables injected at runtime]({{< ref "deployment/add-context-variable">}})

Source context is visible if the trigger source is the Armory GitHub Action. Source context includes the following details:

* Pull request title
* Pull request number
* Actor (person who triggered the deployment)
* Source and target branch
* Commit SHA (most recent from the PR, or that which maps to push)
* Repository
* Tag (when the trigger is a push tag)

Context variables are visible if you have configured them at the time the deployment plan is triggered.

### Target node

A target node corresponds to a target you defined in your deployment config file. Clicking on a specific target takes you to the an overview page for that single target, where you can view details and take additional action if needed.

{{< figure src="ui-fulldetails.jpg" >}}

## {{% heading "nextSteps" %}}

You can [monitor deployment status using the CLI]({{< ref "cli#monitor-deployments" >}}).

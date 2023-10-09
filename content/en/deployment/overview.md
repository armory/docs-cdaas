---
title: Deployment Overview
linktitle: Overview
weight: 1
description: >
  Learn what an Armory CD-as-a-Service deployment is and how it works - strategies (blue/green, canary) and constraints for deploying your app to your target Kubernetes clusters.
categories: ["Canary Analysis", "Features", "Concepts"]
tags: ["Deploy Strategy", "Canary", "Blue/Green", "Kubernetes"]
---

## What a deployment is

A _deployment_ encompasses the manifests, artifacts, configuration, and actions that deliver your code to remote environments. You can configure a deployment to deliver software to a single environment or multiple environments, either in sequence or in parallel depending on your [deployment configuration]({{<ref "deployment/create-deploy-config" >}}).

You define your CD-as-a-Service deployment configuration in a YAML file, which you store within your source control, enabling code-like management. You trigger deployments using the Armory CLI, either from your CI system or your workstation. Although CD-as-a-Service requires a separate deployment configuration file for each app, you can deploy multiple Kubernetes Deployment objects together as part of a single app. 

## How deployment works

{{< figure src="/images/cdaas/deploy/deploy-overview.jpg" width=80%" height="80%" >}}

* CD-as-a-Service starts a deployment with an environment, such as development, that does not depend on another environment. Then deployment progresses through the steps, conditions, and environments defined in your deployment process. 
* CD-as-a-Service deploys a new ReplicaSet every time a deployment is started. This ensures changes to resources like ConfigMap are immediately reflected and validated with your deployment strategy. 
* CD-as-a-Service automatically rolls back when:

  * There is an error deploying your Kubernetes manifests
  * Pods fail to be in a Ready state within 30 minutes
  * A webhook fails
  * You configured your retrospective analysis step to automatically rollback (available in both canary and blue/green deployments)
  * A user fails to issue a configured manual approval within a specified time frame
  * A deployment target constraint is not met

    
  You can deploy multiple Deployment objects as part of a single CD-as-a-Service deployment. When defined in a single deployment, multiple Deployment objects are rolled back together if there's an automatic or manual rollback.

> CD-as-a-Service deploys any Kubernetes manifest to your environments without the need for any special annotations in the manifest.

### How to trigger a deployment

* [Use the GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}) in your GitHub workflow.
* [Use the CLI]({{< ref "cli" >}}) with any CI system by installing the CLI natively or running it in Docker.
* [Use the plugin for Spinnaker and Armory Continuous Deployment]({{< ref "integrations/plugin-spinnaker" >}}), which enables configuring a canary or blue/green deployment that uses CD-as-a-Service.

## Define your deployment

CD-as-a-Service enables you to declaratively define your deployment configuration outcome in a YAML file. 
At its core, you only need to provide only three pieces of information:

* The target environment you want to deploy to
* The artifacts you want to have deployed
* The deployment strategy you want to use for the deployment

An example of a simple deployment may look like this:

```yaml
version: v1
kind: <the-kind-of-deployment> # current options are: Kubernetes
application: <your-app-name> # the name of your app
targets:
  <the-name-of-your-target>:
    account: <your-remote-network-agent-identifier> # the name you gave the RNA when you installed it in your prod cluster
    namespace: <your-namespace-prod> # defined in namespace-prod.yaml
    strategy: <the-name-of-the-strategy) # You will define strategy in the strategies block
manifests:
  - path: manifests/your-app.yaml # replace with the name of your app manifest
    
strategies:
  <the-strategy-name>:
    canary: # the strategy you want to use; current options are: canary, blue-green
      ... # the configuration of your chosen strategy
      
```

For deployment config file details, see {{< linkWithTitle "deployment/create-deploy-config.md" >}}.

## Elements of a deployment

### Targets

Within a deployment, you define _targets_ that are equivalent to the environments you are deploying to. For example, you may define staging, production-west, and production-east deployment targets.

You can configure each deployment target to use a [unique strategy]({{< ref "deployment/strategies/overview" >}}) that 
defines how to deploy your software and route traffic.

#### Target constraints

You can also configure your deployment targets to use constraints that prevent a deployment from beginning or completing until certain conditions are met. For example, you can configure your deployment to wait for your code to be deployed to your staging environment before promoting that code to production.

You can set `beforeDeployment` or `afterDeployment` constraints depending on your use case. 

CD-as-a-Service offers you multiple constraint options including: 

*  `dependsOn`  
   Use `dependsOn` to specify a target deployment that must successfully complete prior to starting this target's deployment.
*  `pause`  
   Use `pause` to pause a deployment for a set period of time or until an authorized user issues an approval.


**Example**

In the following example, you have two Kubernetes deployment targets: `target-1` and `target-2`.  You want deployment to
`target-2` to depend on successful deployment to `target-1`, so you add a `dependsOn` constraint to `target-2`. 
Additionally, you want to manually approve deployment to `target-2`. In the `constraints` section, you add a 
`beforeDeployment` constraint with a `pause`.

```yaml
targets:
  target-1: #a user-defined name to reference this deployment target
    account: <your-remote-network-agent-identifier> # the name you gave the RNA when you installed it in your prod cluster
    namespace: <your-namespace-prod> # defined in namespace-prod.yaml
    strategy: <the-name-of-the-strategy> # strategy will be defined below in the strategies block      
  target-2: #a user-defined name to reference this deployment target
    account: <your-remote-network-agent-identifier> # the name you gave the RNA when you installed it in your prod cluster
    namespace: <your-namespace-prod> # defined in namespace-prod.yaml
    strategy: <the-name-of-the-strategy> # strategy will be defined below in the strategies block      
    constraints:
      dependsOn: ["target-1"] #A constraint indicating that the deployment to target-1 must complete successfully prior to beginning the deployment to target-2
      beforeDeployment: # a list of constraints that must be satisfied before the deployment to the target can begin 
        - pause: # a pause constraint that will pause the execution of the deployment until an authorized user gives an approval
            untilApproved: true
```

For info on configuring constraints, see the [CD-as-a-Service reference docs]({{< ref "reference/deployment/config-file/targets#targetstargetnameconstraints" >}})

### Manifests

To deploy your software, you need tell CD-as-a-Service where to find your Kubernetes manifests.

You can deploy your manifests to all environments or specific environments using a basic configuration: 

```yaml
manifests:
  - path: manifests/your-manifest-1.yaml # this manifest will be deployed to all deployment targets defined in the targets block
  - path: manifests/your-manifest-1.yaml # this manifest will be deployed to the 'target-2' target defined in the targets block
    targets: ["target-2"]
```
             
>Manifest paths are relative to the directory from which you run the `armory deploy` command.

### Strategies 

A deployment strategy is the method by which CD-as-a-Service deploys your changes to a target. Strategies can use different techniques to allow for rapid rollback should a problem be discovered, minimizing the impact of potential issues to a small subset of users. You could also use a strategy optimized for speed. 

Armory CD-as-a-Service offers two distinct deployment strategies that each have various trade-offs.

* Canary

  A canary deployment involves releasing a new software version to a small subset of users or systems while leaving the majority on the current version. This strategy allows for real-world testing and monitoring of the new version's performance and stability. If the canary users experience positive results, the new version can be gradually rolled out to a wider audience.

* Blue/Green

  In a blue/green deployment, you maintain two identical environments, blue and green. The blue environment represents the current production version, while the green environment represents the new version that is being deployed. The new version is deployed and tested in the green environment, and once validated, CD-as-a-Service routes traffic is to green instead of blue. This strategy minimizes downtime and provides a quick rollback option if issues arise.

## {{% heading "nextSteps" %}}

* For deployment strategy details and how canary differs from blue/green, see  {{< linkWithTitle "deployment/strategies/overview.md" >}}.
* Work through the [Quickstart]({{< ref "get-started/quickstart" >}}) to deploy a sample app to a Kubernetes cluster using a blue/green deployment strategy.
* If you want to use a Kubernetes HorizontalPodAutoscaler in your deployment, [learn how CD-as-a-Service implements horizontal pod autoscaling]({{< ref "deployment/kubernetes/hpa" >}}).
* Learn how you can [monitor your deployment]({{< ref "deployment/monitor-deployment" >}}) using the UI or the CLI.

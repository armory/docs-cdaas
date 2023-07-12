---
title: Deployment Overview
linktitle: Overview
weight: 1
description: >
  Learn about deployment targets and strategies that you can use with Armory CD-as-a-Service. Deploy to Kubernetes using blue/green or canary strategies.
categories: ["Canary Analysis", "Features", "Concepts"]
tags: ["Deploy Strategy", "Canary", "Blue/Green", "Kubernetes"]
---



## What is a Deployment
Deployment is the encompassing construct that delivers your code to remote environments. A deployment
can deliver software to a single environment or multiple environments either in sequence or in parallel
depending on your [configuration]({{<ref "deployment/create-deploy-config" >}}).

## Defining a Deployment

CD as a Service allows you to decoratively define your deployment configuration using a simple YAML file declaratively. 
At its core you only need to provide only three pieces of information:

* The environment/target you want to deploy to
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

For more details, you can see our guide on how to [create your deployment configuration]({{<ref "deployment/create-deploy-config" >}}). 

## Elements of a Deployment

### Deployment Targets/Environments
Within a deployment, you can define deployment targets that are equivalent to the environments you are
deploying to.

For example, you may define staging, production-west, and production-east deployment targets.

You can configure each deployment target/environment to use a [unique strategy]({{< ref "deployment/strategies/overview" >}})
to orchestrate how your code is deployed and your traffic is routed.

#### Deployment Target Constraints
You can also configure your deployment targets to use constraints that prevent a deployment from beginning or completing until certain 
conditions are met. For example, you can configure your deployment to wait for your code to be deployed to your staging
environment before promoting that code to production.

Constraints can be set as either `beforeDeployment` or `afterDeployment` depending on your use-case. 

Information on configuring constraints can be found in the [CD-as-a-Service reference docs]({{< ref "reference/deployment/config-file/targets#targetstargetnameconstraints" >}})

CD-as-a-Service offers you multiple constraint options including: 
##### DependsOn
The dependsOn constraint allows you to specify environments that must successfully complete prior to starting this target's deployment. 


##### Manual Approvals and Pauses

The pause constraint allows you to pause a deployment for a set period of time or until an authorized user issues an approval. 

You can configure a  Kubernetes deployment target like this: 

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
### Deployment Manifests

Deploying your code with Armory CD-as-a-Service requires telling the CD-as-a-Service platform what artifacts should be 
deployed. To accomplish this 
you need to provide your Kubernetes manifests to Armory. 

Manifests can be deployed to all environments or specific environments using a simple configuration: 

```yaml
manifests:
  - path: manifests/your-manifest-1.yaml # this manifest will be deployed to all deployment targets defined in the targets block
  - path: manifests/your-manifest-1.yaml # this manifest will be deployed to the 'target-2' target defined in the targets block
    targets: ["target-2"]
```
             
Manifest paths are relative to the directory from which you run the `armory deploy` command.

### Deployment Strategies 
A deployment strategy is the method by which your changes are deployed to a target. Strategies can use different techniques
to allow for rapid rollback should a problem be discovered, minimizing the impact of potential issues to a small subset of users, 
or can be optimized for speed. 

Armory CD-as-a-Service offers two distinct deployment strategies that each have various trade-offs.

For more details as to what deployment strategies are and how they differ, please see our [overview on the subject]({{< ref "deployment/strategies/overview" >}})

#### The Canary Strategy
A canary deployment involves releasing a new software version to a small subset of users or systems while leaving 
the majority on the current version. This strategy allows for real-world testing and monitoring of the new version's performance
and stability. If the canary users experience positive results, the new version can be gradually rolled out to a wider 
audience.

For more details on Canary deployments and how to configure them, you can reference the [canary strategy documentation]({{< ref "deployment/strategies/canary" >}}) 
              
#### The Blue-Green Strategy
In a blue-green deployment, two identical environments, blue and green, are maintained. The blue 
environment represents the current production version, while the green environment represents the new version being 
deployed. The new version is deployed and tested in the green environment, and once validated, traffic is routed to green instead of blue. This strategy minimizes downtime and provides a quick rollback option if issues arise.

For more details on blue-green deployments and how to configure them, you can reference the [blue-green strategy documentation]({{< ref "deployment/strategies/blue-green" >}})
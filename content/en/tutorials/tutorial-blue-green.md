---
title: Blue/Green Deployment Tutorial
linkTitle: Blue/Green
description: >
  In this tutorial, you learn how to use a blue/green strategy to deploy an app to Kubernetes using Armory CD-as-a-Service. Use kubectl to install the Remote Network Agent. Deploy the sample app to multiple targets.
categories: ["Deployment", "Tutorials"]
tags: ["Deploy Strategy", "Blue/Green", "Kubernetes"]
draft: false
---

## Blue/Green deployment tutorial overview

A blue/green strategy shifts traffic from the running version of your software (_blue_) to a new version of your software (_green_). You can preview the green version before approving the full deployment.

This tutorial uses a single Kubernetes cluster with multiple namespaces to simulate multiple clusters. If you don't have a Kubernetes cluster, you can install one locally using [kind](https://kind.sigs.k8s.io/), which is a tool for running a lightweight Kubernetes cluster using Docker. Your cluster does not need be publicly accessible.

The sample code is in a GitHub repo branch that you clone as part of this tutorial.

## Learning objectives

1. [Install the CLI](#install-the-cli) so you can deploy from the command line.
1. [Create Client Credentials](#create-client-credentials) so you can connect your Kubernetes cluster.
1. [Connect your cluster](#connect-your-cluster) by installing a Remote Network Agent.
1. [Clone the repo branch](#clone-the-repo-branch) so you have the code for this tutorial.
1. [Explore the app v1 files](#explore-the-app-v1-deployment-files).
1. [Deploy the first version of the app](#deploy-v1) using a canary strategy.
1. [Explore the app v2 files](#explore-the-app-v2-deployment-files) to learn how to implement a blue/green strategy.
1. [Deploy the second version of the app](#deploy-v2) using a blue/green strategy.
1. [Clean up](#clean-up) installed resources.

If you have already installed the CLI and have connected a cluster, you can start at the [Clone the repo branch](#clone-the-repo-branch) step.

## {{% heading "prereq" %}}

* You have completed the CD-as-a-Service [Quickstart]({{< ref "get-started/quickstart" >}}), which guides you through deploying a sample app.  
* You are familiar with [deployment strategies]({{< ref "deployment/strategies/overview" >}}) and [blue/green]({{< ref "deployment/strategies/blue-green" >}}).
* You have a GitHub account so you can clone a repo branch.

## Install the CLI

{{< include "cli/install-cli-tabpane.md" >}}

## Create Client Credentials

Create a new set of Client Credentials for the Remote Network Agents. Name the credentials "tutorial-blue-green".

{{< include "client-creds.md" >}}

## Connect your cluster

In this step, you install an RNA in your Kubernetes cluster.

The commands do the following:

* Create an `armory-rna` namespace for the RNA.
* Create a Kubernetes secret called `rna-client-credentials` for your Client Credentials.
* Install the RNA into your cluster. The RNA's `agentIdentifier` is "sample-cluster". You use this identifier in your deployment config file.

{{< include "rna/rna-install-kubectl.md" >}}

## Clone the repo branch

Clone the [docs-cdaas-sample](https://github.com/armory/docs-cdaas-sample) repo's `tutorial-blue-green` branch so you have the code for this tutorial.

```shell
git clone --branch tutorial-blue-green --single-branch https://github.com/armory/docs-cdaas-sample.git
```

## Explore the app v1 deployment files

Now that you have cloned the branch, you can explore the files you use to deploy the first version of the `potato-facts` app, which Armory's engineers created for CD-as-a-Service demos. 

### Manifests

You can find the manifests in the `manifests` folder of the `tutorial-blue-green` directory.

* `potato-facts-v1.yaml`: Defines the Deployment object for the potato-facts app, which is a basic web app that displays facts about potatoes. 
* `potato-facts-service.yaml`: Defines the `potato-facts-svc` Service object, which sends traffic to the current version of your app. You use this in `trafficManagement.kubernetes.activeService` field in the deployment config file.

Additionally, there are two manifests for creating namespaces (`staging` and `prod`) so that this tutorial can simulate deploying to different clusters.

### Deployment config

#### Strategy

At the `tutorial-blue-green` directory root level is the deployment config file (`deploy-v1.yaml`), where you declare your deployment outcome. App v1 deployment uses a canary strategy called `rolling` to deploy 100% of the app.

```yaml
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
```

#### Deployment targets

Next, looking at the `targets` section, you see two targets: `staging` and `prod`.

```yaml
targets:
  staging:
    account: sample-cluster
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    account: sample-cluster
    namespace: potato-facts-prod
    strategy: rolling
    constraints:
      dependsOn: ["staging"]
```

`target.staging`:
* `account`: `sample-cluster` declares the Remote Network Agent associated with the `staging` environment. `sample-cluster` is the Agent Identifier used when you installed the RNA in your cluster. 
* `namespace`: `potato-facts-staging` is the namespace defined in the `manifests/staging-namespace.yaml` file. This simulates deploying to a staging cluster.
* `strategy`: `rolling` is the strategy name declared in the `strategies` top-level section.

`target.prod`:
* `account`: `sample-cluster` declares the Remote Network Agent associated with the `staging` environment. `sample-cluster` is the Agent Identifier used when you installed the RNA in your cluster. In a real world deployment, you would have a different Remote Network Agent installed in your production cluster.
* `namespace`: `potato-facts-prod` is the namespace defined in the `manifests/prod-namespace.yaml` file. This simulates deploying to a prod cluster.
* `strategy`: `rolling` is the strategy name declared in the `strategies` top-level section.
* `constraints.dependsOn`: this constraint means that the deployment to prod depends upon successful completion of deployment to staging. If staging deployment fails, CD-as-a-Service does not deploy the app to prod. The entire deployment fails.

#### App manifests

This section declares the paths to the Kubernetes manifests that CD-as-a-Service deploys. Note that the `staging-namespace.yaml` file has a target constraint, as does the `prod-namespace.yaml` file. CD-as-a-Service deploys those manifests to only the specified deployment target.

```yaml
manifests:
  - path: manifests/potato-facts-v1.yaml
  - path: manifests/potato-facts-service.yaml
  - path: manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: manifests/prod-namespace.yaml
    targets: ["prod"]
```

#### Active service

Finally, the `trafficManagement.kubernetes.activeService` field declares the app's active Service, which is defined in `manifests/potato-facts-service.yaml`. 

```yaml
trafficManagement:
  - targets: ["staging", "prod"]
    kubernetes:
      - activeService: potato-facts-svc
```

## Deploy v1

You deploy using the CLI, so be sure to log in:

```bash
armory login
```

Confirm the device code in your browser when prompted. Then return to this tutorial. 


Next, from the root of `tutorial-blue-green`, deploy the app:

```bash
armory deploy start -f deploy-v1.yaml
```

You can use the link provided by the CLI to observe your deployment's progression in the [CD-as-a-Service Console](https://console.cloud.armory.io/deployments). CD-as-a-Service deploys your resources to `staging`. Once those resources have deployed successfully, CD-as-a-Service deploys to `prod`.

## Explore the app v2 deployment files

### Manifests

* `potato-facts-v2.yaml`: Links to the second version of the app.
* `potato-facts-service.yaml`: No changes.
* `potato-facts-preview-service.yaml`: Defines a `potato-facts-preview-svc` Service object that points to the new version of your app. You can programmatically or manually observe the new version before exposing it to traffic via the `activeService`. You configure the preview Service in the `trafficManagement.kubernetes.previewService` field in the deployment config file.

### Deployment config

The `deploy-v2.yaml` config file defines a blue/green strategy called `blue-green-prod`. 

#### Strategy

```yaml
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
  blue-green-prod:
    blueGreen:
      redirectTrafficAfter:
        - pause:
            untilApproved: true
            approvalExpiration:
              duration: 10
              unit: minutes
        - exposeServices:
            services:
              - potato-facts-preview-svc
            ttl:
              duration: 10
              unit: minutes
      shutDownOldVersionAfter:
        - pause:
            duration: 15
            unit: minutes
```

* `blueGreen.redirectTrafficAfter`: This step conditions for exposing the new app version to the active Service. CD-as-a-Service executes steps in parallel.

   - `pause`: This step pauses for manual judgment before redirecting traffic to the new app version. The step has an expiration configured. If you do not approve within the specified time, the deployment fails. You can also configure the deployment to pause for a set amount of time before automatically continuing deployment.
   
   - `exposeServices`: This step creates a temporary preview service link for testing purposes. The exposed link is not secure and expires after the time in the `ttl` section. See {{< linkWithTitle "reference/deployment/config-preview-link.md" >}} for details.
   
   
   >The `redirectTrafficAfter` field also supports continuing or rolling back based on canary analysis. See the [Strategies config file reference]({{< ref "reference/deployment/config-file/strategies#strategiesstrategynamebluegreenredirecttrafficafteranalysis" >}}) for details.

* `blueGreen.shutDownOldVersionAfter`: This step defines a condition for deleting the old version of your app. If deployment is successful, CD-as-a-Service shuts down the old version after the specified time. This field supports the same `pause` steps as the `redirectTrafficAfter` field.

#### Deployment targets

The `staging` configuration is the same, but the `prod` configuration strategy has changed to `blue-green-prod`.

```yaml
targets:
  staging:
    account: sample-cluster
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    account: sample-cluster
    namespace: potato-facts-prod
    strategy: blue-green-prod
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
```

#### App manifests

This section has also changed slightly. In addition to specifying the second version of the app (`potato-facts-v2.yaml`), the section contains `potato-facts-service-preview.yaml`, which is the preview Service for the new version of the app. 

```yaml
manifests:
  - path: manifests/potato-facts-v2.yaml
  - path: manifests/potato-facts-service.yaml
  - path: manifests/potato-facts-service-preview.yaml
  - path: manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: manifests/prod-namespace.yaml
    targets: ["prod"]
```

#### Active and preview services

Finally, the `trafficManagement.kubernetes` field declares the preview Service, which is defined in `manifests/potato-facts-service-preview.yaml`. 

```yaml
trafficManagement:
  - targets: ["staging", "prod"]
    kubernetes:
      - activeService: potato-facts-svc
      - previewService: potato-facts-preview-svc
```

## Deploy v2

```bash
armory deploy start  -f deploy-v2.yaml
```

Use the link provided by the CLI to navigate to your deployment in the [CD-as-a-Service Console](https://console.cloud.armory.io/deployments). Once the `staging` deployment has completed, click **Approve** to allow the `prod` deployment to begin.

{{< figure src="/images/cdaas/tutorials/bluegreen/approve-prod-start.jpg" width=80%" height="80%" >}}


Once deployment begins, click **prod** deployment to open the details window.

{{< figure src="/images/cdaas/tutorials/bluegreen/openDetailsWindow.jpg" width=80%" height="80%" >}}

You can see that both the previous version (blue) and new version (green) are running.

In the **Next Version** section, click **View Environment** to open the preview link to the green version of the app. You can also find the link in the **Resources** section.

{{< figure src="/images/cdaas/tutorials/bluegreen/detailsWithPreviewLink.jpg" width=80%" height="80%" >}}

After you have verified the new app version, you can click **Approve & Continue** to redirect all traffic to the new version. The last step is shutting down the old version. Note that you can still roll back until the old version has been shut down.

{{< figure src="/images/cdaas/tutorials/bluegreen/deployFinish.jpg" width=80%" height="80%" >}}

## Clean up


You can clean kubectl to clean up the app resources you created:

```shell
kubectl delete ns potato-facts-staging potato-facts-prod
```

To clean up the Remote Network Agent resources you installed:

```bash
kubectl delete ns armory-rna
```


## {{% heading "nextSteps" %}}

* [Blue/Green deployment config file reference]({{< ref "reference/deployment/config-file/strategies#bluegreen-fields" >}}) 

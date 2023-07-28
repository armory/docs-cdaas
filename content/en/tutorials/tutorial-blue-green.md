---
title: Blue/Green Deployment Tutorial
linkTitle: Blue/Green
description: >
  In this tutorial, you learn how to use a blue/green strategy to deploy your app to Kubernetes using Armory CD-as-a-Service. Use kubectl to install the Remote Network Agent. Deploy the sample app to multiple targets.
categories: ["Deployment", "Tutorials"]
tags: ["Deploy Strategy", "Blue/Green", "Kubernetes"]
draft: false
---

## Blue/Green deployment tutorial overview

A blue/green strategy shifts traffic from the running version of your software (_blue_) to a new version of your software (_green_). You can preview the green version before approving the full deployment.

This tutorial is designed to use a single Kubernetes cluster with multiple namespaces to simulate multiple clusters. The sample code is in a GitHub repo branch that you clone as part of this tutorial.

If you don't have a Kubernetes cluster, you can install one locally using [kind](https://kind.sigs.k8s.io/), which is a tool for running a lightweight Kubernetes cluster using Docker. Your cluster does not need be publicly accessible.

## Learning objectives

1. Install the CLI so you can deploy from the command line.
1. Create Client Credentials so you can connect your Kubernetes cluster.
1. Connect your cluster by installing a Remote Network Agent.
1. Clone the repo branch
1. Explore the files
1. Deploy the first version of your app using a canary strategy.
1. Deploy the second version of your app using a blue/green strategy.
1. Clean up 

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

Clone the [docs-cdaas-sample](https://github.com/armory/docs-cdaas-sample) repo's `tutorial-blue-green` branch:

```shell
git clone --branch tutorial-blue-green --single-branch https://github.com/armory/docs-cdaas-sample.git
```

## Configure and deploy the first version of your app

Now that you have cloned the branch, you can deploy the first version of the `potato-facts` app, which Armory's engineers created for CD-as-a-Service demos. You can find the manifests in the `manifests` folder of the `tutorial-blue-green` directory.

* `potato-facts-v1.yaml` defines the Deployment object for the potato-facts app, which is a basic web app that displays facts about potatoes. 
* `potato-facts-service.yaml` defines the `potato-facts-svc` Service object, which is the active service for the app.

Additionally, there are two manifests for creating namespaces (`staging` and `prod`) so that this tutorial can simulate deploying to different clusters.


At the `tutorial-blue-green` directory root level is the deployment config file (`deploy-v1.yaml`), where you declare your deployment outcome.

{{< highlight yaml "linenos=table" >}}
version: v1
kind: kubernetes
application: potato-facts
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
manifests:
  - path: manifests/potato-facts-v1.yaml
  - path: manifests/potato-facts-service.yaml
  - path: manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: manifests/prod-namespace.yaml
    targets: ["prod"]
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
trafficManagement:
  kubernetes:
    - activeService: potato-facts-svc
{{< / highlight >}}






 Inside the manifests directory, save the following files:


You need to deploy a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) that sends traffic to the current version of your application. This is the `trafficManagement.kubernetes.activeService` field in the deployment config YAML configuration.

### potato-facts-service.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: potato-facts
spec:
  selector:
    app: potato-facts
  ports:
    - protocol: TCP
      port: 9001
```
(Optional) You can also create a `previewService` Kubernetes Service object so you can programmatically or manually observe the new version of your software before exposing it to traffic via the `activeService`. This is the `trafficManagement.kubernetes.previewService` field in the YAML configuration.

## Create your deployment config file

This tutorial guides you through altering the following deployment config to define and use a blue/green strategy. Copy this file and save it as `deployment.yaml` to the root of your sample app directory. [See the directory structure above](#directory-structure).

```yaml
version: v1
kind: kubernetes
application: potato-facts
targets:
  staging:
    account: my-cdaas-cluster
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    account: my-cdaas-cluster
    namespace: potato-facts-prod
    strategy: rolling
    constraints:
      dependsOn: ["staging"]
manifests:
  - path: manifests/potato-facts-v1.yaml
  - path: manifests/potato-facts-service.yaml
  - path: manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: manifests/prod-namespace.yaml
    targets: ["prod"]
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
```


## Deploy your app 

Deploy your app using the deployment config above to have baseline version of your app deployed before deploying with a blue/green strategy.

```bash
armory deploy start  -f <your-deploy-file>.yaml
```

## Add blue/green to your deployment

1. In your deployment config, go to the `strategies` section.
1. Create a new strategy named `blue-green-deploy-strat` like the following:

   ```yaml
   strategies:
    blue-green-deploy-strat:
      blueGreen:
        redirectTrafficAfter:
          - pause:
              untilApproved: true
              approvalExpiration:
                duration: 2
                unit: hours
        shutDownOldVersionAfter:
          - pause:
              untilApproved: true
              approvalExpiration:
                duration: 2
                unit: hours
   ```

   See the [Deployment File Reference]({{< ref "reference/deployment/config-file/strategies#bluegreen-fields" >}}) for an explanation of these fields.

   This strategy is configured to pause for manual judgment before redirecting traffic to your new app version as well as before shutting down your old version. You could instead choose to pause for a duration of time.

1. Change the value of `targets.<targetName>.strategy` for one or more of your deployment targets to `blue-green-deploy-strat`.

   ```yaml
   ...
   targets:
    <targetName>:
      account: <agentIdentifier>
      namespace: <namespace>
      strategy: blue-green-deploy-strat
    ...
    ```
1. At the bottom of your file, create a top-level traffic management configuration for your `activeService` and `previewService`:

   ```yaml
   ...
   trafficManagement:
     - targets: ['<targetName>']
       kubernetes:
         - activeService: myAppActiveService
           previewService: myAppPreviewService
   ...
   ```

   The values for `activeService` and `previewService` must match the names of the Kubernetes Service objects you created to route traffic to the current and preview versions of your application. See the [Deployment File Reference]({{< ref "reference/deployment/config-file/traffic-management" >}}) for an explanation of these fields.

1. Save the file

## Redeploy your app

Make a change to your app, such as the number of replicas, and redeploy it with the CLI:

```bash
armory deploy start  -f <your-deploy-file>.yaml
```

Monitor the progress and **Approve & Continue** or **Roll back** the blue/green deployment in the UI.




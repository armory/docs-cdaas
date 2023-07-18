---
title: Blue/Green Deployment Tutorial
linkTitle: Blue/Green
description: >
  In this tutorial, you learn how to use a blue/green strategy to deploy your app to Kubernetes using Armory CD-as-a-Service.
categories: ["Deployment", "Tutorials"]
tags: ["Deploy Strategy", "Blue/Green", "Kubernetes"]
---

## Learning objectives

A blue/green strategy shifts traffic from the running version of your software to a new version of your software. 

1. Install the CLI
1. Install the RNA
1. Create directory structure
1. Create Kubernetes manifests - app v1 plus active Service, app v2 plus preview Service
1. Create your deployment config file
1. Add blue/green strategy
1. Deploy first app version
1. Deploy second app version with preview Service
...
1. Clean up 

## {{% heading "prereq" %}}

* You have completed the CD-as-a-Service [Quickstart]({{< ref "get-started/quickstart" >}}), which guides you through deploying a sample app.  
* You are familiar with [deployment strategies]({{< ref "deployment/strategies/overview" >}}) and [blue/green]({{< ref "deployment/strategies/blue-green" >}}).

## Install the CLI

{{< include "install-cli.md" >}}

add windows

## Install the Remote Network Agent

If you don't have a cluster, you can install one locally using [kind](https://kind.sigs.k8s.io/), which is a tool for running a lightweight Kubernetes cluster using Docker.

{{< include "rna/rna-install-cli.md" >}}

## Create your directory structure

### Directory structure

In this guide you create a deployment config and two simple namespace configs. The namespace manifests should be in a `manifests` directory along with the Kubernetes manifests for deploying your app.

The directory structure should look like this:

```
<your-app>
├── deployment.yaml  # created as part of this guide
└── manifests
    ├── <your-app-service>.yaml
    ├── <your-app>.yaml
    ├── namespace-staging.yaml  # created as part of this guide
    └── namespace-prod.yaml     # created as part of this guide
```

## Create your Kubernetes manifests

@TODO Include manifests from  https://github.com/armory-io/cdaas-examples/tree/main/hello-armory/manifests. this has the namespace files, potato factx v1 and v2, and a potato-facts-service.  Need to add a potato-facts-service-v2 to demonstrate the previewService feature. 

You need to deploy a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) that sends traffic to the current version of your application. This is the `trafficManagement.kubernetes.activeService` field in the deployment config YAML configuration.

(Optional) You can also create a `previewService` Kubernetes Service object so you can programmatically or manually observe the new version of your software before exposing it to traffic via the `activeService`. This is the `trafficManagement.kubernetes.previewService` field in the YAML configuration.

## Create your deployment config files

@TODO Include deploy config files from https://github.com/armory-io/cdaas-examples/tree/main/hello-armory

## Add blue/green to your deployment

1. In your deploy file, go to the `strategies` section.
1. Create a new strategy named `blue-green-deploy-strat` like the following:

   ```yaml
   strategies:
    blue-green-deploy-strat:
      blueGreen:
        redirectTrafficAfter:
          - pause:
              untilApproved: true
        shutDownOldVersionAfter:
          - pause:
              untilApproved: true
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




---
title: Deploy Your Own App
linkTitle:  Deploy Your Own App
description: >
  Use a canary strategy to deploy two versions of your app to your Kubernetes cluster with Armory CD-as-a-Service. Install the CLI, connect your cluster, create a deployment config file, and deploy your app to two environments.
weight: 10
categories: ["Get Started", "Guides"]
tags: ["Deployment", "Quickstart"]
---

## Learning objectives

>If you prefer a web-based, interactive tutorial, see the CD-as-a-Service Console's [**Deploy Your Own App** tutorial](https://next.console.cloud.armory.io/getting-started).

In this guide, you create a deployment config that declares two strategies to deploy your own app to "staging" and "prod" namespaces in your Kubernetes cluster. 

1. [Sign up for CD-as-a-Service](#sign-up-for-cd-as-a-service).
1. [Install the CD-as-as-Service CLI](#install-the-cd-as-as-service-cli) on your Mac, Linux, or Windows workstation. 
1. [Connect your Kubernetes cluster](#connect-your-cluster) to CD-as-a-Service.
1. [Create the directory structure](#create-your-directory-structure) that you use for this guide.
1. [Create Namespace manifests](#create-namespace-manifests) to simulate deploying to different targets.
1. [Create a deployment config file](#create-a-deployment-config-file) and learn config file syntax.
1. [Deploy your app and monitor its progress](#deploy-your-app), observe a traffic split, and preview your v2 app from a link in the UI.
1. [Clean up](#clean-up) resources created for this guide.

## {{% heading "prereq" %}}

* You have created the Kubernetes manifests for your web app. These should include a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#writing-a-deployment-spec) and related [Service](https://kubernetes.io/docs/concepts/services-networking/service/). You use the Service name in your deployment config file's `trafficSplit` canary strategy so that CD-as-a-Service can create a preview link for your app.
* You have two versions of your app to deploy.
* You have access to a Kubernetes cluster. If you need a cluster, consider installing a local [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/) cluster.  Your cluster's API endpoint does not need to be publicly accessible to use CD-as-a-Service.

## Sign up for CD-as-a-Service

{{< include "register.md" >}}

## Install the CD-as-as-Service CLI

{{< include "cli/install-cli-tabpane.md" >}}

### Log in with the CLI

```shell
armory login
```

Confirm the device code in your browser when prompted. Then return to this guide.    

## Connect your cluster

CD-as-a-Service uses a _Remote Network Agent (RNA)_ to execute deployments in your Kubernetes cluster. The installation process uses credentials from your `~/.kube/config` file to install the RNA.

Run the following command to install an agent in your Kubernetes cluster:

```shell
armory agent create
```

You name your agent during the installation process. This guide references that name as `<your-agent-identifier>`.

## Create your directory structure

In this guide, you create a deployment config and two simple namespace configs. The namespace manifests should be in a `manifests` directory along with the Kubernetes manifests for deploying your app.

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

## Create Namespace manifests

To illustrate deploying to different targets, you deploy to two namespaces in the same cluster. In production, you would deploy to different clusters. 

Create two manifests, one for staging (`namespace-staging.yaml`) and the other for prod (`namespace-prod.yaml`). Save these to the `manifests` directory.


{{< cardpane >}}
{{< card code=true header="namespace-staging.yaml" lang="yaml">}}
apiVersion: v1
kind: Namespace
metadata:
  name: staging-ns
{{< /card >}}
{{< card code=true header="namespace-prod.yaml" lang="yaml" >}}
apiVersion: v1
kind: Namespace
metadata:
  name: prod-ns
{{< /card >}}
{{< /cardpane >}}


## Create a deployment config file

Next, create your deployment config file. 

<details><summary>Learn deployment file syntax</summary>

**`targets`**

In CD-as-a-Service, a `target` is an `(account, namespace)` pair where `account` is the agent identifier you created when you connected your cluster.

When deploying to multiple targets, you can specify dependencies between targets using the `constraints.dependsOn` field. In this guide, the `prod` deployment starts only after the `staging` deployment has completed successfully, and you have manually approved deployment to prod.

**`manifests`**

CD-as-a-Service can deploy any Kubernetes manifest. You do not need to alter your manifests or apply any special annotations.

By default, CD-as-a-Service deploys all the manifests defined in `path` to all of your `targets`. If you want to restrict the targets where a manifest should be deployed, use the `manifests.targets` field.

A `path` can be a path to a directory or to an individual file. Each file may contain one or more Kubernetes manifests.

**`strategies`**

A `strategy` defines how CD-as-a-Service deploys manifests to a target.

A `canary`-type strategy is a linear sequence of steps. The `setWeight` step defines the ratio of traffic between app versions.

</details></br>

This config defines `staging` and `prod` deployment targets in the same cluster. The targets have different Namespaces. Deployment to prod depends on successful deployment to staging. The prod deployment requires a manual approval to begin deployment and another to continue deployment after the traffic split. 

You can create deployment strategies with as many steps as you want. There are two strategies in this config:

* `rolling`: deploy 100% of the app (staging deployment)
* `trafficSplit`: 75% to the current version and 25% to the new version (prod deployment). In this section, you expose your Service in the `trafficSplit.canary.steps.exposeServices` section so CD-as-a-Service can create a preview link for you in the UI.

Save the following config as `deployment.yaml` in the root of your app directory, the same level as your `manifests` directory. Replace the bracketed values with your own.

```yaml
version: v1
kind: kubernetes
application: <your-app-name> # the name of your app
targets:
  staging:  
    account: <your-agent-identifier>
    namespace: staging-ns # defined in namespace-staging.yaml
    strategy: rolling
  prod:
    account: <your-agent-identifier>
    namespace: prod-ns # defined in namespace-prod.yaml
    strategy: trafficSplit
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
manifests:
  - path: manifests/<your-app>.yaml # replace with the name of your app manifest
  - path: manifests/<your-app-service>.yaml # replace with the name of your app service manifest
  - path: manifests/namespace-staging.yaml  
    targets: ["staging"]
  - path: manifests/namespace-prod.yaml
    targets: ["prod"]
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
  trafficSplit:
    canary:
      steps:
        - setWeight:
            weight: 25
        - exposeServices:
            services:
              - <your-app-service>
            ttl:
              duration: 30
              unit: minutes
        - pause:
            untilApproved: true
        - setWeight:
            weight: 100
```

## Deploy your app

In order to see some deployment strategies at work, you need to deploy your app twice. The first time, CD-as-a-Service skips any traffic splitting or manual approval steps in order to fully deploy a stable version to prod. The second deployment demonstrates an advanced deployment strategy, routing only 25% of traffic to your new version, while routing the rest to the stable version.

### Deploy the first version
   
1. Start the deployment from the root of your directory.

   ```bash
   armory deploy start  -f deployment.yaml
   ```

   This command starts your deployment, and then returns a **Deployment ID** and a link to your deployment details. 

1. Monitor your deployment execution.

   Use the link provided by the CLI to view your deployment in the CD-as-a-Service Console [**Deployments** screen](https://console.cloud.armory.io/deployments). 
   
   For more info on monitoring your deployment via the UI or CLI, see:
   * [Navigating the CD-as-a-Service Console]({{< ref "deployment/monitor-deployment.md#monitor-deployments-using-the-ui" >}})
   * [Monitoring with the Armory CLI]({{< ref "deployment/monitor-deployment.md#monitor-deployments-using-the-cli" >}})


1. Issue manual approval.

   Once CD-as-a-Service successfully deploys your resources to `staging`, it waits for your manual approval before deploying to `prod`. When the `staging` deployment has completed, click **Approve** to allow the `prod` deployment to begin. 

   > You must issue manual approvals using the UI. You cannot issue manual approvals using the CLI.

{{% alert title="Important" color="warning" %}}
CD-as-a-Service manages your Kubernetes deployments using ReplicaSets. During the initial deployment of your app, CD-as-a-Service deletes the underlying Kubernetes deployment object in a way that leaves behind the ReplicaSet and pods so that there is no actual downtime for your app. These are later deleted when the deployment succeeds.

If your initial deployment fails, you should [manually delete]({{< ref "troubleshooting/tools#initial-deployment-failure-orphaned-replicaset" >}}) the orphaned ReplicaSet.
{{% /alert %}}

### Deploy second version

When you deploy the second version of your app, CD-as-a-Service uses the `trafficSplit` canary strategy to route 25% of traffic to your new version. You can preview the new version from the link in the **Resources** area on the deployment details screen. 

1. Update your Kubernetes manifest to deploy a new version of your app.
1. Start the deployment from the root of your directory.

   ```bash
   armory deploy start  -f deployment.yaml
   ```

1. Monitor your deployment.

   Use the link provided by the CLI to navigate to your deployment in the [CD-as-a-Service Console](https://console.cloud.armory.io/deployments). 

1. Issue manual approval to begin prod deployment.

   Once the `staging` deployment has completed, click **Approve** to allow the `prod` deployment to begin. Once deployment begins, you can see the traffic split. CD-as-a-Service has deployed a new `ReplicaSet` with only one pod to achieve a 75/25% traffic split between app versions. 
   
1. Preview your app.

   Click the **prod** deployment to open the details window. You can find a link to your v2 app in the **Resources** section.

1. Finish deployment.

   Return to the deployment details window. Click **Approve & Continue** to finish deployment. CD-as-a-Service fully shifts traffic to the new app version and tears down the previous app version.

## Clean up

You can clean kubectl to clean up the app resources you created:

```shell
kubectl delete ns staging-ns prod-ns
```

To clean up the Remote Network Agent you installed:

```bash
kubectl delete ns armory-rna
```

## {{% heading "nextSteps" %}}

* [Learn about different deployment strategies]({{< ref "deployment/strategies/overview.md" >}})
* [Use the GitHub Action to automatically trigger deployments]({{< ref "integrations/ci-systems/gh-action.md" >}})
* [Integrate your tool chain using webhooks]({{< ref "webhooks/overview.md" >}})



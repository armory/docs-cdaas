---
title: Quickstart Kubernetes Deployment
linktitle: Quickstart Kubernetes
description: >
  Quickly get started using Armory CD-as-a-Service to deploy a sample app to Kubernetes. Install the CLI, connect your Kubernetes cluster with a single command, and deploy a sample app using a canary traffic split strategy. Learn deployment file syntax.
weight: 2
categories: ["Get Started", "Guides"]
tags: ["Deployment", "Quickstart"]
---

## Learning objectives

1. [Sign up for CD-as-a-Service](#sign-up-for-cd-as-a-service).
1. [Install the CD-as-as-Service CLI](#install-the-cd-as-as-service-cli) on your Mac, Linux, or Windows workstation.
1. [Connect your Kubernetes cluster](#connect-your-cluster) to CD-as-a-Service.
1. [Deploy Armory's sample app](#deploy-the-sample-app) `potato-facts` to two environments: `staging` and `prod`.
   * Use the CD-as-a-Service Console to approve an environment promotion.
   * Observe a traffic split between two app versions.
1. [Learn CD-as-a-Service deployment file syntax](#learn-deployment-file-syntax).
1. [Remove](#clean-up) the resources you created.

## {{% heading "prereq" %}}

* You are familiar with CD-as-a-Service's [key components]({{< ref "architecture.md" >}}).
* You have access to a Kubernetes cluster. If you need a cluster, consider installing a local [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/) or [Minikube](https://minikube.sigs.k8s.io/docs/start/) cluster. Your cluster's API endpoint does not need to be publicly accessible to use CD-as-a-Service.

>If you do not have a Kubernetes cluster and still wish to tour CD-as-a-Service, you can [sign up ](https://go.armory.io/signup/) and select **Self-Guided Browser Tour**. CD-as-a-Service creates a short-lived Kubernetes cluster for you and then guides you through deploying the sample app.

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

CD-as-a-Service uses an agent to execute deployments in your Kubernetes cluster. The installation process uses credentials from your `~/.kube/config` file to install the CD-as-a-Service agent.

Run the following command to install an agent in your Kubernetes cluster:

```shell
armory agent create
```

You name your agent during the installation process. This guide references that name as `<my-agent-identifier>`.

## Deploy the sample app

Armory's `potato-facts` sample app is a basic web app. The UI polls the API backend for facts about potatoes and renders them for users. 

### First deployment

Your first deployment deploys the following resources into your Kubernetes cluster:

- Two namespaces: `potato-facts-staging` and `potato-facts-prod`
- In each namespace: the `potato-facts` app and a Kubernetes `Service`

**Deploy**

Run the following command:

```shell
armory deploy start -f https://go.armory.io/hello-armory-first-deployment --account <my-agent-identifier>
```

Congratulations, you've just started your first deployment with CD-as-a-Service!

You can use the link provided by the CLI to observe your deployment's progression in the [CD-as-a-Service Console](https://console.cloud.armory.io/deployments). CD-as-a-Service deploys your resources to `staging`. Once those resources have deployed successfully, CD-as-a-Service deploys to `prod`.

### Second deployment

CD-as-a-Service is designed to help you build safety into your app deployment process. It does so by giving you declarative levers to control the scope of your deployment.

CD-as-a-Service has four kinds of constraints that you can use to control your deployment:

- Manual Approvals
- Timed Pauses
- [External Automation (Webhooks)]({{< ref "webhooks/overview.md" >}})
- [Automated Canary Analysis]({{< ref "deployment/strategies/canary" >}})

You can use these constraints _between_ environments and _within_ environments:

- During your next deployment, you need to issue a manual approval between `staging` and `prod`.
- Within the `prod` deployment, CD-as-a-Service creates a traffic split between your app versions: 75% goes to the old version and 25% goes to the new version. CD-as-a-Service waits for your approval before continuing the deployment.

**Deploy**

Start your second deployment:

```shell
armory deploy start -f https://go.armory.io/hello-armory-second-deployment --account <my-agent-identifier>
```

Use the link provided by the CLI to navigate to your deployment in the [CD-as-a-Service Console](https://console.cloud.armory.io/deployments). Once the `staging` deployment has completed, click **Approve** to allow the `prod` deployment to begin.

{{< figure src="clickApprove.jpg" width=80%" height="80%" >}}

Once deployment begins, you can see the traffic split. CD-as-a-Service has deployed a new `ReplicaSet` with only one pod to achieve a 75/25% traffic split between app versions. Click the **prod** deployment to open the details window.

{{< figure src="openTrafficSplitDetails.jpg"  width=80%" height="80%"  >}}

Click on `potato-facts` in the **Resources** section to open a preview of `potato-facts`.

{{< figure src="trafficSplitDetailsWindow.jpg" width=80%" height="80%"  >}}

The app's graph plots the ratio of facts served by a given Kubernetes `ReplicaSet`. The ratio of facts served by `ReplicaSet` backends in the graph should roughly match the 75/25% split.

{{< figure src="potatoFactsTrafficSplit.jpg"  width=80%" height="80%"  >}}

Return to the deployment details window. Click **Approve & Continue** to finish deployment. CD-as-a-Service fully shifts traffic to the new app version and tears down the previous app version.

{{< figure src="deployFinishedDetails.jpg"  width=80%" height="80%"  >}}

## Learn deployment file syntax

Now that you've used CD-as-a-Service to deploy to two environments, it's time to break down the sample app's deployment file. You can find full specification details in the [Deployment Config File Reference]({{< ref "reference/deployment/config-file" >}}).

**`targets`**

In CD-as-a-Service, a `target` is an `(account, namespace)` pair where `account` is the agent identifier you created when you connected your cluster.

When deploying to multiple targets, you can specify dependencies between targets using the `constraints.dependsOn` field. In this guide, the `prod` deployment starts only after the `staging` deployment has completed successfully, and you have manually approved deployment to prod.

```yaml
targets:
  staging:
    # Account is optional when passed as a CLI flag (--account).
    # It's also required if you'd like to deploy to multiple Kubernetes clusters.
    # account: <my-agent-identifier>
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    namespace: potato-facts-prod
    strategy: trafficSplit
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
```

**`manifests`**

CD-as-a-Service can deploy any Kubernetes manifest. You do not need to alter your manifests or apply any special annotations.

By default, CD-as-a-Service deploys all the manifests defined in `path` to all of your `targets`. If you want to restrict the targets where a manifest should be deployed, use the `manifests.targets` field.

A `path` can be a path to a directory or to an individual file. Each file may contain one or more Kubernetes manifests.

```yaml
manifests:
  - path: ./manifests/potato-facts-v1.yaml
  - path: ./manifests/potato-facts-service.yaml
  - path: ./manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: ./manifests/prod-namespace.yaml
    targets: ["prod"]
```

**`strategies`**

A `strategy` defines how CD-as-a-Service deploys manifests to a target.

A `canary`-type strategy is a linear sequence of steps. The `setWeight` step defines the ratio of traffic between app versions.

```yaml
strategies:
  rolling:
    canary:
      steps:
        # This strategy immediately flips all traffic to the new app version.
        - setWeight:
            weight: 100
  trafficSplit:
    canary:
      steps:
        - setWeight:
            weight: 25
        - exposeServices:
            services:
              - potato-facts
            ttl:
              duration: 30
              unit: minutes
        - pause:
            untilApproved: true
        - setWeight:
            weight: 100
```


CD-as-a-Service integrates with service meshes like [Istio]({{< ref "traffic-management/istio" >}}) and [Linkerd]({{< ref "traffic-management/linkerd" >}}), but you do not need to use a service mesh to use a CD-as-a-Service `canary` strategy.

CD-as-a-Service also supports a [blue/green]({{< ref "deployment/strategies/blue-green" >}}) deployment strategy.

## Clean up

You can use `kubectl` to clean up the app resources you created:

```shell
kubectl delete ns potato-facts-staging potato-facts-prod
```

To clean up the Remote Network Agent you installed:

```bash
kubectl delete ns armory-rna
```

You may want to keep the installed Remote Network Agent to use when working through other guides.

## {{% heading "nextSteps" %}}

* View the [manifests and deployment config files](https://github.com/armory-io/cdaas-examples/tree/main/hello-armory) for this quickstart. 
* If you want to verify the `potato-facts` web app code for security reasons, you can view the app code in the [public repo](https://github.com/armory-io/potato-facts-go). This repo only contains the app code. It **does not** contain any deployment config files or GitHub Actions for this quickstart. 
* {{< linkWithTitle "get-started/deploy-your-app.md" >}}
* {{< linkWithTitle "integrations/ci-systems/gh-action.md" >}}
* {{< linkWithTitle "deployment/strategies/blue-green.md" >}}
* {{< linkWithTitle "deployment/strategies/canary.md" >}}

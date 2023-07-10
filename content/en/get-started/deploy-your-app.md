---
title: Deploy Your Own App
linkTitle:  Deploy Your Own App
weight: 10
---

## Learning objectives

1. [Create a deployment config file](#create-a-deployment-config-file)
2. [Deploy your app](#deploy-your-app)
3. [Monitor your deployment](#monitor-your-deployment)


## {{% heading "prereq" %}}

* You have the [Armory CLI installed]({{< ref "cli.md" >}}).
* You have an [Armory RNA installed]({{< ref "remote-network-agent/_index.md" >}}) in your cluster.
* You have created the Kubernetes manifests for your web app.
* You have two versions of your app to deploy.


### Directory structure

In this guide you will create a deployment config and two simple namespace configs. The namespace manifests should be in a `manifests` directory along with the Kubernetes manifests for deploying your app.

The directory structure should look like this:

```
<your-app>
├── deployment.yaml
└── manifests
    ├── <your-app-service>.yaml
    ├── <your-app>.yaml
    ├── namespace-staging.yaml
    └── namespace-prod.yaml
```



## 1. Create a deployment config file

First create two manifests for the staging and prod namespaces. These are where you'll deploy your app and this also showcases the ability to deploy manifests to specific targets. Save these to the `manifests` directory.


{{< cardpane >}}
{{< card code=true header="namespace-staging.yaml" lang="yaml">}}
apiVersion: v1
kind: Namespace
metadata:
  name: <your-staging-namespace>
{{< /card >}}
{{< card code=true header="namespace-prod.yaml" lang="yaml" >}}
apiVersion: v1
kind: Namespace
metadata:
  name: <your-prod-namespace>
{{< /card >}}
{{< /cardpane >}}




Next, save the following config as `deployment.yaml` to the root of your app directory, next to the `manifests` directory. Replace the bracketed values with your own.


```yaml
version: v1
kind: kubernetes
application: <your-app-name> # the name of your app
targets:
  staging:  
    account: <your-remote-network-agent-identifier> # the name you gave the RNA when you installed it in your staging cluster
    namespace: <your-namespace-staging> # defined in namespace-staging.yaml
    strategy: rolling
  prod:
    account: <your-remote-network-agent-identifier> # the name you gave the RNA when you installed it in your prod cluster
    namespace: <your-namespace-prod> # defined in namespace-prod.yaml
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


In your CDaaS config, you can create deployment strategies with as many steps as you want. In this example, the deployment config defines the following strategies:

* `rolling`: deploy 100% of the app (staging deployment)
* `trafficSplit`: 75% to the current version and 25% to the new version (prod deployment)

The prod deployment requires a manual approval to begin deployment and another to continue deployment after the traffic split.

## 2. Deploy your app
In order to see some deployment strategies at work, you'll need to deploy your app twice. The first time, CDaaS will skip any traffic splitting or manual approval steps in order to have a stable version fully deployed. The second deploy will demonstrate an advanced deployment strategy, routing only 25% of traffic to your new version, while routing the rest to the stable version.

### Deploy the first version

1. Log in using the CLI.

   ```bash
   armory login
   ```

   The CLI returns a `Device Code` and opens your default browser.  Confirm the code in your browser to complete the login process.

2. Start the deployment from the root of your directory.

   ```bash
   armory deploy start  -f deployment.yaml
   ```

   This command starts your deployment, then returns a **Deployment ID** and a link to your deployment details. 

3. Monitor your deployment execution.

   Use the link provided by the CLI to view your deployment in the [CD-as-a-Service Console](https://console.cloud.armory.io/deployments). 

4. Issue manual approval.

   Once CD-as-a-Service successfully deploys your resources to `staging`, it waits for your manual approval before deploying to `prod`. When the `staging` deployment has completed, click **Approve** to allow the `prod` deployment to begin. 
   > You must issue manual approvals using the UI. You cannot issue manual approvals using the CLI.

  Because this is the first time deploying your app, CD-as-a-Service deploys 100% to your prod environment, skipping the defined `trafficSplit` strategy. CD-as-a-Service uses the `trafficSplit` when deploying subsequent versions of your app.

{{% alert title="Important" color="warning" %}}
CDaaS manages your Kubernetes deployments using ReplicaSets. During the initial deployment of your app, CDaaS deletes the underlying Kubernetes deployment object in a way that leaves behind the ReplicaSet and pods so that there is no actual downtime for your app. These are later deleted when the deployment succeeds.

If your initial deployment fails, you should [manually delete]({{< ref "troubleshooting/tools#initial-deployment-failure-orphaned-replicaset" >}}) the orphaned ReplicaSet.
{{% /alert %}}

### Deploy second version

1. Update your Kubernetes manifest to deploy a new version of your app. 
2. Start the deployment from the root of your directory.

   ```bash
   armory deploy start  -f deployment.yaml
   ```

3. Monitor your deployment.

4. Issue manual approvals.

   Approve the deployment to prod again and this time, observe the traffic split on the deployment details page and preview your web app deployment. Issue your manual approval to finish deployment.

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "deployment/strategies/overview.md" >}}
* {{< linkWithTitle "webhooks/overview.md" >}}
* {{< linkWithTitle "integrations/ci-systems/gh-action.md" >}}



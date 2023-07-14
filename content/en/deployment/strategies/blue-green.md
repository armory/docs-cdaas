---
title: "Blue/Green Deployment Strategy"
linkTitle: "Blue/Green"
weight: 5
description: >
  A blue/green strategy shifts traffic from the running version of your app to a new version of your app based on conditions you set. This guide walks you through how to deploy your app to Kubernetes using a blue/green strategy. 
categories: ["Deployment", "Guides"]
tags: ["Deploy Strategy", "Blue/Green", "Kubernetes"]
---

## Blue/Green deployment overview

A blue/green strategy shifts traffic from the running version of your software to a new version of your software based on conditions you set. The Armory CD-as-a-Service blue/green strategy follows these steps:

1. CD-as-a-Service deploys a new version of your software without exposing it to external traffic.
1. CD-as-a-Service executes one or more user-defined steps in parallel. These steps are pre-conditions for exposing the new version of your software to traffic. For example, you may want to run automated metric analysis or wait for manual approval.
1. After all pre-conditions complete successfully, CD-as-a-Service redirects all traffic to the new software version. At this stage of the deployment, the old version of your software is still running but is not receiving external traffic.
1. Next, CD-as-a-Service executes one or more user-defined steps in parallel. These steps are pre-conditions for tearing down the old version of your software. For example, you may want to pause for an hour or wait for an additional automated metric analysis.
1. After all pre-conditions complete successfully, CD-as-a-Service tears down the old version of your software.

## {{% heading "prereq" %}}

For this guide, you need the following:

* The [Armory CLI]({{< ref "cli.md" >}}) installed
  <details><summary>Show me how</summary>
    {{< include "install-cli.md" >}}
  </details>
* A [Remote Network Agent]({{< ref "remote-network-agent/overview.md" >}}) (RNA) installed in the cluster where you want to deploy your app
  <details><summary>Show me how</summary>
    {{< include "rna/rna-install-cli.md" >}}
  </details>


## Configure an active service
You need to have a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) that sends traffic to the current version of your application. This is the `trafficManagement.kubernetes.activeService` field in the YAML configuration. This can be pre-existing in your cluster or can be deployed along with your deployment config file.

If you don't have one in your cluster, here is an example:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: <your-app-service>
  labels:
    app: <your-app-name>
spec:
  selector:
    app: <your-app-name>
  ports:
    - name: http
      port: 80
      targetPort: 9001
      protocol: TCP
```

Save the file as `<your-app-service>.yaml` and run `kubectl -n <target-namespace> -f <your-app-service>.yaml` to deploy the service.

## Define a blue/green deployment strategy

Create a deployment config file with the following contents or amend an existing one with the content in `strategies` and `trafficManagement`:

```yaml
version: v1
kind: kubernetes
application: <your-app-name> # the name of your app
targets:
  staging:  
    account: <your-remote-network-agent-identifier> # the name of the RNA you installed in your cluster
    namespace: <your-namespace> # the namespace you want to deploy to
    strategy: <name-for-your-blue-green-strategy>
manifests:
  - path: manifests/<your-app>.yaml # the path to and name of your app manifest
strategies:
  <name-for-your-blue-green-strategy>:
    blueGreen:
      redirectTrafficAfter:
        - pause:
            untilApproved: true
      shutDownOldVersionAfter:
        - pause:
            untilApproved: true
trafficManagement:
    kubernetes:
      - activeService: <your-app-service> # the name of your app's Kubernetes service
```


   See the [Deployment File Reference]({{< ref "reference/deployment/config-file/strategies#bluegreen-fields" >}}) for an explanation of the fields under the <code>blueGreen</code> strategies block.

The `redirectTrafficAfter` steps are conditions for exposing the new version of your app to the activeService. You can add multiple steps here and they're all executed in parallel. After all the steps complete successfully, CD-as-a-Service exposes the new version to the activeService.

Set the conditions for shutting down the old version of your app under `shutDownOldVersionAfter`. These steps are also executed in parallel. After all the steps complete successfully, CD-as-a-Service deletes the old version.

   The value for `activeService` must match the name of the Kubernetes Service object you created to route traffic to the current version of your application. See the [Deployment File Reference]({{< ref "reference/deployment/config-file/traffic-management" >}}) for an explanation of these fields.


## Redeploy your app

Make a change to your app, such as the number of replicas, and redeploy it with the CLI:

```bash
armory deploy start  -f <your-deploy-file>.yaml
```

Monitor the progress and **Approve & Continue** or **Roll back** the blue/green deployment in the UI.



## Optional configuration

### Preview service
You can also create a `previewService` Kubernetes Service object so you can programmatically or manually observe the new version of your software before exposing it to traffic via the `activeService`. This is the `trafficManagement.kubernetes.previewService` field in the YAML configuration.

In order to have a separate preview service serving traffic to only your new version, make sure to deploy your new version under a new app name.

Then create a new service that exposes traffic internally only, putting your new app name in the appropriate fields below:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <your-new-app-service>
  labels:
    app: <your-new-app-name>
spec:
  selector:
    app: <your-new-app-name>
  ports:
    - name: gate-tcp
      port: 80
      protocol: TCP
      targetPort: 9001
```

Add the preview service next to the active service in the `trafficManagement` block:

```yaml
...
trafficManagement:
    kubernetes:
      - activeService: <your-app-service>
        previewService: <your-new-app-service>  # optional
```


### Environment-specific traffic management
You can apply the traffic management settings to specific environments with the `targets` field.

```yaml
...
trafficManagement:
  - targets: ['staging']  # optionally apply this to only one environment, if you have multiple environments
    kubernetes:
      - activeService: <your-app-service>
```
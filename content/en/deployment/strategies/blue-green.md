---
title: "Blue/Green Deployment Strategy"
linkTitle: "Blue/Green"
weight: 5
description: >
  A blue/green strategy shifts traffic from the running version of your app to a new version of your app based on conditions you set. This guide walks you through how to deploy your app to Kubernetes using a blue/green strategy. 
categories: ["Deployment", "Guides"]
tags: ["Deploy Strategy", "Blue/Green", "Kubernetes"]
---

## How CD-as-a-Service implements Blue/Green

A blue/green strategy shifts traffic from the running version of your software to a new version of your software based on conditions you set. The Armory CD-as-a-Service blue/green strategy follows these steps:

1. CD-as-a-Service deploys a new version of your software without exposing it to external traffic.
1. CD-as-a-Service executes one or more user-defined steps in parallel. These steps are pre-conditions for exposing the new version of your software to traffic. For example, you may want to run automated metric analysis or wait for manual approval.
1. After all pre-conditions complete successfully, CD-as-a-Service redirects all traffic to the new software version. At this stage of the deployment, the old version of your software is still running but is not receiving external traffic.
1. Next, CD-as-a-Service executes one or more user-defined steps in parallel. These steps are pre-conditions for tearing down the old version of your software. For example, you may want to pause for an hour or wait for an additional automated metric analysis.
1. After all pre-conditions complete successfully, CD-as-a-Service tears down the old version of your software.

## {{% heading "prereq" %}}

For a blue/green strategy, you need your Kubernetes service and your deployment object.

* **Kubernetes Service object**

  A [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) that sends traffic to the current version of your application. This can be pre-existing in your cluster or can be deployed along with your deployment config file.

  <details><summary>Show me an example service to apply.</summary>

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
  </details>

<br>

* **Deployment object**
Your app!



## Define a blue/green deployment strategy

When you define your blue/green strategy, you need the following required fields:

// TODO(Aimee): bullet formatting pleeeease
* `redirectTrafficAfter`: The `redirectTrafficAfter` steps are conditions for exposing the new version of your app to the activeService. You can add multiple steps here and they're all executed in parallel. After all the steps complete successfully, CD-as-a-Service exposes the new version to the activeService.

* Set the conditions for shutting down the old version of your app under `shutDownOldVersionAfter`. These steps are also executed in parallel. After all the steps complete successfully, CD-as-a-Service deletes the old version.

* The value for `activeService` must match the name of the Kubernetes Service object you created to route traffic to the current version of your application. See the [Deployment File Reference]({{< ref "reference/deployment/config-file/traffic-management" >}}) for an explanation of these fields.

The basic format for your deployment config file is:

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
        - pause:        # an example step, see below for all options
            untilApproved: true   
      shutDownOldVersionAfter:
        - <choose your steps>
trafficManagement:
    kubernetes:
      - activeService: <your-app-service> # the name of your app's Kubernetes service
```


See the [Deployment File Reference]({{< ref "reference/deployment/config-file/strategies#bluegreen-fields" >}}) for an explanation of all the fields under the <code>blueGreen</code> strategies block.



## Optional configuration

### Preview service
With Blue/Green strategy, you can programmatically or manually observe the new version of your software before exposing it to traffic. You can accomplish this by defining a previewService in the deployment configuration in the trafficManagement block.

The `previewService` is the name of a Kubernetes Service object, that points to the deployment object. This service needs to exist on your cluster, or can be deployed alongside your application with CD-as-a-Service. The previewService must be a different service than the one used for activeService.
When creating the Replicaset for the new version, CD-as-a-Service will inject the labels into preview service, so that the preview Service points to the new version of application.
<details><summary>Show me an example preview service.</summary>

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
</details>

<br>

Add the preview service next to the active service in the `trafficManagement` block:

```yaml
...
trafficManagement:
    kubernetes:
      - activeService: <your-app-service>
        previewService: <your-new-app-service>  # optional
```


### Target-specific traffic management
You can apply the traffic management settings to specific targets with the `targets` field.

```yaml
...
trafficManagement:
  - targets: ['staging']  # optionally apply this to only one target, if you have multiple target
    kubernetes:
      - activeService: <your-app-service>
```

### Canary Analysis
### Webhooks
### Pause
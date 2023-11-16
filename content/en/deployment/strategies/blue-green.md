---
title: "Configure a Blue/Green Deployment Strategy"
linkTitle: "Blue/Green"
weight: 5
description: >
  Learn how to configure a blue/green strategy in Armory CD-as-a-Service. A blue/green strategy shifts traffic from the running version of your app to a new version of your app based on conditions you set. 
categories: ["Deployment", "Guides"]
tags: ["Deploy Strategy", "Blue/Green", "Kubernetes"]
---

**Kubernetes Only**

## What a blue/green strategy does

A blue/green strategy shifts traffic from the running version of your software (_blue_) to a new version of your software (_green_) based on conditions you set. You specify conditions that must be met prior to routing traffic to the new version and before shutting down the old version. See the [Strategies Overview]({{< ref "deployment/strategies/overview" >}}) for details on the advantages of using a blue/green deployment strategy.

## How CD-as-a-Service implements blue/green

1. CD-as-a-Service deploys a new version of your software without exposing it to external traffic.
1. CD-as-a-Service executes one or more user-defined steps in parallel. These steps are pre-conditions for exposing the new version of your software to traffic. For example, you may want to run automated metric analysis or wait for manual approval.
1. After all pre-conditions complete successfully, CD-as-a-Service redirects all traffic to the new software version. At this stage of the deployment, the old version of your software is still running but is not receiving external traffic.
1. Next, CD-as-a-Service executes one or more user-defined steps in parallel. These steps are pre-conditions for tearing down the old version of your software. For example, you may want to pause for an hour or wait for an additional automated metric analysis.
1. After all pre-conditions complete successfully, CD-as-a-Service tears down the old version of your software.

## {{% heading "prereq" %}}

Before configuring a blue/green strategy in your [deployment]({{< ref "deployment/overview" >}}), you should have the following:

* Kubernetes Deployment object
  
  Your [Kubernetes Deployment object](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) tells Kubernetes how to create and update your app. 

* Kubernetes Service object

  Your [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) sends traffic to the current green version of your app. This active Service can already exist in your cluster, or you can deploy it along with your app. You declare the name of this service in the `trafficManagement.kubernetes.activeService` field in the deployment config file.

  <details><summary>Show me an example Service object</summary>

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
  
## Define a blue/green deployment strategy

1. [Declare your strategy](#declare-your-strategy).
1. [Configure your active Service](#configure-your-active-service).
1. [Add your strategy to your deployment target](#add-your-strategy-to-your-deployment-target).

### Declare your strategy

You define your blue/green strategy in the root-level `strategies` section of your CD-as-a-Service deployment config file.  The strategy has two required fields:


```yaml
strategies:
  <name-for-your-blue-green-strategy>:
    blueGreen:
      redirectTrafficAfter:
      shutDownOldVersionAfter:
```

* `redirectTrafficAfter`: Define the conditions for exposing the new blue version of your app to the active Service. You can add multiple steps, which are all executed in parallel. After all the steps complete successfully, CD-as-a-Service exposes the new version to the active Service.
  * `pause`: Pause until a condition is true. You can pause for a set amount of time or until you approve a manual judgment in the UI. When you configure a manual judgment, it's a good idea to include `approvalExpiration` so your deployment cancels if nobody issues a manual approval.
    
    {{< cardpane >}}
    {{< card code=true header="Time" lang="yaml" >}}
    redirectTrafficAfter:
      - pause:
          duration: <integer>
          unit: <seconds|minutes|hours>
    {{< /card >}}
    {{< card code=true header="Manual Judgment" lang="yaml" >}}
    redirectTrafficAfter:
      - pause:
          untilApproved: true
          approvalExpiration:
            duration: <integer>
            unit: <seconds|minutes|hours>
    {{< /card >}}
    {{< /cardpane >}}

* `shutDownOldVersionAfter`: Set the conditions for shutting down the old version of your app. You can add multiple steps, which are all executed in parallel. After all the steps complete successfully, CD-as-a-Services shuts down the old version of your app. 
  * `pause`: Pause until a condition is true. You have the same config choices here as you do in the `redirectTrafficAfter.pause` section.

### Configure your active Service

You also need to configure your active Service in a root-level `trafficManagement` section so CD-as-a-Service knows where to route traffic.

```yaml
trafficManagement:
    kubernetes:
      - activeService: <your-app-service>
```

* `activeService`: This is the name of the Kubernetes Service object you created to route traffic to the current version of your app. 


### Add your strategy to your deployment target

After you configure your strategy, you need to add it to your deployment targets:

```yaml
targets:
  staging:  
    ...
    strategy: <name-for-your-blue-green-strategy>
  prod:  
    ...
    strategy: <name-for-your-blue-green-strategy>
```

You can define different blue/green strategies for different deployment targets.


## Example deployment config file

In this basic example, you deploy an app called "sample-app" with a Service called "sample-app-svc" to two deployment targets.

```yaml
version: v1
kind: kubernetes
application: sample-app
targets:
  staging:  
    account: staging-cluster
    namespace: staging-ns
    strategy: sample-app-blue-green
  prod:  
    account: prod-cluster
    namespace: prod-ns
    strategy: sample-app-blue-green
manifests:
  - path: manifests/<your-app>.yaml # the path to and name of your app manifest
strategies:
  sample-app-blue-green:
    blueGreen:
      redirectTrafficAfter:
        - pause: 
            duration: 2
            unit: hours   
      shutDownOldVersionAfter:
        - pause:
            untilApproved: true
            approvalDuration:
              duration: 8
              unit: hours
trafficManagement:
    kubernetes:
      - activeService: sample-app-svc
```

<details><summary>Show me the app manifest</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  annotations: 
    "app": "sample-app"
spec:
  revisionHistoryLimit: 1
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2
      maxUnavailable: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
      annotations: 
        "app": "sample-app"
    spec:
      containers:
      - image:  demoimages/bluegreen:v3 #v5, v4, v3
        imagePullPolicy: Always
        name: sample-app
        resources:
          limits:
            cpu: "100m" # this is to ensure the above busy wait cannot DOS a low CPU cluster.
            memory: "70Mi"
          requests:
            cpu: "10m" # this is to ensure the above busy wait cannot DOS a low CPU cluster.
            memory: "70Mi"
        #ports:
        #  - containerPort: 8086
      restartPolicy: Always
---

apiVersion: v1
kind: Service
metadata:
  name: sample-app-svc
  labels:
    app: sample-app
  annotations:
    linkerd.io/inject: enabled
spec:
  selector:
    app: sample-app
  ports:
    - name: http
      port: 80
      targetPort: 8000
      protocol: TCP
```
</details>

## Optional configuration

### Preview service

You can programmatically or manually observe the new version of your software before exposing it to traffic. You can accomplish this by defining a preview Service in the`trafficManagement.kubernetes` block.

As with the active Service, you need to create a Kubernetes Service object as the preview Service, which sends traffic to the new, blue version of your app. The preview Service must be a different Service object than the active Service. The preview Service needs to exist on your cluster, or you can deploy it alongside your app.

When creating the ReplicaSet for the new version, CD-as-a-Service injects the labels into the preview Service, so that the preview Service points to the new version of app.

<details><summary>Show me an example preview Service</summary>

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

Configure `previewService` in the `trafficManagement.kubernetes` block:

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
  - targets: ['staging']  # optionally apply this to only one target, if you have multiple targets
    kubernetes:
      - activeService: <your-app-service>
```

### Canary Analysis

You can add canary analysis as a step in the `redirectTrafficAfter` and `shutdownOldVersionAfter` blocks. You use the `analysis` step to run a set of queries against your deployment. Based on the results of the queries, the deployment can (automatically or manually) roll forward or roll back.

For example:

```yaml
redirectTrafficAfter:
  - analysis:
      metricProviderName: <metricProviderName>
      context:
        keyName: <value>
        keyName: <value>
      interval: <integer>
      unit: <seconds|minutes|hours>
      numberOfJudgmentRuns: <integer>
      rollBackMode: <manual|automatic>
      rollForwardMode: <manual|automatic>
      queries:
        - <queryName>
        - <queryName>
```

### Expose service resources

`strategies.<strategy-name>.blueGreen.redirectTrafficAfter.exposeServices`

{{< include "deploy/preview-link-details.md" >}}

### External automation

You can use a webhook-based approval as a step in the `redirectTrafficAfter` section. See {{< linkWithTitle "webhooks/overview.md" >}} for details on incorporating external automation in your blue/green strategy.

## {{% heading "nextSteps" %}}

* See the [Deployment File Reference]({{< ref "reference/deployment/config-file/strategies#bluegreen-fields" >}}) for detailed field explanations.
* The {{< linkWithTitle "tutorials/tutorial-blue-green.md" >}} shows you how to deploy an app using a blue/green strategy.

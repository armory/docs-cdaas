---
title: Configure a Canary Deployment Strategy
linktitle: Canary
weight: 5
description: >
  Learn how to configure a canary deployment strategy. Integrate your metrics provider, create a retrospective analysis query, and add canary analysis as a deployment constraint. Deploy your app to your Kubernetes cluster.
categories: ["Deployment", "Guides"]
tags: ["Kubernetes", "Deploy Strategy", "Canary"]
---

## What a canary strategy does

A canary strategy involves shifting a small percentage of traffic to the new version of your application. You specify conditions before gradually increasing the traffic percentage to the new version. Service meshes like Istio and Linkerd enable finer-grained traffic shaping patterns compared to what is available natively. See the [Strategies Overview]({{< ref "deployment/strategies/overview" >}}) for details on the advantages of using a canary deployment strategy.

## How CD-as-a-Service implements canary
With CD-as-a-Service, users can configure their canary deployment strategy as they desire. Users can define a list of steps that are executed sequentially when executing the strategy. When executing the strategy, CD-as-a-Service creates a new ReplicaSet  for the new version of the application and manipulates the ReplicaSet  object and other resources to shape traffic. 
CD-as-a-Service uses `setWeight` step type to shape the traffic to the new version. Traffic is shaped differently depending on if you are using service mesh or not. 

### Canary strategy without service mesh
When using a canary strategy without a service mesh, CD-as-a-Service performs the following steps:
1. CD-as-a-Service evaluates the setWeight step to determine the traffic split between the new version and the old version.
1. CD-as-a-Service manipulates ReplicaSet  objects of the new version and the old version to achieve the desired traffic split by changing the number of pods in each ReplicaSet .


### Canary strategy with service mesh
When using a canary strategy with a service mesh like Istio or LinkerD, CD-as-a-Service performs the following steps:
1. CD-as-a-Service creates the ReplicaSet  for the new version of the application without changing the `replicaCount` specified in the Kubernetes deployment object. 
1. CD-as-a-Service evaluates the `setWeight` step to determine the traffic split between the new version and the old version.
1. CD-as-a-Service manipulates the relevant objects that are involved in shaping the traffic for the service mesh. 

## {{% heading "prereq" %}}

Before configuring a canary strategy in your [deployment]({{< ref "deployment/overview" >}}), you should have the following:

* Kubernetes Deployment object
  
  Your [Kubernetes Deployment object](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) describes the desired state for your application Pods and ReplicaSets. 

## Define a canary deployment strategy

1. [Declare your strategy](#declare-your-strategy).
1. [Add your strategy to your deployment target](#add-your-strategy-to-your-deployment-target).


### Declare your strategy

You define your blue/green strategy in the root-level `strategies` section of your CD-as-a-Service deployment config file.  The strategy has two required fields:


```yaml
strategies:
  <name-for-your-canary-strategy>:
    canary:
      steps:
        - setWeight: 10
        - pause:
            untilApproved: true
        - setWeight: 20
        - pause:
            untilApproved: true
        - setWeight: 100
```
* `steps`: Define a list of steps that constitue your canary strategy. CD-as-a-Service excutes steps sequentially, waiting for the previous step to finish before starting the next step. This enables you to configure monitoring during canary using analysis or webhooks. 

* `setWeight`: Define how much traffic should get directed to the new version of your application. CD-as-a-Service will manipulated the relevant resources to send the traffic to your new version. 

### Add your strategy to your deployment target

After you configure your strategy, you need to add it to your deployment targets:

```yaml
targets:
  staging:  
    ...
    strategy: <name-for-your-canary-strategy>
  prod:  
    ...
    strategy: <name-for-your-canary-strategy>
```

You can define different canary strategies for different deployment targets.

## Example deployment config file

In this basic example, you deploy an app called "sample-app" to two deployment targets.

```yaml
version: v1
kind: kubernetes
application: sample-app
targets:
  staging:  
    account: staging-cluster
    namespace: staging-ns
    strategy: sample-app-canary
  prod:  
    account: prod-cluster
    namespace: prod-ns
    strategy: sample-app-canary
manifests:
  - path: manifests/<your-app>.yaml # the path to and name of your app manifest
strategies:
  sample-app-canary:
    canary:
      steps:
        - setWeight: 10
        - pause:
            untilApproved: true
        - setWeight: 20
        - pause:
            untilApproved: true
        - setWeight: 100
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

## Using canary strategies with service mesh

Service meshes allow setting up accurate traffic split between the new version and the old version of your application. If you are using a service mesh you need to add a `trafficManagement` block to your deployment config. 

```yaml
trafficManagement:
  - istio:
      ...
```
For more info on using service mes, see:
* [Using service mesh for canary]({{< ref "traffic-management/overview.md" >}})

## {{% heading "nextSteps" %}}

* [Configure your metrics provider to use canary analysis]({{< ref "canary-analysis/overview.md" >}})
* See the [Deployment File Reference]({{< ref "reference/deployment/config-file/strategies#canary-fields" >}}) for detailed field explanations.
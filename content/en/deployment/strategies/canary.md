---
title: Configure a Canary Deployment Strategy
linkTitle: Canary
weight: 5
description: >
  Learn how to configure a canary deployment strategy in your Armory CD-as-a-Service deployment.
---

## What a canary strategy does

A canary strategy involves shifting a small percentage of traffic to the new version of your app. You specify conditions and then gradually increase the traffic percentage to the new version. Service meshes like Istio and Linkerd enable finer-grained traffic shaping patterns compared to what is available natively. See the [Strategies Overview]({{< ref "deployment/strategies/overview" >}}) for details on the advantages of using a canary deployment strategy.

## How CD-as-a-Service implements canary

With CD-as-a-Service, you can configure your canary deployment strategy however you want. You define a list of steps that CD-as-a-Service executes sequentially when deploying your app. CD-as-a-Service creates a new ReplicaSet for the new version of the app and then manipulates the ReplicaSet object and other resources to shape traffic. CD-as-a-Service uses the `setWeight` step type to shape traffic to the new version. Traffic is shaped differently depending on whether or not you are using a service mesh.

### Canary strategy without a service mesh

When using a canary strategy without a service mesh, CD-as-a-Service performs the following steps:

1. CD-as-a-Service evaluates the `setWeight` step to determine the traffic split between the new version and the old version.
1. CD-as-a-Service manipulates ReplicaSet objects of the new version and the old version to achieve the desired traffic split by changing the number of pods in each ReplicaSet.

### Canary strategy with service mesh

When using a canary strategy with a service mesh such as Istio or Linkerd, CD-as-a-Service performs the following steps:

1. CD-as-a-Service creates the ReplicaSet for the new version of the app without changing the `replicaCount` specified in the Kubernetes deployment object. 
1. CD-as-a-Service evaluates the `setWeight` step to determine the traffic split between the new version and the old version.
1. CD-as-a-Service manipulates the relevant objects that are involved in shaping the traffic for the service mesh. 

## {{% heading "prereq" %}}

Before configuring a canary strategy in your [Kubernetes deployment]({{< ref "deployment/kubernetes/overview" >}}), you 
should have the following:

* Kubernetes Deployment object
  
  Your [Kubernetes Deployment object](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment) describes the desired state for your app Pods and ReplicaSets. 

  >If you do not have a Kubernetes deployment object being deployed to a target, CD-as-a-Service ignores the strategy and deploys all the manifests destined for the target.

## Define a canary deployment strategy

1. [Declare your strategy](#declare-your-strategy).
1. [Add your strategy to your deployment target](#add-your-strategy-to-your-deployment-target).


### Declare your strategy

You define your canary strategy in the root-level `strategies` section of your CD-as-a-Service deployment config file. The strategy has two required fields: `steps` and `setWeight`. 


{{< highlight yaml "hl_lines=4 5 8 11" >}}
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
{{< /highlight >}}

* `steps`: Define a list of steps that constitute your canary strategy. CD-as-a-Service executes steps sequentially, waiting for each step to finish before starting the next step. This enables you to configure monitoring during deployment using analysis or webhooks. 

* `setWeight`: Define how much traffic CD-as-a-Service should direct to the new version of your app. CD-as-a-Service manipulates the relevant resources to gradually increase the traffic to the new version. 

Between `setWeight` entries, you can configure deployment to wait for the outcome of canary analysis, to pause for manual judgment, or to pause for a defined period of time. See the [Deployment File Reference]({{< ref "/reference/deployment/config-file/strategies#pause" >}}) for details.

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

## Using canary strategies with a service mesh

Service meshes enable setting up accurate traffic splits between the new version and the old version of your app. If you are using a service mesh, you need to add a `trafficManagement` block to your deployment config.

```yaml
trafficManagement:
  - istio:
      ...
```
For more info on using service meshes, see the [Traffic Management Overview]({{< ref "traffic-management/overview.md" >}}), which explains how CD-as-a-Service implements progressive canary deployment using an SMI TrafficSplit.


## Example Kubernetes deployment config file

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

## Example AWS Lambda deployment config

```yaml
version: v1
kind: lambda
application: Sweet Potato Lambda
description: Sweet Potato facts from a Lambda function
deploymentConfig:
  timeout:
    unit: minutes
    duration: 10
targets:
  dev:
    account: armory-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-2
    strategy: trafficSplit

strategies:
  trafficSplit:
    canary:
      steps:
        - setWeight: 10
        - pause:
            untilApproved: true
        - setWeight: 20
        - pause:
            untilApproved: true
        - setWeight: 100
artifacts:
  - functionName: just-sweet-potatoes
    path: s3://armory-docs-dev-us-east-2/justsweetpotatoes.zip
    type: zipFile

providerOptions:
  lambda:
    - name: just-sweet-potatoes
      target: dev
      runAsIamRole: arn:aws:iam::111111111111:role/LamdaExecutionRole
      handler: index.handler
      runtime: nodejs18.x
```

## {{% heading "nextSteps" %}}

* [Configure your metrics provider and create canary analysis queries]({{< ref "canary-analysis/overview.md" >}}).
* See the [Deployment File Reference]({{< ref "reference/deployment/config-file/strategies#canary-fields" >}}) for detailed field explanations.
* [Configure Istio]({{< ref "traffic-management/istio" >}}).
* [Configure Linkerd]({{< ref "traffic-management/linkerd" >}}).
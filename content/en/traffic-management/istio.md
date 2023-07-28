---
title: Configure Traffic Management With Istio
linkTitle: Istio
description: >
  Configure your Armory CD-as-a-Service deployment to use Istio for traffic management.
categories: ["Traffic Management", "Features", "Guides"]
tags: ["Istio", "Deploy Config"]
---

## {{% heading "prereq" %}}

* You are familiar with the following [Istio](https://istio.io/latest/) concepts:

  * [Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/)
  * [Virtual Service configuration](https://istio.io/latest/docs/reference/config/networking/virtual-service/)

* You have [installed Istio](https://istio.io/latest/docs/setup/getting-started/) in your target cluster.
* You know how to configure Istio's [VirtualService](https://istio.io/latest/docs/reference/config/networking/virtual-service/) and associated [DestinationRule](https://istio.io/latest/docs/reference/config/networking/virtual-service/#Destination).
* You know [how to create a CD-as-a-Service deployment config file]({{< ref "reference/deployment/_index.md" >}}).

>CD-as-a-Service does not configure proxy sidecar injection.

## How CD-as-a-Service shapes traffic

In the following example, you define a CD-as-a-Service deployment that uses a VirtualService and DestinationRoute:

{{< include "deploy/istio-example.md" >}}

When you deploy your app, CD-as-a-Service modifies your VirtualService and DestinationRule, setting weights for `stable` and `canary` subsets based on the weights specified in your deployment strategy.  CD-as-a-Service also adds the `armory-pod-template-hash` label to the DestinationRule subsets for routing traffic to the pods of each ReplicaSet.

{{< highlight yaml "linenos=table, hl_lines=13 17 30 34" >}}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews.istiodemo.svc.cluster.local
        subset: stable
      weight: 10
    - destination:
        host: reviews.istiodemo.svc.cluster.local
        subset: canary
      weight: 90
    name: http-route-reviews
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews.istiodemo.svc.cluster.local
  subsets:
  - name: stable
    labels:
      app: reviews
      armory-pod-template-hash: gc6647
  - name: canary
    labels:
      app: reviews
      armory-pod-template-hash: cd6648
{{< /highlight >}}

At the end of the deployment, CD-as-a-Service removes the lines it added so the resources look the same as before the deployment began.

## Additional capabilities

* You have two options for deploying your VirtualService and DestinationRule Istio resources:

   1. Separately, before your CD-as-a-Service deployment
   1. As part of your CD-as-a-Service deployment, included in the same directory as your app manifest

* You can use a VirtualService that has more than one route as long as the route is named within the resource and specified in your deployment file.
* CD-as-a-Service supports both FQDN and short names in the `host` fields.

## Create your Istio resources manifest

Create a manifest that defines your VirtualService and DestinationRule resources. Armory recommends one VirtualService with one DestinationRule for your deployment. CD-as-a-Service modifies these resources based on the [canary strategy]({{< ref "reference/deployment/config-file/strategies" >}}) that you define in your deployment file. You can deploy these resources separately or as part of your CD-as-a-Service deployment.

## Configure your CD-as-a-Service deployment

Configure your Istio resources in the `trafficManagement.targets` section of your deployment file.

{{< include "dep-file/tm-istio-config.md" >}}

## Example resources and deployment files

In this example, you deploy an app called "reviews".  You define your Istio resources in `istio-resources.yaml` and deploy that manifest as part of your app deployment.

{{< include "deploy/istio-example.md" >}}

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "reference/deployment/config-file/traffic-management.md" >}}
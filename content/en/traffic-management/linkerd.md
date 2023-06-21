---
title: Configure Traffic Management With Linkerd
linkTitle: Linkerd
weight: 1
description: >
  Configure your Armory CD-as-a-Service deployment to use Linkerd for traffic management.
categories: ["Traffic Management", "Features", "Guides"]
tags: ["Linkerd", "TrafficSplit", "Deploy Config"]
---

## {{% heading "prereq" %}}

* In your target Kubernetes cluster, you have deployed Linkerd, a service mesh that complies with the [Service Mesh Interface (SMI) spec](https://github.com/servicemeshinterface/smi-spec).
* You know [how to create a CD-as-a-Service deployment config file]({{< ref "reference/deployment/_index.md" >}}).

>CD-as-a-Service does not configure proxy sidecar injection.

## Configure traffic management

Add a top-level `trafficManagement.targets` section to your deployment file.

{{< include "dep-file/tm-smi-config.md" >}}

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "reference/deployment/_index.md" >}}

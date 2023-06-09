---
title: Traffic Management Config
weight: 8
description: >
  This page describes the `trafficManagement` section.
---

## `trafficManagement.`

You configure your service mesh per target in this section. If you omit the `target` entry, CD-as-a-Service applies the config to all targets.

{{< prism lang="yaml"  line-numbers="true" >}}
trafficManagement:
  - targets: ["<target-name>"]
{{< /prism >}}

### `trafficManagement.targets.smi`

{{< include "dep-file/tm-smi-config.md" >}}


### `trafficManagment.targets.istio`

See {{< linkWithTitle "traffic-management/istio.md" >}} for a detailed example.

{{< include "dep-file/tm-istio-config.md" >}}


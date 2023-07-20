---
title: Deployment Config
weight: 2
description: >
  Declare the time before your deployment times out. Default is 30 minutes.
---

## `deploymentConfig`

This config block is optional. If included, this configuration applies to all targets.

A deployment times out if the pods for your application fail to be in ready state in 30 minutes. If you want to change the default, include this section.


{{< prism lang="yaml"  line-numbers="true" >}}
deploymentConfig:
  timeout:
    unit: <seconds|minutes|hours>
    duration: <integer>
{{< /prism >}}

- `timeout`: (Required is section is included) The section specifies the amount of time to wait for pods to be ready before cancelling the deployment.
   - `unit`: (Required) Set to `seconds`, `minutes` or `hours` to indicate what `duration` refers to.
   - `duration`: (Required) Integer amount of time to wait

>The minimum timeout you can specify is 60 seconds (1 minute).

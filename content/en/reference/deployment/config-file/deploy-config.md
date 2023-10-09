---
title: Deployment Config
description: >
  Customize your CD-as-a-Service deployment's behavior deployment timeout and `keepDeploymentObject` settings.
---

## Deployment config section

This config block is optional. If included, this configuration applies to all targets.

```yaml
deploymentConfig:
  timeout:
    unit: <seconds|minutes|hours>
    duration: <integer>
  keepDeploymentObject: <boolean> 
```

## Timeout

A deployment times out if the pods for your app fail to be in ready state in 30 minutes. If you want to change the default, include a `timeout` block.

```yaml
deploymentConfig:
  timeout:
    unit: <seconds|minutes|hours>
    duration: <integer>
```

- `timeout`: The section specifies the amount of time to wait for pods to be ready before cancelling the deployment.
   - `unit`: (Required) Set to `seconds`, `minutes` or `hours` to indicate what `duration` refers to.
   - `duration`: (Required) Integer amount of time to wait.

>The minimum timeout you can specify is 60 seconds (1 minute).

## Keep deployment object

```yaml
deploymentConfig:
  keepDeploymentObject: <boolean> 
```

(Optional; Default: `false`) By default, CD-as-a-Service deploys and manages ReplicaSets even when the client-requested resource is a Kubernetes Deployment. When this flag is set to `true`, CD-as-a-Service keeps Deployment objects between deployment executions. 


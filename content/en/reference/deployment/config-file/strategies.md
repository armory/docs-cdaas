---
title: Strategies Config
description: >
  Declare your deployment strategies. You can use blue/green, canary, or both. Restrict by target environment. Add steps such as weight, manual or timed pauses, analysis, expose services, redirect traffic, and shut down old version. 
---

## Strategies section

This config block is where you define the behavior and steps for your deployment strategy. You can declare multiple strategies in your deployment config file.

```yaml
strategies:
  <strategyName>
    <strategyType>:
    ...
  <strategyName>
    <strategyType>:
    ...
  <strategyName>
    <strategyType>:
```

* `<strategyName>`: The name you assign to the strategy. Use this name for `targets.<targetName>.strategy`. You can define multiple strategies, so make sure to use a unique descriptive name for each.

  In this example, you name the strategy `canary-wait-til-approved`.

  ```yaml
  strategies:
    canary-wait-til-approved:
  ```

  You would use `canary-wait-til-approved` as the value for `targets.<targetName>.strategy` that is at the start of the file:

  ```yaml
  ...
  targets:
    staging:
      ...
      strategy: canary-wait-till-approved
  ```

* `<strategyType>`: This is either `canary` or `blueGreen`.

  ```yaml
  strategies:
    canary-wait-til-approved:
      canary:
  ```

## Canary fields

```yaml
strategies:
  <strategyName>
    canary:
      steps:
        - setWeight:
            weight: <integer>
        - pause:
            duration: <integer>
            unit: <seconds|minutes|hours>
        - setWeight:
            weight: <integer>
        - exposeServices:
            services:
              - <service-1>
              - <service-2>
              - <service-n>
            ttl:
              duration: <integer>
              unit: <seconds|minutes|hours>
        - pause:
            untilApproved: true
        - analysis:
            context:
              keyName: <value>
              keyName: <value>
            interval: <integer>
            units: <seconds|minutes|hours>
            numberOfJudgmentRuns: <integer>
            rollBackMode: <manual|automatic>
            rollForwardMode: <manual|automatic>
            queries:
              - <queryName>
              - <queryName>
        - setWeight:
            weight: <integer>
```

### Steps

`strategies.<strategyName>.canary.steps`

Armory CD-as-a-Service progresses through all the steps you define as part of the deployment process. The process is sequential and steps can be of the types, `analysis`, `setWeight` or `pause`.

Generally, you want to configure a `setWeight` step and have a `analysis` or `pause` step follow it although this is not necessarily required. This gives you the opportunity to see how the deployment is doing either manually or automatically before the deployment progresses.

Some scenarios where this pairing sequence might not be used would be the following:

- You can start the sequence of steps with a `pause` that has no corresponding weight. Armory CD-as-a-Service recognizes this as a weight of `0` since it is as the start of the deployment. This causes the deployment to pause at the start before any of the app is deployed.
- You want to have two `pause` steps in a row, such as a `pause` for a set amount of time followed by a `pause` for a manual judgment.

You can add as many steps as you need but do not need to add a final step that deploys the app to 100% of the cluster. Armory CD-as-a-Service automatically does that after completing the final step you define.

#### Set weight

`strategies.<strategyName>.canary.steps.setWeight.weight`

This is an integer value and determines how much of the cluster the app gets deployed to. The value must be between 0 and 100 and the the `weight` for each `setWeight` step should increase as the deployment progresses. After hitting this threshold, Armory CD-as-a-Service pauses the deployment based on the behavior you set for  the `strategies.<strategyName>.<strategy>.steps.pause` that follows.


For example, this snippet instructs Armory CD-as-a-Service to deploy the app to 33% of the cluster:

```yaml
...
steps:
  - setWeight:
      weight: 33
```

#### Pause

`strategies.<strategyName>.canary.steps.pause`

There are two base behaviors you can set for `pause`, either a set amount of time or until a manual judgment is made.

```yaml
steps:
...
  - pause:
      duration: <integer>
      unit: <seconds|minutes|hours>
...
  - pause:
      untilApproved: true
      requiresRoles: []
      approvalExpiration:
        duration: 60
        unit: seconds
```

**Pause for a set amount of time**

If you want the deployment to pause for a certain amount of time after a weight is met, you must provide both the amount of time (duration) and the unit of time (unit).

- `strategies.<strategyName>.canary.steps.pause.duration`
  - Use an integer value for the amount of time.
- `strategies.<strategyName>.canary.steps.pause.unit`
  - Use `seconds`, `minutes` or `hours` for unit of time.

For example, this snippet instructs Armory CD-as-a-Service to wait for 30 seconds:

```yaml
steps:
...
  - pause:
      duration: 30
      unit: seconds
```

**Pause until a manual judgment**

When you configure a manual judgment, the deployment waits when it hits the corresponding weight threshold. At that point, you can either approve the deployment so far and let it continue or roll the deployment back if something doesn't look right.

- `strategies.<strategyName>.canary.steps.pause.untilApproved: true`
- `strategies.<strategyName>.canary.steps.pause.requiresRoles` (Optional) list of RBAC roles that can issue a manual approval
- `strategies.<strategyName>.canary.steps.pause.approvalExpiration` (Optional) time to wait for the approval - if expired, current deployment is cancelled

For example:

```yaml
steps:
...
  - pause:
      untilApproved: true
      requiresRoles: []
      approvalExpiration:
        duration: 60
        unit: minutes
```

#### Expose services (preview links)

`strategies.<strategyName>.canary.steps.exposeServices`

{{< include "deploy/preview-link-details.md" >}}

#### Analysis

`strategies.<strategyName>.canary.steps.analysis`

The `analysis` step is used to run a set of queries against your deployment. Based on the results of the queries, the deployment can automatically or manually roll forward or roll back.

```yaml
steps:
...
        - analysis:
            metricProviderName: <metricProviderName>
            context:
              keyName: <value>
              keyName: <value>
            interval: <integer>
            units: <seconds|minutes|hours>
            numberOfJudgmentRuns: <integer>
            rollBackMode: <manual|automatic>
            rollForwardMode: <manual|automatic>
            queries:
              - <queryName>
              - <queryName>
```

##### Metrics provider name

`strategies.<strategyName>.canary.steps.analysis.metricProviderName`

Optional. The name of a configured metric provider. If you do not provide a metric provider name, CD-as-a-Service uses the default metric provider defined in the `analysis.defaultMetricProviderName`. Use the **Configuration UI** to add a metric provider.

##### Context

 `strategies.<strategyName>.canary.steps.analysis.context`

Custom key/value pairs that are passed as substitutions for variables to the queries.

CD-as-a-Service supports the following variables out of the box:

- `armory.startTimeIso8601`
- `armory.startTimeEpochSeconds`
- `armory.startTimeEpochMillis`
- `armory.endTimeIso8601`
- `armory.endTimeEpochSeconds`
- `armory.endTimeEpochMillis`
- `armory.intervalMillis`
- `armory.intervalSeconds`
- `armory.promQlStepInterval`
- `armory.deploymentId`
- `armory.applicationName`
- `armory.environmentName`
- `armory.replicaSetName`

If your deployment strategy contains `exposeServices` step, all exposed service preview links are available as part of the `armory.preview` sub-context. For example, if you create service preview for service `my-http-service` you could access it using `armory.preview.my-http-service`.

You can supply your own variables by adding them to this section. When you use them in your query, include the `context` prefix. For example, if you create a variable named `owner`, you would use `context.owner` in your query.

For information about writing queries, see {{< linkWithTitle "reference/canary-analysis-query.md" >}}.

##### Interval

`strategies.<strategyName>.canary.steps.analysis.interval`

```yaml
steps:
...
        - analysis:
            interval: <integer>
            units: <seconds|minutes|hours>
```

How long each sample of the query gets summarized over.

For example, the following snippet sets the interval to 30 seconds:

```yaml
steps:
...
        - analysis:
            interval: 30
            units: seconds

```

##### Units

`strategies.<strategyName>.canary.steps.analysis.units`

The unit of time for the interval. Use `seconds`, `minutes` or `hours`. See `strategies.<strategyName>.<strategy>.steps.analysis.interval` for more information.

##### Number of judgment runs

 `strategies.<strategyName>.canary.steps.analysis.numberOfJudgmentRuns`

```yaml
steps:
...
        - analysis:
            ...
            numberOfJudgmentRuns: <integer>
            ...
```

The number of times that each query runs as part of the analysis. Armory CD-as-a-Service takes the average of all the results of the judgment runs to determine whether the deployment falls within the acceptable range.

##### Rollback mode

`strategies.<strategyName>.canary.steps.analysis.rollBackMode`

```yaml
steps:
...
        - analysis:
            ...
            rollBackMode: <manual|automatic>
            ...
```

Optional. Can either be `manual` or `automatic`. Defaults to `automatic` if omitted.

How a rollback is approved if the analysis step determines that the deployment should be rolled back. The thresholds for a rollback are set in `lowerLimit` and `upperLimit` in the `analysis` block of the deployment file. This block is separate from the `analysis` step that this parameter is part of.

##### Roll forward mode

`strategies.<strategyName>.canary.steps.analysis.rollForwardMode`

```yaml
steps:
...
        - analysis:
            ...
            rollForwardMode: <manual|automatic>
            ...
```

Optional. Can either be `manual` or `automatic`. Defaults to `automatic` if omitted.

How a rollback is approved if the analysis step determines that the deployment should proceed (or roll forward). The thresholds for a roll forward are any values that fall within the range you create when you set the `lowerLimit` and `upperLimit`values in the `analysis` block of the deployment file. This block is separate from the `analysis` step that this parameter is part of.

##### Queries

`strategies.<strategyName>.canary.steps.analysis.queries`

```yaml
steps:
...
        - analysis:
            ...
            queries:
              - <queryName>
              - <queryName>
```

A list of queries that you want to use as part of this `analysis` step. Provide the name of the query, which is set in the `analysis.queries.name` parameter. Note that thee `analysis` block is separate from the `analysis` step.

All the queries must pass for the step as a whole to be considered a success.



## Blue/green fields

```yaml
strategies:
  <strategyName>
    blueGreen:
      activeService: <active-service>
      previewService: <preview-service>
      redirectTrafficAfter:
        - pause:
            duration: <integer>
            unit: <seconds|minutes|hours>
      shutDownOldVersionAfter:
        - pause:
            untilApproved: true
```


#### Active service

`strategies.<strategyName>.blueGreen.activeService`

The name of a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) that you created to route traffic to your application.

```yaml
strategies:
  <strategy>:
    blueGreen:
      activeService: <active-service>
```

#### Preview service

`strategies.<strategyName>.blueGreen.previewService`

(Optional) The name of a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) you created to route traffic to the new version of your application so you can preview your updates.

```yaml
strategies:
  <strategy>:
    blueGreen:
      previewService: <preview-service>
```

#### Redirect traffic after

`strategies.<strategyName>.blueGreen.redirectTrafficAfter`

The `redirectTrafficAfter` steps are conditions for exposing the new version to the `activeService`. The steps are executed in parallel. After each step completes, Armory CD-as-a-Service exposes the new version to the `activeService`.

##### Pause

`strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause`

There are two base behaviors you can set for `pause`, either a set amount of time or until a manual judgment is made.

```yaml
redirectTrafficAfter:
  - pause:
      duration: <integer>
      unit: <seconds|minutes|hours>
```

```yaml
redirectTrafficAfter:
  - pause:
      untilApproved: true
      approvalExpiration:
        duration: 60
        unit: seconds
```

**Pause for a set amount of time**

If you want the deployment to pause for a certain amount of time, you must provide both the amount of time (duration) and the unit of time (unit).

- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.duration`
  - Use an integer value for the amount of time.
- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.unit`
  - Use `seconds`, `minutes` or `hours` for unit of time.

For example, this snippet instructs Armory CD-as-a-Service to wait for 30 minutes:

```yaml
redirectTrafficAfter:
  - pause:
      duration: 30
      unit: minutes
```

**Pause until a manual judgment**

When you configure a manual judgment, the deployment waits for manual approval through the UI. You can either approve the deployment or roll the deployment back if something doesn't look right. Do not provide a `duration` or `unit` value when defining a judgment-based pause.

- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.untilApproved: true`
- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.requiresRoles` (Optional) list of RBAC roles that can issue a manual approval
- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.approvalExpiration` (Optional) time to wait for the approval - if expired, current deployment is cancelled
- 
For example:

```yaml
redirectTrafficAfter:
  - pause:
      untilApproved: true
      requiresRoles: []
      approvalExpiration:
        duration: 60
        unit: minutes
```

##### Expose services (preview links)

`strategies.<strategyName>.blueGreen.redirectTrafficAfter.exposeServices`

{{< include "deploy/preview-link-details.md" >}}

##### Analysis

 `strategies.<strategyName>.blueGreen.redirectTrafficAfter.analysis`

The `analysis` step is used to run a set of queries against your deployment. Based on the results of the queries, the deployment can (automatically or manually) roll forward or roll back.

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

#### Shut down old version after

`strategies.<strategyName>.blueGreen.shutdownOldVersionAfter`

This step is a condition for deleting the old version of your software. Armory CD-as-a-Service executes the `shutDownOldVersion` steps in parallel. After each step completes, Armory CD-as-a-Service deletes the old version.

```yaml
shutdownOldVersionAfter:
  - pause:
      untilApproved: true
```

##### Analysis

`strategies.<strategyName>.blueGreen.shutdownOldVersionAfter.analysis`

The `analysis` step is used to run a set of queries against your deployment. Based on the results of the queries, the deployment can (automatically or manually) roll forward or roll back.

```yaml
shutdownOldVersionAfter:
  - analysis:
      metricProviderName: <metricProviderName>
      context:
        keyName: <value>
        keyName: <value>
      interval: <integer>
      units: <seconds|minutes|hours>
      numberOfJudgmentRuns: <integer>
      rollBackMode: <manual|automatic>
      rollForwardMode: <manual|automatic>
      queries:
        - <queryName>
        - <queryName>`
```

## Examples

### Basic canary strategies

This example declares `rolling` and `trafficSplit` canary strategies. The `rolling` strategy deploys to the target 100%, whereas the `trafficSplit` strategy deploys to 25% of the new pods in the first step, creates a preview link, and then waits for manual approval before deploying to the remaining pods.

```yaml
version: v1
kind: kubernetes
application: potato-facts
targets:
  staging:
    account: my-cdaas-cluster
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    account: my-cdaas-cluster
    namespace: potato-facts-prod
    strategy: trafficSplit
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
            requiresRoles:
              - Organization Admin
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
  trafficSplit:
    canary:
      steps:
        - setWeight:
            weight: 25
        - exposeServices:
            services:
              - potato-facts
            ttl:
              duration: 30
              unit: minutes
        - pause:
            untilApproved: true
        - setWeight:
            weight: 100
...
```

### Basic blue/green strategy

```yaml
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
  blue-green-prod:
    blueGreen:
      redirectTrafficAfter:
        - pause:
            untilApproved: true
            approvalExpiration:
              duration: 10
              unit: minutes
        - exposeServices:
            services:
              - potato-facts-preview-svc
            ttl:
              duration: 10
              unit: minutes
      shutDownOldVersionAfter:
        - pause:
            duration: 15
            unit: minutes
```

* `blueGreen.redirectTrafficAfter`: This step declares conditions for exposing the new app version to the active Service. CD-as-a-Service executes steps in parallel.

   - `pause`: This step pauses for manual judgment before redirecting traffic to the new app version and has an expiration configured. If you do not approve within the specified time, the deployment fails. You can also configure the deployment to pause for a set amount of time before automatically continuing deployment.
   
   - `exposeServices`: This step creates a temporary preview service link for testing purposes. The exposed link is not secure and expires after the time in the `ttl` section. See {{< linkWithTitle "reference/deployment/config-preview-link.md" >}} for details.

* `blueGreen.shutDownOldVersionAfter`: This step defines a condition for deleting the old version of your app. If deployment is successful, CD-as-a-Service shuts down the old version after the specified time. This field supports the same `pause` steps as the `redirectTrafficAfter` field.

### Strategies with analysis

```yaml
...
strategies:
  mycanary:
    canary: 
        steps:
          - setWeight:
              weight: 25
          - analysis:
              interval: 7
              units: seconds
              numberOfJudgmentRuns: 1
              rollBackMode: manual
              rollForwardMode: automatic
              queries:
              - avgCPUUsage-pass
          - runWebhook:
              name: CheckLogs
          - pause:
              untilApproved: true
          - setWeight:
              weight: 50
          - analysis:
              interval: 7
              units: seconds
              numberOfJudgmentRuns: 3
              rollBackMode: manual
              rollForwardMode: manual
              queries: 
              - avgCPUUsage-fail
              - avgCPUUsage-pass
          - setWeight:
              weight: 100
  rolling:
    canary:
      steps: 
      - setWeight:
          weight: 100
  myBlueGreen:
    blueGreen:
      activeService: potato-facts-external
      previewService: potato-facts-preview
      redirectTrafficAfter:
        - runWebhook:
              name: CheckLogs
        - analysis:
              interval: 7
              units: seconds
              numberOfJudgmentRuns: 3
              rollBackMode: manual
              rollForwardMode: manual
              queries: 
              - avgCPUUsage-fail
              - avgCPUUsage-pass
      shutDownOldVersionAfter:
        - pause:
            untilApproved: true
analysis:
  defaultMetricProviderName: Stephen-Prometheus
  queries:
    - name: avgCPUUsage-pass
      upperLimit: 10000 #3
      lowerLimit: 0
      queryTemplate: >-
        avg (avg_over_time(container_cpu_system_seconds_total{job="kubelet"}[{{armory.promQlStepInterval}}]) * on (pod)  group_left (annotation_app)
        sum(kube_pod_annotations{job="kube-state-metrics",annotation_deploy_armory_io_replica_set_name="{{armory.replicaSetName}}"})
        by (annotation_app, pod)) by (annotation_app)
    - name: avgCPUUsage-fail
      upperLimit: 1
      lowerLimit: 0
      queryTemplate: >-
        avg (avg_over_time(container_cpu_system_seconds_total{job="kubelet"}[{{armory.promQlStepInterval}}]) * on (pod)  group_left (annotation_app)
        sum(kube_pod_annotations{job="kube-state-metrics",annotation_deploy_armory_io_replica_set_name="{{armory.replicaSetName}}"})
        by (annotation_app, pod)) by (annotation_app)
...
```
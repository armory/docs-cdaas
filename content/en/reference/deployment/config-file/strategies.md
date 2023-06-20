---
title: Strategies Config
weight: 5
description: >
  This page describes the `strategies` section.
---

## `strategies.`

This config block is where you define behavior and the actual steps to a deployment strategy.

{{< prism lang="yaml"  line-numbers="true" >}}
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
{{< /prism >}}

### `strategies.<strategyName>`

The name you assign to the strategy. Use this name for `targets.<targetName>.strategy`. You can define multiple strategies, so make sure to use a unique descriptive name for each.

For example, this snippet names the strategy `canary-wait-til-approved`:

{{< prism lang="yaml"  line-numbers="true" >}}
strategies:
  canary-wait-til-approved:
{{< /prism >}}

You would use `canary-wait-til-approved` as the value for `targets.<targetName>.strategy` that is at the start of the file:

{{< prism lang="yaml"  line-numbers="true" >}}
...
targets:
  someName:
    ...
    strategy: canary-wait-till-approved
...
{{< /prism >}}

### `strategies.<strategyName>.<strategy>`

The kind of deployment strategy this strategy uses. Armory CD-as-a-Service supports `canary` and `blueGreen`.

{{< prism lang="yaml"  line-numbers="true" >}}
strategies:
  <strategyName>
    canary:
{{< /prism >}}

### Canary fields

#### `strategies.<strategyName>.canary.steps`

Armory CD-as-a-Service progresses through all the steps you define as part of the deployment process. The process is sequential and steps can be of the types, `analysis`, `setWeight` or `pause`.

Generally, you want to configure a `setWeight` step and have a `analysis` or `pause` step follow it although this is not necessarily required. This gives you the opportunity to see how the deployment is doing either manually or automatically before the deployment progresses.

Some scenarios where this pairing sequence might not be used would be the following:

- You can start the sequence of steps with a `pause` that has no corresponding weight. Armory CD-as-a-Service recognizes this as a weight of `0` since it is as the start of the deployment. This causes the deployment to pause at the start before any of the app is deployed.
- You want to have two `pause` steps in a row, such as a `pause` for a set amount of time followed by a `pause` for a manual judgment.

You can add as many steps as you need but do not need to add a final step that deploys the app to 100% of the cluster. Armory CD-as-a-Service automatically does that after completing the final step you define.

#### `strategies.<strategyName>.canary.steps.setWeight.weight`

This is an integer value and determines how much of the cluster the app gets deployed to. The value must be between 0 and 100 and the the `weight` for each `setWeight` step should increase as the deployment progresses. After hitting this threshold, Armory CD-as-a-Service pauses the deployment based on the behavior you set for  the `strategies.<strategyName>.<strategy>.steps.pause` that follows.


For example, this snippet instructs Armory CD-as-a-Service to deploy the app to 33% of the cluster:

{{< prism lang="yaml"  line-numbers="true" >}}
...
steps:
  - setWeight:
      weight: 33
{{< /prism >}}

#### `strategies.<strategyName>.canary.steps.pause`

There are two base behaviors you can set for `pause`, either a set amount of time or until a manual judgment is made.

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
  - pause:
      duration: <integer>
      unit: <seconds|minutes|hours>
...
  - pause:
      untilApproved: true
      approvalExpiration:
        duration: 60
        unit: seconds
{{< /prism >}}

**Pause for a set amount of time**

If you want the deployment to pause for a certain amount of time after a weight is met, you must provide both the amount of time (duration) and the unit of time (unit).

- `strategies.<strategyName>.canary.steps.pause.duration`
  - Use an integer value for the amount of time.
- `strategies.<strategyName>.canary.steps.pause.unit`
  - Use `seconds`, `minutes` or `hours` for unit of time.

For example, this snippet instructs Armory CD-as-a-Service to wait for 30 seconds:

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
  - pause:
      duration: 30
      unit: seconds
{{< /prism >}}

**Pause until a manual judgment**

When you configure a manual judgment, the deployment waits when it hits the corresponding weight threshold. At that point, you can either approve the deployment so far and let it continue or roll the deployment back if something doesn't look right.

- `strategies.<strategyName>.canary.steps.pause.untilApproved: true`
- `strategies.<strategyName>.canary.steps.pause.requiresRole` (Optional) list of RBAC roles that can issue a manual approval
- `strategies.<strategyName>.canary.steps.pause.approvalExpiration` (Optional) time to wait for the approval - if expired, current deployment is cancelled

For example:

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
  - pause:
      untilApproved: true
      requiresRoles: []
      approvalExpiration:
        duration: 60
        unit: minutes
{{< /prism >}}

#### `strategies.<strategyName>.canary.steps.analysis`

The `analysis` step is used to run a set of queries against your deployment. Based on the results of the queries, the deployment can automatically or manually roll forward or roll back.

{{< prism lang="yaml"  line-numbers="true" >}}
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
{{< /prism >}}

##### `strategies.<strategyName>.canary.steps.analysis.metricProviderName`

Optional. The name of a configured metric provider. If you do not provide a metric provider name, Armory CD-as-a-Service uses the default metric provider defined in the `analysis.defaultMetricProviderName`. Use the **Configuration UI** to add a metric provider.

##### `strategies.<strategyName>.canary.steps.analysis.context`

Custom key/value pairs that are passed as substitutions for variables to the queries.

Armory supports the following variables out of the box:

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

If your deployment strategy contains `exposeServices` step, all exposed service preview links are available as part of the `armory.preview` sub-context. 
For example, if you create service preview for service `my-http-service` you could access it using `armory.preview.my-http-service`.

You can supply your own variables by adding them to this section. When you use them in your query, include the `context` prefix. For example, if you create a variable named `owner`, you would use `context.owner` in your query.

For information about writing queries, see {{< linkWithTitle "reference/canary-analysis-query.md" >}}.

##### `strategies.<strategyName>.canary.steps.analysis.interval`

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
        - analysis:
            interval: <integer>
            units: <seconds|minutes|hours>
{{< /prism >}}

How long each sample of the query gets summarized over.

For example, the following snippet sets the interval to 30 seconds:

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
        - analysis:
            interval: 30
            units: seconds

{{< /prism >}}

##### `strategies.<strategyName>.canary.steps.analysis.units`

The unit of time for the interval. Use `seconds`, `minutes` or `hours`. See `strategies.<strategyName>.<strategy>.steps.analysis.interval` for more information.

##### `strategies.<strategyName>.canary.steps.analysis.numberOfJudgmentRuns`

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
        - analysis:
            ...
            numberOfJudgmentRuns: <integer>
            ...
{{< /prism >}}

The number of times that each query runs as part of the analysis. Armory CD-as-a-Service takes the average of all the results of the judgment runs to determine whether the deployment falls within the acceptable range.

##### `strategies.<strategyName>.canary.steps.analysis.rollBackMode`

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
        - analysis:
            ...
            rollBackMode: <manual|automatic>
            ...
{{< /prism >}}

Optional. Can either be `manual` or `automatic`. Defaults to `automatic` if omitted.

How a rollback is approved if the analysis step determines that the deployment should be rolled back. The thresholds for a rollback are set in `lowerLimit` and `upperLimit` in the `analysis` block of the deployment file. This block is separate from the `analysis` step that this parameter is part of.

##### `strategies.<strategyName>.canary.steps.analysis.rollForwardMode`

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
        - analysis:
            ...
            rollForwardMode: <manual|automatic>
            ...
{{< /prism >}}

Optional. Can either be `manual` or `automatic`. Defaults to `automatic` if omitted.

How a rollback is approved if the analysis step determines that the deployment should proceed (or roll forward). The thresholds for a roll forward are any values that fall within the range you create when you set the `lowerLimit` and `upperLimit`values in the `analysis` block of the deployment file. This block is separate from the `analysis` step that this parameter is part of.

##### `strategies.<strategyName>.canary.steps.analysis.queries`

{{< prism lang="yaml"  line-numbers="true" >}}
steps:
...
        - analysis:
            ...
            queries:
              - <queryName>
              - <queryName>
{{< /prism >}}

A list of queries that you want to use as part of this `analysis` step. Provide the name of the query, which is set in the `analysis.queries.name` parameter. Note that thee `analysis` block is separate from the `analysis` step.

All the queries must pass for the step as a whole to be considered a success.

#### `strategies.<strategyName>.canary.steps.exposeServices`

{{< include "deploy/preview-link-details.md" >}}

### Blue/green fields

#### `strategies.<strategyName>.blueGreen.activeService`

The name of a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) that you created to route traffic to your application.

{{< prism lang="yaml"  line-numbers="true" >}}
strategies:
  <strategy>:
    blueGreen:
      activeService: <active-service>
{{< /prism >}}

#### `strategies.<strategyName>.blueGreen.previewService`

(Optional) The name of a [Kubernetes Service object](https://kubernetes.io/docs/concepts/services-networking/service/) you created to route traffic to the new version of your application so you can preview your updates.

{{< prism lang="yaml"  line-numbers="true" >}}
strategies:
  <strategy>:
    blueGreen:
      previewService: <preview-service>
{{< /prism >}}

#### `strategies.<strategyName>.blueGreen.redirectTrafficAfter`

The `redirectTrafficAfter` steps are conditions for exposing the new version to the `activeService`. The steps are executed in parallel. After each step completes, Armory CD-as-a-Service exposes the new version to the `activeService`.

##### `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause`

There are two base behaviors you can set for `pause`, either a set amount of time or until a manual judgment is made.

{{< prism lang="yaml"  line-numbers="true" >}}
redirectTrafficAfter:
  - pause:
      duration: <integer>
      unit: <seconds|minutes|hours>
{{< /prism >}}

{{< prism lang="yaml"  line-numbers="true" >}}
redirectTrafficAfter:
  - pause:
      untilApproved: true
      approvalExpiration:
        duration: 60
        unit: seconds
{{< /prism >}}

**Pause for a set amount of time**

If you want the deployment to pause for a certain amount of time, you must provide both the amount of time (duration) and the unit of time (unit).

- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.duration`
  - Use an integer value for the amount of time.
- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.unit`
  - Use `seconds`, `minutes` or `hours` for unit of time.

For example, this snippet instructs Armory CD-as-a-Service to wait for 30 minutes:

{{< prism lang="yaml"  line-numbers="true" >}}
redirectTrafficAfter:
  - pause:
      duration: 30
      unit: minutes
{{< /prism >}}

**Pause until a manual judgment**

When you configure a manual judgment, the deployment waits for manual approval through the UI. You can either approve the deployment or roll the deployment back if something doesn't look right. Do not provide a `duration` or `unit` value when defining a judgment-based pause.

- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.untilApproved: true`
- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.requiresRole` (Optional) list of RBAC roles that can issue a manual approval
- `strategies.<strategyName>.blueGreen.redirectTrafficAfter.pause.approvalExpiration` (Optional) time to wait for the approval - if expired, current deployment is cancelled
- 
For example:

{{< prism lang="yaml"  line-numbers="true" >}}
redirectTrafficAfter:
  - pause:
      untilApproved: true
      requiresRoles: []
      approvalExpiration:
        duration: 60
        unit: minutes
{{< /prism >}}

##### `strategies.<strategyName>.blueGreen.redirectTrafficAfter.analysis`

The `analysis` step is used to run a set of queries against your deployment. Based on the results of the queries, the deployment can (automatically or manually) roll forward or roll back.

{{< prism lang="yaml"  line-numbers="true" >}}
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
{{< /prism >}}

#### `strategies.<strategyName>.blueGreen.shutdownOldVersionAfter`

This step is a condition for deleting the old version of your software. Armory CD-as-a-Service executes the `shutDownOldVersion` steps in parallel. After each step completes, Armory CD-as-a-Service deletes the old version.

{{< prism lang="yaml"  line-numbers="true" >}}
shutdownOldVersionAfter:
  - pause:
      untilApproved: true
{{< /prism >}}

##### `strategies.<strategyName>.blueGreen.shutdownOldVersionAfter.analysis`

The `analysis` step is used to run a set of queries against your deployment. Based on the results of the queries, the deployment can (automatically or manually) roll forward or roll back.

{{< prism lang="yaml"  line-numbers="true" >}}
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
{{< /prism >}}

#### `strategies.<strategyName>.blueGreen.redirectTrafficAfter.exposeServices`

{{< include "deploy/preview-link-details.md" >}}
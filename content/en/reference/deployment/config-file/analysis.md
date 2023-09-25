---
title: Analysis Config
weight: 6
description: >
  Declare the queries used to analyze a deployment for any `analysis` steps. Includes defaultMetricProviderName and queries (name, upperLimit, lowerLimit, queryTemplate).
---

## Analysis section

```yaml
analysis: 
  defaultMetricProviderName: <providerName>
  queries:
    - name: <queryName>
      upperLimit: <integer>
      lowerLimit: <integer>
      queryTemplate: >-
        <some-metrics-query>
```

This block defines the queries used to analyze a deployment for any `analysis` steps. In addition, you set upper and lower limits for the queries that define what is considered a failed deployment step or a successful deployment step. You can provide multiple queries in this block. 

## Provider name

`analysis.defaultMetricProviderName`

The name that you assigned to a metrics provider in the **Configuration UI**. If the analysis step does not specify a metrics provider, the default metrics provider is used.

## Queries

`analysis.queries`

In this block, you define the queries that you want to run.

### Query name

`analysis.queries.name`

Used in `analysis` steps to specify the query that you want to use for the step. Specifically it's used for the list in `steps.analysis.queries`.

Provide a unique and descriptive name for the query, such as `containerCPUSeconds` or `avgMemoryUsage`.

### Upper limit

`analysis.queries.upperLimit`

The upper limit for the query. If the analysis returns a value that is above this range, the deployment is considered a failure, and a rollback is triggered. The rollback can happen either manually or automatically depending on how you configured `strategies.<strategyName>.<strategy>.steps.analysis.rollBackMode`.

If the query returns a value that falls within the range between the `upperLimit` and `lowerLimit` after all the runs of the query complete, the query is considered a success.

### Lower limit

`analysis.queries.lowerLimit`

The lower limit for the query. If the analysis returns a value that is below this range, the deployment is considered a failure, and a rollback is triggered. The rollback can happen either manually or automatically depending on how you configured `strategies.<strategyName>.<strategy>.steps.analysis.rollBackMode`.

If the query returns a value that falls within the range between the `upperLimit` and `lowerLimit` after all the runs of the query, the query is considered a success.

### Query template

`analysis.queries.queryTemplate`

```yaml
analysis: # Define queries and thresholds used for automated analysis
  queries:
    - name: <queryName>
      upperLimit: <integer> # If the metric exceeds this value, the automated analysis fails.
      lowerLimit: <integer> # If the metric goes below this value, the automated analysis fails.
      queryTemplate: >-
        <some-metrics-query>
```

You can insert variables into your queries using the format `{{key}}`. The example query includes the variable `armory.replicaSetName`. Variables that Armory supports can be referenced by `{{armory.VariableName}}`. You can define custom variables and then using `{{context.VariableName}}`. 

The query you want to run. See the {{< linkWithTitle "canary-analysis/create-canary-queries.md" >}} guide for details on how to build and test queries using the UI.

For information about writing queries, see {{< linkWithTitle "reference/canary-analysis-query.md" >}}.

When writing queries, you can use key/value pairs that are passed as substitutions for variables to the queries.

CD-as-a-Service includes the following variables:

{{< include "armory-context-variables.md" >}}

You can supply your own variables by adding them to the `strategies.<strategyName>.<strategy>.steps.analysis.context`. When you use them in your query, include the `context` prefix. For example, if you create a variable named `owner`, you would use `{{context.owner}}` in your query.

## Example

The following example includes a sample Prometheus query. Note that the example requires the following:

- `kube-state-metrics.metricAnnotationsAllowList[0]=pods=[*]` must be set
- Your applications pods need to have the annotation `"prometheus.io/scrape": "true"`

```yaml
analysis: # Define queries and thresholds used for automated analysis
  defaultMetricProviderName: <providerName> # The name that you assigned a metrics provider in the Configuration UI.
  queries:
    - name: avgCPUUsage
      upperLimit: 100
      lowerLimit: 1
      queryTemplate: >-
        avg (avg_over_time(container_cpu_system_seconds_total{job="kubelet"}[{{armory.promQlStepInterval}}]) * on (pod)  group_left (annotation_app)
                  sum(kube_pod_annotations{job="kube-state-metrics",annotation_deploy_armory_io_replica_set_name="{{armory.replicaSetName}}"})
                  by (annotation_app, pod)) by (annotation_app)
                #,annotation_deploy_armory_io_replica_set_name="${canaryReplicaSetName}"})
                #${ARMORY_REPLICA_SET_NAME}
                #,annotation_deploy_armory_io_replica_set_name="${ARMORY_REPLICA_SET_NAME}"
                #${replicaSetName}
                #${applicationName}
                # note the time should actually be set to ${promQlStepInterval}
```

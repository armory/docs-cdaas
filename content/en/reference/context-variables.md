---
title: Context Variables Reference
linkTitle: Context Variables
description: >
  @TODO
categories: ["Reference"]
tags: ["Deployment", "Deploy Strategy", "Canary"]
---

### Armory-provided variables

Armory provides some metrics by default on all canary analysis requests. These variables are all prefixed with `armory` and are surrounded by `{{}}`. For example, to use `applicationName` variable that Armory supplies, you use the following snippet in the query template: `{{armory.applicationName}}`.

Armory provides the following variables:

| Variable                 | Annotation                          | Environment variable      | Notes                                                                       |
|--------------------------|-------------------------------------|---------------------------|-----------------------------------------------------------------------------|
| applicationName          | `deploy.armory.io/application`      | `ARMORY_APPLICATION_NAME` | Added as annotation resources and as environment variables on  pods*        |
| deploymentId             | `deploy.armory.io/deployment-id`    | `ARMORY_DEPLOYMENT_ID`    | Added as annotation resources and as environment variables on  pods*        |
| environmentName          | `deploy.armory.io/environment`      | `ARMORY_ENVIRONMENT_NAME` | Added as annotation resources and as environment variables on  pods*        |
| replicaSetName           | `deploy.armory.io/replica-set-name` | `ARMORY_REPLICA_SET_NAME` | Added as annotation resources and as environment variables on  pods*        |
| accountName              | -                                   | -                         | The name of the account (or agentIdentifier) used to execute the deployment |
| namespace                | -                                   | -                         | The namespace resources are being deployed to                               |
| promQlStepInterval       | -                                   | -                         | Used to aggregate PromQL functions to a single value                        |
| intervalSeconds          | -                                   | -                         | Length of the current query interval in seconds                             |
| intervalMillis           | -                                   | -                         | Length of the current query interval in milliseconds                        |
| endTimeEpochMillis       | -                                   | -                         | Exact end time of the current query interval in epoch milliseconds format   |
| endTimeEpochSeconds      | -                                   | -                         | Exact end time of the current query interval in epoch seconds format        |
| endTimeIso8601           | -                                   | -                         | Exact end time of the current query interval in ISO 8601 format             |
| startTimeEpochMillis     | -                                   | -                         | Exact start time of the current query interval in epoch milliseconds format |
| startTimeEpochSeconds    | -                                   | -                         | Exact start time of the current query interval in epoch seconds format      |
| startTimeIso8601         | -                                   | -                         | Exact start time of the current query interval in ISO 8601 format           |
| preview.`<service name>` | -                                   | -                         | URL to the `Service` resource exposed via `exposeServices` step**           |

`*`If you are using a metrics implementation like [Micrometer](https://micrometer.io/), make sure to configure it to report these metrics to your metrics provider.

`**`Service preview links are scoped to the strategy and `afterDeployment` constraints section. Do consider adjusting preview link's TTL property, otherwise you may end up 
serving links which have already expired. 


### Custom variables

In addition to the Armory provided variables, you can define additional custom ones. These are added to the `strategies.<strategyName>.canary.steps.analysis.context` section of your deployment file:

```
strategies:
  ...
    canary:
      steps:
        ...
        - analysis:
            ...
            context:
              - <variableName>: <variableValue>
```

They need to be defined for each analysis step that uses a query referencing them.

In query templates, you reference them with the following format: `{{context.<variableName>}}`. For example, if you created a variable called `owner`, you reference it in the query template with `{{context.owner}}`.

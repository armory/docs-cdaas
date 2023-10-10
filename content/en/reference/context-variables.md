---
title: Context Variables Reference
linkTitle: Context Variables
weight: 10
description: >
  Reference for context variables that you can use in your deployment config file.
categories: ["Reference"]
tags: ["Deployment", "Context Variables", "Canary"]
---

## Variables included with CD-as-a-Service

Armory provides some metrics by default on all canary analysis requests. These variables are all prefixed with `armory` and are surrounded by `{{}}`. For example, to use `applicationName` variable that Armory supplies, you use the following snippet in the query template: `{{armory.applicationName}}`.

CD-as-a-Service includes the following variables:

{{< include "armory-context-variables.md" >}}

## Custom variables

You can also define custom variables. These are added to the `strategies.<strategyName>.canary.steps.analysis.context` section of your deployment file:

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

You need to define the variables in each analysis step that uses a query referencing them.

In query templates, you reference them with the following format: `{{context.<variableName>}}`. For example, if you created a variable called `owner`, you reference it in the query template with `{{context.owner}}`.

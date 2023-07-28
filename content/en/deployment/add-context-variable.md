---
title: Add New Context Variables at Deploy Time
linktitle: Add Context Variables at Deploy Time
weight: 10
description: >
  Add new context variables from the command line or in the Armory CD-as-a-Service GitHub Action. CD-as-a-Service injects these variables into your canary analysis and webhook triggers.
categories: ["Deployment", "Guides"]
tags: ["Deploy Config", "Context Variables"]
---

## How to add new context variables

You can add new context variables at deployment time by using the `--add-context` argument on the command line or from within your [Armory CD-as-a-Service GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}). CD-as-a-Service adds the new context variables to webhook triggers and canary analysis steps in any deployment constraint.

The value of the `--add-context` argument is a comma-delimited list of key=value pairs.

For this example, you want to add the following new context variables:

| Name        | Value      |
| ----------- | ---------- |
| smokeTest   | true       |
| environment | prod       |
| changeBy    | jane-smith |


Your command line looks like this:

```bash
armory deploy start -f deploy.yml --add-context=smokeTest=true,environment=prod,changeBy=jane-doe
```

In your GitHub Action, you add an `addContext` key in your `Deployment` step.

{{< highlight yaml "linenos=table, hl_lines=22" >}}
name: Deploy my latest version

on:
  push:
    branches:
      - main  

jobs:
  build:
    name: deploy from main
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Deployment
        uses: armory/cli-deploy-action@main
        with:
          clientId: "${{ secrets.CDAAS_CLIENT_ID }}"
          clientSecret:  "${{ secrets.CDAAS_CLIENT_SECRET }}"
          path-to-file: "/deploy.yml"
          addContext: "smokeTest=true,environment=prod,changeBy=jane-doe"
          applicationName: "potato-facts"
{{< /highlight >}}

## Known issues

Context variables are not added in the following situations:

* An `analysis` step when used in an after deployment constraint
* A step in a blue/green deployment strategy


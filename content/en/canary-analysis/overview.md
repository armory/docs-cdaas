---
title: Canary Analysis Overview
linktitle: Overview
weight: 1
description: >
  Learn how to construct retrospective analysis queries that you can then use for your canary strategy.
categories: ["Canary Analysis", "Features", "Concepts"]
tags: ["Deploy Strategy", "Canary", "Retrospective Analysis"]
---

## What is retrospective analysis?

Retrospective analysis is the starting point to creating queries so that you can perform canary analysis on your deployments. The UI gives you a structured way to create a query and test it against previous deployments. When ready, you can export it so that you can add the query to your deploy file easily.

Use the **Retrospective Analysis** UI to help you to construct queries. You can then test those queries by running them against previous deployments. Once you've created a query that meets your needs, export it to generate YAML that you can use in your deploy file.

## {{% heading "nextSteps" %}}

* [Integrate your metrics provider]({{< ref "canary-analysis/integrate-metrics-provider" >}}) so you can begin creating retrospective analysis queries.
* [Construct retrospective analysis queries]({{< ref "canary-analysis/create-canary-queries" >}}).
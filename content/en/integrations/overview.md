---
title: Integrations Overview
linkTitle: Overview
weight: 1
description: >
  
categories: ["Integrations", "Features", "Concepts"]
tags: ["CI Systems", "GitHub", "Automation"]
---

## Armory integrations

Armory provides and supports the following:

* The [Armory Continuous Deployment-as-a-Service GitHub Action]({{< ref "integrations/ci-systems/gh-action" >}}) enables triggering deployments from your GitHub repo.
* The [Spinnaker plugin](https://docs.armory.io/plugins/cdaas-spinnaker/) provides a stage in which you can configure a blue/green or canary deployment that uses CD-as-a-Service.

## Generic CI systems

You can trigger deployments from any CI system. 

1. Install the [CD-as-a-Service CLI]({{< ref "cli" >}}) natively or run it in Docker.

   <details><summary>Show me how</summary>
   {{< include "cli/install-cli-tabpane" >}}
   </details>
1. [Create machine to machine credentials]({{< ref "cli" >}}) to use in your CI system job. 

   <details><summary>Show me how</summary>
   {{< include "client-creds.md" >}}
   </details>

1. [Pass these credentials]({{< ref "deployment/deploy-with-creds" >}}) to the CLI when starting a deployment.

   <details><summary>Show me how</summary>

   ```yaml
   armory deploy start  -c <your-client-id> -s <your-client-secret> -f <your-deploy.yaml>
   ```
   
   </details>
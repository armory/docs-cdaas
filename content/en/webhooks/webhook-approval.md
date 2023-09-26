---
title: Configure External Automation (Webhook-Based) Approval in your Deployment Config File
linkTitle: Configure Approval
weight: 5
description: >
  Configure external automation (webhook-based) approval in your Armory CD-as-a-Service app deployment process.
categories: ["Webhooks", "Features", "Guides"]
tags: ["Webhooks", "GitHub", "Automation"]
---

## {{% heading "prereq" %}}

You have read the [External Automation Overview guide]({{< ref "webhooks/overview.md" >}}), which explains how webhook-based approval works in CD-as-a-Service.

In order to configure webhook-based approval, you should have the following:

1. The URL to trigger your external job
1. [Client Credentials (Client ID and Client Secret)]({{< ref "iam/manage-client-creds.md" >}}) with **Deployments Full Access** permission. You need these to fetch an OATH token to use in the callback that sends the job result to CD-as-a-Service.

   <details><summary>Show me how</summary>
   {{< include "client-creds.md" >}}
   </details>

## Steps to use webhook-based approval

1. [Create your external job](#create-your-external-job) and note the URL to trigger the job

   * Your job does not have to be accessible from the internet. CD-as-a-Service can use your Remote Network Agent as a proxy.
   * You can send context variables from CD-as-a-Service to your job.
   * The job result should be a boolean pass or fail.
1. [Configure the webhook](#configure-the-webhoook-in-your-deployment-config-file) in your deployment config file.

   * You define the `callbackUri` that CD-as-a-Service passes in the request to trigger your job.
   * You can include context variables for CD-as-a-Service to pass to your job.
1. [Configure your external job](#configure-your-external-jobs-callback) to send the result to CD-as-a-Service.

   * Extract the `callbackUri`.   
   * Fetch an OAUTH token from CD-as-a-Service.
   * Send the job result to the callback URI, including the OAUTH token.

## Create your external job

How you create your job varies from system to system and is beyond the scope of this guide.  

A few things to keep in mind:

* You can send send context variables from CD-as-a-Service to your job.
* The result that you send to CD-as-a-Service is a boolean. See the [Configure your external job](#configure-your-external-job) section later in this guide for callback format.

## Configure the webhoook in your deployment config file

In your deployment file, you configure your webhook by adding a top-level `webhooks` section with the following information:

{{< include "dep-file/webhooks-config.md" >}}

### Webhooks context variables

{{< include "webhooks-context-variables.md" >}}

### Configuration examples

The first example configures a GitHub webhook that uses token authorization, with the token value configured as a CD-as-a-Service secret. This webhook requires you to pass the callback URI in the request body. The payload also contains context variables that you pass in when invoking the webhook in your deployment file.

{{< highlight yaml "linenos=table, hl_lines=8 16-17" >}}
webhooks:
  - name: myWebhook
    method: POST
    uriTemplate: https://api.github.com/repos/armory/docs-cdaas-sample/dispatches
    networkMode: direct
    headers:
      - key: Authorization
        value: token {{secrets.github_token}}
      - key: Content-Type
        value: application/json
    bodyTemplate:
      inline:  >-
        {
        "event_type": "webhookCallback",
        "client_payload": {
            "callbackUri": "{{armory.callbackUri}}/callback"
            "environment": "{{armory.environmentName}}"
            "applicationName": "{{armory.applicationName}}"
            "replicaSetName": "{{armory.replicaSetName}}"
            }
        }
    retryCount: 3
{{< /highlight >}}
</br>

The second example configures a webhook that is not accessible from the internet. The `networkMode` is set to `remoteNetworkAgent` and the `agentIdentifier` specifies which Remote Network Agent to use. The `agentIdentifier` value must match the **Agent Identifier** value listed on the **Agents** UI screen. The Authorization Bearer value is configured as a CD-as-a-Service secret. Note that in this example, the callback URI is passed in the header.

{{< highlight yaml "linenos=table, hl_lines=5-6 9 11" >}}
webhooks:
  - name: integration-tests
    method: POST
    uriTemplate: https://integrations.armory.io/tests/
    networkMode: remoteNetworkAgent
    agentIdentifier: test-rna
    headers:
      - key: Authorization
        value: Bearer {{secrets.test_token}}
      - key: CallbackURI
        value: {{armory.callbackUri}}/callback
      - key: Content-Type
        value: application/json
      - key: environment
        value: {{context.environment}}
      - key: applicationName
        value: {{armory.applicationName}}
      - key: replicaSetName
        value: {{armory.replicaSetName}}
    retryCount: 5
{{< /highlight >}}


### Trigger a webhook

You can trigger a webhook from the following areas:

- Deployment constraints: `beforeDeployment` and `afterDeployment`
- A canary step within a canary strategy
- The `redirectTrafficAfter` section of a blue/green strategy

You add a `runWebhooks` section where you want to trigger the webhook.

```yaml
- runWebhook:
    name: <webhook-name>
    context:
        myCustomKey: myCustomValue
```

- `name`: (Required) webhook name; must match the name you gave your webhook in the `webhooks` configuration section.
- `context`: (Optional) dictionary; declare values to use in templates or headers.

#### Deployment constraints

**Before deployment**

In this example, you have a webhook named `Update-Database-Schema`. You want to trigger this webhook before your app gets deployed. So you trigger the webhook in the `beforeDeployment` constraint of your environment deployment.

{{< highlight yaml "linenos=table, hl_lines=8-9" >}}
targets:
  dev:
    account: dev-cluster
    namespace: myApp-dev
    strategy: rolling-canary
    constraints:
      beforeDeployment:
        - runWebhook:
            name: Update-Database-Schema
{{< /highlight >}}

App deployment proceeds only if the `Update-Database-Schema` callback sends a "success: true" message.

**After deployment**

In this example, you have a webhook named `Run-Integration-Tests`. You want to trigger this webhook after your app has been deployed to staging but before it gets deployed to production. So you trigger the webhook in the `afterDeployment` constraint of your staging environment deployment.

{{< highlight yaml "linenos=table, hl_lines=8-11" >}}
targets:
  staging:
    account: staging-cluster
    namespace: myApp-staging
    strategy: rolling-canary
    constraints:
      afterDeployment:
        - runWebhook:
            name: Run-Integration-Tests
            context:
              environment: staging
  prod:
    account: prod-cluster
    namespace: myApp-prod
    strategy: rolling-canary
    constraints:
      dependsOn: ["staging"]
{{< /highlight >}}

Deployment to production proceeds only if the `Run-Integration-Tests` callback sends a "success: true" message.

#### Blue/Green strategy

In this example, there is a `security-scan` webhook that scans your deployed app. You have a blue/green deployment strategy in which you want to run that security scan on the preview version of your app before switching traffic to it. You add the `runWebhook` section to the `redirectTrafficAfter` section in your blue/green strategy configuration.

{{< highlight yaml "linenos=table, hl_lines=15-16" >}}
strategies:
  myBlueGreen:
    blueGreen:
      activeService: myApp-external
      previewService: myApp-preview
      redirectTrafficAfter:
        - analysis:
            interval: 7
            units: seconds
            numberOfJudgmentRuns: 1
            rollBackMode: manual
            rollForwardMode: automatic
            queries:
              - avgCPUUsage-pass
        - runWebhook:
            name: security-scan
{{< /highlight >}}

Since tasks in the `redirectTrafficAfter` section run in parallel, both tasks in this example must be successful for deployment to continue. If the `analysis` task fails, rollback is manual. If the `runWebhook` task fails, rollback is automatic.

#### Canary strategy

In this example, there is a `system-health` webhook that you want to trigger as part of your canary strategy. Add the `runWebhook` section to your `steps` configuration.

{{< highlight yaml "linenos=table, hl_lines=7-10" >}}
strategies:
  canary-rolling:
    canary:
      steps:
        - setWeight:
            weight: 25
        - runWebhook:
            name: system-health
            context:
              environment: staging
{{< /highlight >}}

## Configure your external job's callback

After you have configured your webhook in your deployment config file, you should configure the callback in your job.

1. Extract the callback URI from the HTTP Request that CD-as-a-Service sent to trigger your job. How you do this depends on what external automation tool you use.
1. Fetch an OAUTH token from CD-as-a-Service.

   Replace `<CLIENT-ID>` and `<CLIENT-SECRET>` with your values.

   Request format:

   ```bash
    curl --request POST \
    --url https://auth.cloud.armory.io/oauth/token \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data data=audience=https://api.cloud.armory.io \
    --data grant_type=client_credentials \
    --data client_id=<CLIENT-ID> \
    --data client_secret=<CLIENT-SECRET>
   ```

   Example response:

   ```json
   {
   "access_token": "<very long access token>",
   "expires_in": 86400,
   "token_type": "Bearer"
   }
   ```

1. Configure the callback

   ```bash
   curl --request POST \
   --url '<CALLBACK-URI>' \
   --header 'Authorization: Bearer <OAUTH_TOKEN>' \
   --header 'Content-Type: application/json' \
   --data '{"success": <true|false>, "mdMessage": "<MESSAGE>"}'
   ```

   - `<CALLBACK-URI>`: Replace with the callback URI you extracted from the HTTP Request that CD-as-a-Service sent to trigger your job.
   - ` <OAUTH_TOKEN>`: Replace with the OAUTH token you fetched from CD-as-a-Service.
   - `data` dictionary job outcome: CD-as-a-Service looks for a `success` value of true or false to determine the webhook’s success or failure. `mdMessage` should contain a user-friendly message for CD-as-a-Service to display in the UI and write to logs.

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "tutorials/tutorial-webhook-github.md" >}}
* [Webhooks section]({{< ref "reference/deployment/config-file/webhooks" >}}) in the deployment config file reference
* {{< linkWithTitle "troubleshooting/webhook.md" >}}

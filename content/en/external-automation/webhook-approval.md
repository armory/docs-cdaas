---
title: Configure Webhook-Based Approval in the Deployment Config File
linkTitle: Configure Webhook Approval
weight: 5
description: >
  Configure external automation (webhook-based approval) in your Armory CD-as-a-Service app deployment process.
categories: ["Webhooks", "Features", "Guides"]
tags: ["Webhooks", "GitHub", "Automation"]
---

## {{% heading "prereq" %}}

You have read {{< linkWithTitle "external-automation/overview.md" >}}, which explains how webhook-based approval works in CD-as-a-Service.

In order to configure webhook-based approval, you should have the following:

1. The URL of your webhook
1. [Client Credentials (Client ID and Client Secret)]({{< ref "iam/manage-client-creds.md" >}}) with **Deployments Full Access** permission. You need these to fetch an OATH token to use in the callback that sends the webhook result to CD-as-a-Service.

   <details><summary>Show me how</summary>
   {{< include "client-creds.md" >}}
   </details>
1. 


## Steps to use webhook-based approval

1. Configure your external automation job


## Configure your external automation job

Your external automation job needs to perform these tasks:

1. Fetch an OAUTH token and callback URI from CD-as-a-Service.

   You need to include your Client ID and Client Secret.

   {{< prism lang="bash"  line-numbers="true" >}}
   curl --request POST \
    --url https://auth.cloud.armory.io/oauth/token \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data "data=audience=https://api.cloud.armory.io&grant_type=client_credentials&client_id=$CDAAS_CLIENT_ID&client_secret=$CDAAS_CLIENT_SECRET"
   {{< /prism >}}



1. Use the callback URI and token to send a the job outcome to CD-as-a-Service.

   - The callback must use Bearer authorization and include a success value and optional message in the body.




## How to retrieve an OAUTH token to use in your callback

Request format:



Example response:

{{< prism lang="json"  line-numbers="true" >}}
{
  "access_token": "<very long access token>",
  "scope": "manage:deploy read:infra:data exec:infra:op read:artifacts:data",
  "expires_in": 86400,
  "token_type": "Bearer"
}
{{< /prism >}}

### Callback format

{{< prism lang="bash"  line-numbers="true" >}}
curl --request POST \
  --url 'https://$CALLBACK_URI' \
  --header 'Authorization: Bearer $OAUTH_TOKEN' \
  --header 'Content-Type: application/json' \
  --data '{"success": true, "mdMessage": "Webhook successful"}'
{{< /prism >}}

CD-as-a-Service looks for `success` value of `true` or `false` to determine the webhook's success or failure. `mdMessage` should contain a user-friendly message for CD-as-a-Service to display in the UI and write to logs.

## How to configure a webhook in your deployment file

In your deployment file, you configure your webhook by adding a top-level `webhooks` section with the following information:

{{< include "dep-file/webhooks-config.md" >}}

### Configuration examples

The first example configures a GitHub webhook that uses token authorization, with the token value configured as a CD-as-a-Service secret. This webhook requires you to pass the callback URI in the request body. The payload also contains context variables that you pass in when invoking the webhook in your deployment file.

{{< prism lang="yaml" line-numbers="true" line="8, 16-17" >}}
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
{{< /prism >}}
</br>

The second example configures a webhook that is not accessible from the internet. The `networkMode` is set to `remoteNetworkAgent` and the `agentIdentifier` specifies which Remote Network Agent to use. The `agentIdentifier` value must match the **Agent Identifier** value listed on the **Agents** UI screen. The Authorization Bearer value is configured as a CD-as-a-Service secret. Note that in this example, the callback URI is passed in the header.

{{< prism lang="yaml" line-numbers="true" line="5-6, 9, 11" >}}
webhooks:
  - name: integration-tests
    method: POST
    uriTemplate: https://integrations.armory.io/tests/
    networkMode: remoteNetworkAgent
    agentIdentifier: test-rna
    headers:
      - key: Authorization
        value: Bearer {{secrets.test_token}}
      - key: Location
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
{{< /prism >}}


## How to trigger a webhook

You can trigger a webhook from the following areas:

- Deployment constraints: `beforeDeployment` and `afterDeployment`
- A canary step within a canary strategy
- The `redirectTrafficAfter` section of a blue/green strategy

You add a `runWebhooks` section where you want to trigger the webhook.

{{< prism lang="yaml" line-numbers="true" >}}
- runWebhook:
    name: <webhook-name>
    context: 
        myCustomKey: myCustomValue
{{< /prism >}}

- `name`: (Required) webhook name; must match the name you gave your webhook in the `webhooks` configuration section.
- `context`: (Optional) dictionary; declare values to use in templates or headers.

### Deployment constraints

**Before deployment**

In this example, you have a webhook named `Update-Database-Schema`. You want to trigger this webhook before your app gets deployed. So you trigger the webhook in the `beforeDeployment` constraint of your environment deployment.

{{< prism lang="yaml" line-numbers="true" line="8-9" >}}
targets:
  dev:
    account: dev-cluster
    namespace: myApp-dev
    strategy: rolling-canary
    constraints:
      beforeDeployment:
        - runWebhook:
            name: Update-Database-Schema
{{< /prism >}}

App deployment proceeds only if the `Update-Database-Schema` callback sends a "success: true" message.

**After deployment**

In this example, you have a webhook named `Run-Integration-Tests`. You want to trigger this webhook after your app has been deployed to staging but before it gets deployed to production. So you trigger the webhook in the `afterDeployment` constraint of your staging environment deployment.

{{< prism lang="yaml" line-numbers="true" line="8-11" >}}
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
{{< /prism >}}

Deployment to production proceeds only if the `Run-Integration-Tests` callback sends a "success: true" message.

### Blue/green strategy

In this example, there is a `security-scan` webhook that scans your deployed app. You have a blue/green deployment strategy in which you want to run that security scan on the preview version of your app before switching traffic to it. You add the `runWebhook` section to the `redirectTrafficAfter` section in your blue/green strategy configuration.

{{< prism lang="yaml" line-numbers="true" line="15-16" >}}
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
{{< /prism >}}

Since tasks in the `redirectTrafficAfter` section run in parallel, both tasks in this example must be successful for deployment to continue. If the `analysis` task fails, rollback is manual. If the `runWebhook` task fails, rollback is automatic.

### Canary strategy

In this example, there is a `system-health` webhook that you want to trigger as part of your canary strategy. Add the `runWebhook` section to your `steps` configuration.

{{< prism lang="yaml" line-numbers="true" line="7-10" >}}
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
{{< /prism >}}


## {{% heading "nextSteps" %}}

* [Webhooks section in the deployment file reference]({{< ref "reference/deployment/config-file/webhooks" >}})
* {{< linkWithTitle "tutorials/tutorial-webhook-github.md" >}}
* {{< linkWithTitle "troubleshooting/webhook.md" >}}
 
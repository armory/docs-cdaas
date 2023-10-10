You can use variables in the webhook templates you define in the `webhooks` block of your deployment for the follow fields: `webhooks.[].uriTemplate`, `webhooks.[].headers`, and `webhooks.[].bodyTemplate`. 

**Armory-provided context variables**

Armory provides the following variables for every webhook execution: 

| Variable                 | Annotation                          | Environment variable      | Notes                                                                       |
|--------------------------|-------------------------------------|---------------------------|-----------------------------------------------------------------------------|
| applicationName          | `deploy.armory.io/application`      | `ARMORY_APPLICATION_NAME` | Added as annotation resources and as environment variables on  pods*        |
| deploymentId             | `deploy.armory.io/deployment-id`    | `ARMORY_DEPLOYMENT_ID`    | Added as annotation resources and as environment variables on  pods*        |
| environmentName          | `deploy.armory.io/environment`      | `ARMORY_ENVIRONMENT_NAME` | Added as annotation resources and as environment variables on  pods*        |
| replicaSetName           | `deploy.armory.io/replica-set-name` | `ARMORY_REPLICA_SET_NAME` | Added as annotation resources and as environment variables on  pods*        |
| accountName              | -                                   | -                         | The name of the account (or agentIdentifier) used to execute the deployment |
| namespace                | -                                   | -                         | The namespace resources are being deployed to                               |

Prefix the variable with `armory` and surround with `{{}}`. For example, to use `applicationName`, add `{{armory.applicationName}}` to the webhook query template.

**Custom context variables**

Add your custom variables to the `strategies.<strategyName>.canary.steps.runWebhook.context` section of your deployment file:

```
strategies:
  ...
    canary:
      steps:
        ...
        - runWebhook:
            name: <webhookName>
            ...
            context:
              <variableName>: <variableValue>
```

You need to configure your custom variables for each webhook step that references them.

In supported webhook fields, you reference them with the following format: `{{context.<variableName>}}`. For example, if you create a variable called `uri` for `webhooks.[].uriTemplate`, you reference it in `webhooks.[].bodyTemplate` with `{{context.uri}}`, so that `uriTemplate: {{context.uri}}` is the address the webhook calls.
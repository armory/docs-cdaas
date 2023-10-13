---
title: Targets Config
description: >
  Declare your deployment targets: account, namespace, and strategy to use. Configure target constraints such as `dependsOn`, `beforeDeployment`, and `afterDeployment` with pause, webhoook, and analysis conditions.
---


## Targets config overview

In the `targets.` config block, you define where and how you want to deploy an app. You can specify multiple targets. Provide unique descriptive names for each environment to which you are deploying.

```yaml
targets:
  <targetName>:
    account: <accountName>
    namespace: <namespaceOverride>
    strategy: <strategyName>
    constraints: <mapOfConstraints>
```

## Name

`targets.<targetName>`: A descriptive name for this deployment, such as the name of the environment you want to deploy to.

For example, this snippet configures a deployment target with the name `prod`:

```yaml
targets:
  prod:
...
```

## Account (cluster)

`targets.<targetName>.account`: The account name that a target Kubernetes cluster got assigned when you installed the Remote Network Agent (RNA) on it. Specifically, it is the value for the `agentIdentifier` parameter. Note that older versions of the RNA used the `agent-k8s.accountName` parameter.

This name must match an existing cluster because Armory CD-as-a-Service uses the identifier to determine which cluster to deploy to.

For example, this snippet configures a deployment to an environment named `prod` that is hosted on a cluster named `prod-cluster-west`:

```yaml
targets:
  prod:
    account: prod-cluster-west
...
```

## Namespace

`targets.<targetName>.namespace`

Optional but recommended

The namespace on the target Kubernetes cluster that you want to deploy to. This field overrides any namespaces defined in your manifests.

For example, this snippet overrides the namespace in your manifest and deploys the app to a namespace called `overflow`:

```yaml
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
```

## Strategy

`targets.<targetName>.strategy`: This is the name of the strategy that you want to use to deploy your app. You define the strategy and its behavior in the `strategies` block.

For example, this snippet configures a deployment to use the `canary-wait-til-approved` strategy:

```yaml
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
```

Read more about how this config is defined and used in the [strategies]({{< ref "reference/deployment/config-file/strategies" >}}) section.

## Constraints

Optional

`targets.<targetName>.constraints`

`constraints` is a map of conditions that must be met before a deployment starts. The constraints can be dependencies on previous deployments, such as requiring deployments to a test environment before staging, or a pause. If you omit the constraints section, the deployment starts immediately when it gets triggered.

> Constraints are evaluated in parallel.

```yaml
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["<targetName>"]
      beforeDeployment:
        - pause:
            untilApproved: true
        - pause:
            duration: <integer>
            unit: <seconds|minutes|hours>
      afterDeployment:
        - runWebhook:
            name: <webhook-name>
```

### Depends on

Optional

`targets.<targetName>.constraints.dependsOn`: A comma-separated list of deployments that must finish before this deployment can start. You can use this option to sequence deployments. Deployments with the same `dependsOn` criteria execute in parallel. For example, you can make it so that a deployment to prod cannot happen until a staging deployment finishes successfully.

The following example shows a deployment to `prod-west` that cannot start until the `dev-west` target finishes:

```yaml
targets:
  prod:
    account: prod-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev-west"]
```

### Before and after deployment

Optional

`targets.<targetName>.constraints.beforeDeployment`: Add conditions that must be met before the deployment can start. These are in addition to the deployments you define in `dependsOn` that must finish. If a `beforeDeployment` condition fails, CD-as-a-Service does not deploy to this target or subsequent targets.

`targets.<targetName>.constraints.afterDeployment`: Add conditions that must be met before deployment to this target is considered finished. These constraints are executed after deployment to this target but before deployment to the next target (or before deployment is considered done). If an `afterDeployment` condition fails, CD-as-a-Service does not roll back this target and does not deploy to subsequent targets.

`beforeDeployment` and `afterDeployment` support `pause`, `runWebhook`, and `analysis` conditions.

#### Pause

You can specify a pause that waits for a manual approval or a certain amount of time before starting. 

**Pause until manual approval**

```yaml
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev-west"]
      beforeDeployment:
        - pause:
            untilApproved: true 
            requiresRoles: []
            approvalExpiration:
              duration: 60
              unit: seconds
```

- `pause.untilApproved`: Set to true
- `pause.requiresRoles`: (Optional) List of RBAC roles that can issue a manual approval
- `pause.approvalExpiration`: (Optional) Timeout configuration; when expired the ongoing deployment is cancelled 

**Pause for a certain amount of time**

```yaml
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev-west"]
      beforeDeployment:
        - pause:
            duration: 60
            unit: seconds
```

- `pause.duration` set to an integer value for the amount of time to wait before starting after the `dependsOn` condition is met.
- `pause.unit` set to `seconds`, `minutes` or `hours` to indicate the unit of time to wait.

#### Run a webhook

In the following example, before deploying to the `prod-cluster-west` target, CD-as-a-Service pauses deployment for manual approval by an Org Admin and also calls a webhook that sends a Slack notification. You declare the webhook in the [webhooks section]

```yaml
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
            requiresRoles:
              - Organization Admin
            approvalExpiration:
              duration: 24
              unit: hours
        - runWebhook:
            name: Send_Slack_Deployment_Approval_Required
```

#### Analysis

In this example, CD-as-a-Service performs a [canary analysis]({{< ref "reference/canary-analysis-query" >}}) after deploying to the target. You declare your query in the [analysis section]{{< ref "reference/deployment/config-file/analysis" >}} and then add the name to the `queries` list.

```yaml
targets:
  staging:
    account: staging-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev"]
      afterDeployment:
        - analysis:
            metricProviderName: <metric-provider-name>
            interval: 10
            units: seconds
            numberOfJudgmentRuns: 3
            rollBackMode: manual
            rollForwardMode: manual
            queries:
              - avgCPUUsage
```

## Example

In this example, there are four targets: `dev`,  `infosec`, `staging`, and `prod-west`. After you deploy code to `infosec` and `staging`, you want to run jobs against those targets. If either of those jobs fails, CD-as-a-Service does not deploy to `prod-west`.

`prod-west`'s `afterDeployment` conditions perform an analysis and call a webhook that sends a "deployment complete" notification. If the `analysis` condition fails, CD-as-a-Service rolls back the target deployment.

```yaml
targets:
  dev:
    account: demo-dev-cluster
    namespace: cdaas-dev
    strategy: rolling
  infosec:
    account: demo-staging-cluster
    constraints:
      afterDeployment:
        - runWebhook:
            name: Security_Scanners
      dependsOn:
        - dev
    namespace: cdaas-infosec
    strategy: rolling
  staging:
    account: demo-staging-cluster
    constraints:
      afterDeployment:
        - runWebhook:
            name: Integration_Tests
      dependsOn:
        - dev
    namespace: cdaas-staging
    strategy: rolling
  prod-west:
    account: demo-prod-west-cluster
    constraints:
      beforeDeployment:
        - pause:
            requiresRoles:
              - Organization Admin
            untilApproved: true
        - runWebhook:
            name: Send_Slack_Deployment_Approval_Required
      afterDeployment:
        - analysis:
            interval: 10
            units: seconds
            numberOfJudgmentRuns: 3
            rollBackMode: manual
            rollForwardMode: manual
            queries:
              - avgCPUUsage
        - runWebhook:
            name: Send_Slack_Deployment_Complete            
      dependsOn:
        - infosec
        - staging
    namespace: cdaas-prod
    strategy: mycanary
```


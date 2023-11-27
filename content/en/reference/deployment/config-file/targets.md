---
title: Targets Config
description: >
  Declare your Kubernetes or AWS Lambda deployment targets.
---


## Targets config overview

In the `targets.` config block, you define where and how you want to deploy your Kubernetes app or AWS Lambda function. 

You can specify multiple targets. Provide unique descriptive names for each target to which you are deploying.

{{< cardpane >}}
{{< card code=true lang="yaml" header="AWS Lambda" >}}
targets:
  <targetName>:
    account: <aws-account-name>
    deployAsIamRole: <armory-role-arn>
    region: <aws-region>
    strategy: <strategy-name>
    constraints: <constraints-collection>
{{< /card >}}
{{< card code=true  lang="yaml" header="Kubernetes" >}}
targets:
  <targetName>:
    account: <account-name>
    namespace: <namespace-override>
    strategy: <strategy-name>
    constraints: <constraints-collection>
{{< /card >}}
{{< /cardpane >}}

## Common fields

These fields are the same whether your target is AWS Lambda or a Kubernetes cluster.

### Name

`targets.<targetName>`: A descriptive name for this deployment, such as the name of the environment you want to deploy to.

For example, this snippet configures a deployment target with the name `prod`:

```yaml
targets:
  prod:
...
```

### Strategy

`targets.<targetName>.strategy`: This is the name of the strategy that you want to use to deploy your app. You define the strategy and its behavior in the `strategies` block.

For example, this snippet configures a deployment to use the `canary-wait-til-approved` strategy:

```yaml
targets:
  prod:
    account: prod-cluster-west
    strategy: canary-wait-til-approved
```

Read more about how this config is defined and used in the [strategies]({{< ref "reference/deployment/config-file/strategies" >}}) section.

## AWS Lambda fields

```yaml
<targetName>:
    account: <aws-account-name>
    deployAsIamRole: <armory-role-arn>
    region: <aws-region>
```

### Account (AWS)

`targets.<targetName>.account`: A descriptive name for your AWS Account.

```yaml
Prod-West-1:
    account: armory-docs-dev
```

### Deploy as IAM Role

`targets.<targetName>.deployAsIamRole`: The ARN of the [ArmoryRole]({{< ref "deployment/lambda/create-iam-role-lambda" 
 >}})
that CD-as-a-Service assumes to deploy your function.

```yaml
Prod-West-1:
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
```

### AWS Region

`targets.<targetName>.region`: The AWS Region to deploy your function to.

```yaml
Prod-West-1:
    region: us-west-1
```

## Kubernetes fields

### Account (cluster)

`targets.<targetName>.account`: The account name that a target Kubernetes cluster got assigned when you installed the Remote Network Agent (RNA) on it. Specifically, it is the value for the `agentIdentifier` parameter. Note that older versions of the RNA used the `agent-k8s.accountName` parameter.

This name must match an existing cluster because Armory CD-as-a-Service uses the identifier to determine which cluster to deploy to.

For example, this snippet configures a deployment to an environment named `prod` that is hosted on a cluster named `prod-cluster-west`:

```yaml
targets:
  prod:
    account: prod-cluster-west
...
```

### Namespace

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


## Constraints

Optional

`targets.<targetName>.constraints`

`constraints` is a map of conditions that must be met before a deployment starts. The constraints can be dependencies on previous deployments, such as requiring deployments to a test environment before staging, or a pause. If you omit the constraints section, the deployment starts immediately when it gets triggered.

> Constraints are evaluated in parallel.

{{< tabpane text=true right=true >}}
  {{% tab header="**Target**:" disabled=true /%}}
    {{% tab header="AWS Lambda" %}}
```yaml
targets:
  prod:
    account: aws-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-1
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
  {{% /tab %}}
  {{% tab header="Kubernetes" %}}
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
  {{% /tab %}}

{{< /tabpane >}}


### Depends on

Optional

`targets.<targetName>.constraints.dependsOn`: A list of deployments that must finish before this deployment can start. You can use this option to sequence deployments. Deployments with the same `dependsOn` criteria execute in parallel. For example, you can make it so that a deployment to prod cannot happen until a staging deployment finishes successfully.

The following example shows a deployment to `prod-west` that cannot start until the `dev-west` target finishes:

{{< tabpane text=true right=true >}}
  {{% tab header="**Target**:" disabled=true /%}}
  {{% tab header="AWS Lambda" %}}
```yaml
targets:
  prod-west:
    account: aws-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-west-1
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: 
        - ITSec
        - Audit
```
  {{% /tab %}}
    {{% tab header="Kubernetes" %}}
```yaml
targets:
  prod-west:
    account: prod-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn:
        - ITSec
        - Audit
```

  {{% /tab %}}
{{< /tabpane >}}


### Before and after deployment

Optional

`targets.<targetName>.constraints.beforeDeployment`: Add conditions that must be met before the deployment can start. These are in addition to the deployments you define in `dependsOn` that must finish. If a `beforeDeployment` condition fails, CD-as-a-Service does not deploy to this target or subsequent targets.

`targets.<targetName>.constraints.afterDeployment`: Add conditions that must be met before deployment to this target is considered finished. These constraints are executed after deployment to this target but before deployment to the next target (or before deployment is considered done). If an `afterDeployment` condition fails, CD-as-a-Service does not roll back this target and does not deploy to subsequent targets.

`beforeDeployment` and `afterDeployment` support `pause`, `runWebhook`, and `analysis` conditions.

#### Pause

You can specify a pause that waits for a manual approval or a certain amount of time before starting. 

**Pause until manual approval**

{{< tabpane text=true right=true >}}
  {{% tab header="**Target**:" disabled=true /%}}
    {{% tab header="AWS Lambda" %}}
```yaml
targets:
  prod:
    account: aws-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-west-1
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev-west"]
      beforeDeployment:
        - pause:
            untilApproved: true 
            approvalExpiration:
              duration: 60
              unit: seconds
```

- `pause.untilApproved`: Set to true
- `pause.approvalExpiration`: (Optional) Timeout configuration; when expired the ongoing deployment is cancelled 

  {{% /tab %}}
  {{% tab header="Kubernetes" %}}
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
  
  {{% /tab %}}

{{< /tabpane >}}

**Pause for a certain amount of time**

{{< tabpane text=true right=true >}}
  {{% tab header="**Target**:" disabled=true /%}}
    {{% tab header="AWS Lambda" %}}
```yaml
targets:
  prod:
    account: aws-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-west-1
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev-west"]
      beforeDeployment:
        - pause:
            duration: 60
            unit: seconds
```
  {{% /tab %}}
  {{% tab header="Kubernetes" %}}
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
  {{% /tab %}}

{{< /tabpane >}}

- `pause.duration` set to an integer value for the amount of time to wait before starting after the `dependsOn` condition is met.
- `pause.unit` set to `seconds`, `minutes` or `hours` to indicate the unit of time to wait.

#### Run a webhook

In the following example, before deploying to the `prod-cluster-west` target, CD-as-a-Service pauses deployment for manual approval by an Org Admin and also calls a webhook that sends a Slack notification. You declare the webhook in the [webhooks section]({{< ref "reference/deployment/config-file/webhooks" >}}).

{{< tabpane text=true right=true >}}
  {{% tab header="**Target**:" disabled=true /%}}
    {{% tab header="AWS Lambda" %}}
```yaml
targets:
  prod:
    account: aws-docs-dev
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-west-1
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["staging"]
      beforeDeployment:
        - pause:
            untilApproved: true
            approvalExpiration:
              duration: 24
              unit: hours
        - runWebhook:
            name: Send_Slack_Deployment_Approval_Required
```
  {{% /tab %}}
  {{% tab header="Kubernetes" %}}
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
  {{% /tab %}}

{{< /tabpane >}}



#### Analysis

**Kubernetes Only**

In this example, CD-as-a-Service performs a [canary analysis]({{< ref "reference/canary-analysis-query" >}}) after deploying to the target. You declare your query in the [analysis section]({{< ref "reference/deployment/config-file/analysis" >}}) and then add the name to the `queries` list.

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


## AWS Lambda example

{{< tabpane text=true right=true >}}
  {{% tab header="**AWS Accounts**:" disabled=true /%}}
    {{% tab header="Single" %}}
```yaml
targets:
  Production-1:
    account: arn:aws:iam::111111111111:role/ArmoryRole
    constraints:
      dependsOn:
        - staging
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-2
    strategy: allAtOnce
  Production-2:
    account: arn:aws:iam::111111111111:role/ArmoryRole
    constraints:
      dependsOn:
        - staging
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-west-1
    strategy: allAtOnce
  staging:
    account: arn:aws:iam::111111111111:role/ArmoryRole
    constraints:      
      beforeDeployment:
        - runWebhook:
            name: Send_Slack_Deployment_Approval_Required
      afterDeployment:
        - runWebhook:
            name: Integration_Tests
        - pause:
            untilApproved: true
    deployAsIamRole: arn:aws:iam::111111111111:role/ArmoryRole
    region: us-east-1
    strategy: allAtOnce
```
  {{% /tab %}}
  {{% tab header="Multiple" %}}

```yaml
targets:
  Lab:
    account: armory-lab
    deployAsIamRole: "arn:aws:iam::111111111111:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
  Staging:
    account: armory-core
    deployAsIamRole: "arn:aws:iam::222222222222:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn: 
        - Lab
      afterDeployment:
        - runWebhook:
            name: Integration-Tests
  Audit:
    account: armory-audit
    deployAsIamRole: "arn:aws:iam::333333333333:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn:
        - Lab
      afterDeployment:
        - runWebhook:
            name: Audit-Analysis
  ITSec:
    account: armory-itsec
    deployAsIamRole: "arn:aws:iam::444444444444:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn:
        - Lab
      afterDeployment:
        - runWebhook:
            name: Security-Scans            
  Prod-West-2:
    account: armory-prod
    deployAsIamRole: "arn:aws:iam::555555555555:role/ArmoryRole"
    region: us-west-2
    strategy: rollingDeployment
    constraints:
      dependsOn:
        - Staging
        - Audit
        - ITSec
      beforeDeployment:
        - runWebhook:
            name: Send-Slack-Deployment-Approval-Required
        - pause:
            untilApproved: true
```
  {{% /tab %}}

{{< /tabpane >}}



## Kubernetes example

In this example, there are four targets: `dev`,  `infosec`, `staging`, and `prod-west`. After you deploy code to `infosec` and `staging`, you want to run jobs against those targets. If either of those jobs fails, CD-as-a-Service does not deploy to `prod-west`.

`prod-west`'s `afterDeployment` conditions perform an analysis and call a webhook that sends a "deployment complete" notification. 

>If the `analysis` condition fails, CD-as-a-Service does **not** roll back the prod-west deployment because the analysis condition is in an `afterdeployment` constraint. However, if you include the `analysis` step in your strategy and that `analysis` step fails, CD-as-a-Service **does** roll back the deployment.

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

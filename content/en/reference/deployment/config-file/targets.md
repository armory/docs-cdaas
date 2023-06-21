---
title: Targets Config
weight: 3
description: >
  This page describes the `targets` section.
---


## `targets.`

This config block is where you define where and how you want to deploy an app. You can specify multiple targets. Provide unique descriptive names for each environment to which you are deploying.

{{< prism lang="yaml"  line-numbers="true" >}}
targets:
  <targetName>:
    account: <accountName>
    namespace: <namespaceOverride>
    strategy: <strategyName>
    constraints: <mapOfConstraints>
{{< /prism >}}



### `targets.<targetName>`

A descriptive name for this deployment, such as the name of the environment you want to deploy to.

For example, this snippet configures a deployment target with the name `prod`:

{{< prism lang="yaml"  line-numbers="true" >}}
targets:
  prod:
...
{{< /prism >}}

### `targets.<targetName>.account`

The account name that a target Kubernetes cluster got assigned when you installed the Remote Network Agent (RNA) on it. Specifically, it is the value for the `agentIdentifier` parameter. Note that older versions of the RNA used the `agent-k8s.accountName` parameter.

This name must match an existing cluster because Armory CD-as-a-Service uses the identifier to determine which cluster to deploy to.

For example, this snippet configures a deployment to an environment named `prod` that is hosted on a cluster named `prod-cluster-west`:

{{< prism lang="yaml"  line-numbers="true" >}}
targets:
  prod:
    account: prod-cluster-west
...
{{< /prism >}}

### `targets.<targetName>.namespace`

(Recommended) The namespace on the target Kubernetes cluster that you want to deploy to. This field overrides any namespaces defined in your manifests.

For example, this snippet overrides the namespace in your manifest and deploys the app to a namespace called `overflow`:

{{< prism lang="yaml"  line-numbers="true" >}}
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
{{< /prism >}}

### `targets.<targetName>.strategy`

This is the name of the strategy that you want to use to deploy your app. You define the strategy and its behavior in the `strategies` block.

For example, this snippet configures a deployment to use the `canary-wait-til-approved` strategy:

{{< prism lang="yaml"  line-numbers="true" >}}
targets:
  prod:
    account: prod-cluster-west
    namespace: overflow
    strategy: canary-wait-til-approved
{{< /prism >}}

Read more about how this config is defined and used in the [strategies.<strategyName>](#strategies.<strategyName>) section.

#### `targets.<targetName>.constraints`

`constraints` is a map of conditions that must be met before a deployment starts. The constraints can be dependencies on previous deployments, such as requiring deployments to a test environment before staging, or a pause. If you omit the constraints section, the deployment starts immediately when it gets triggered.

> Constraints are evaluated in parallel.

{{< prism lang="yaml"  line-numbers="true" >}}
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
{{< /prism >}}

#### `targets.<targetName>.constraints.dependsOn`

A comma-separated list of deployments that must finish before this deployment can start. You can use this option to sequence deployments. Deployments with the same `dependsOn` criteria execute in parallel. For example, you can make it so that a deployment to prod cannot happen until a staging deployment finishes successfully.

The following example shows a deployment to `prod-west` that cannot start until the `dev-west` target finishes:

{{< prism lang="yaml"  line-numbers="true" >}}
targets:
  prod:
    account: prod-west
    namespace: overflow
    strategy: canary-wait-til-approved
    constraints:
      dependsOn: ["dev-west"]
{{< /prism >}}

#### `targets.<targetName>.constraints.beforeDeployment`

Conditions that must be met before the deployment can start. These are in addition to the deployments you define in `dependsOn` that must finish.

You can specify a pause that waits for a manual approval or a certain amount of time before starting.

**Pause until manual approval**

Use the following configs to configure this deployment to wait until a manual approval before starting:

- `targets.<targetName>.constraints.beforeDeployment.pause.untilApproved` set to true
- `targets.<targetName>.constraints.beforeDeployment.pause.requiresRole` (Optional) list of RBAC roles that can issue a manual approval
- `targets.<targetName>.constraints.beforeDeployment.pause.approvalExpiration` (Optional) Optional timeout configuration; when expired the ongoing deployment is cancelled 

{{< prism lang="yaml"  line-numbers="true" >}}
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
            requiresRole: []
            approvalExpiration:
              duration: 60
              unit: seconds
{{< /prism >}}

**Pause for a certain amount of time**

- `targets.<targetName>.constraints.beforeDeployment.pause.duration` set to an integer value for the amount of time to wait before starting after the `dependsOn` condition is met.
- `targets.<targetName>.constraints.beforeDeployment.pause.unit` set to `seconds`, `minutes` or `hours` to indicate the unit of time to wait.

{{< prism lang="yaml"  line-numbers="true" >}}
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
{{< /prism >}}

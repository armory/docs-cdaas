---
title: Monitor Deployments
linkTitle: Monitor Deployments
weight: 10
description: >
  Monitor the status of your deployments and approve or rollback deployments.
categories: ["Deployment", "Guides"]
tags: ["Monitor"]
---


## Monitor deployments using the UI

When you navigate to the **Deployments** tab of the UI, you land on the **Deployment List** page, which shows all the apps for a specific Armory CD-as-a-Service environment. If you don't see a deployment that you're expecting to see, refresh the list or verify the Armory CD-as-a-Service environment the app belongs to. You can switch environments in the top right menu by clicking on your username.

On the **Deployment List** page, you can select a specific app to go the **Deployment Graph** page, which shows all the environments that are part of that deploy file. If a deploy file only contains one environment, clicking the app will take you straight to the **Environment Details** page.

### Deployment Graph Page

The **Deployment Graph** page shows you all environments that are being deployed to in a single deploy file. If you click the link that the CLI returns when you trigger the deployment, this is the page you are linked to. It can give you a general idea of the state of the deployment and what environment is currently being deployed to.

{{< figure src="/images/cdaas/multitarget-deploy.jpg" alt="The deployment starts in a dev environment. It then progresses to infosec and staging environments simultaneously. It finishes by deploying to a prod-west environment." >}}

More specifically, this view shows you how deployments are supposed to progress through different environments based on the constraints that are defined in the deploy file. An environment that is waiting for one or more constraints to be satisfied is connected to the preceding deployment by a dotted line and is greyed out.

{{< figure src="/images/cdaas/ui-constraints.jpg" alt="The staging-west environment has constraints that prevent it from starting until they are satisfied." >}}

Clicking on a specific environment takes you to the **Environment Details** page for that single environment where you can take additional action.

### Single environment

The **Environment Details** page for a single environment is where you monitor the progress of the deployment to that environment. If the strategy you specified involves user input, such as a manual approval, this is the page where you can approve or rollback the deployment.

{{< figure src="/images/cdaas/ui-fulldetails.jpg" >}}


## Monitor deployments using the CLI

If you want to monitor your deployment in your terminal, use the `--watch` flag to output deployment status.

```bash
armory deploy start  -f deployment.yaml --watch
```

Output is similar to:

```bash
[2023-05-24T13:43:35-05:00] Waiting for deployment to complete. Status UI: https://console.cloud.armory.io/deployments/pipeline/03fe43c6-ddc1-49d8-8116-b01db0ca0c5a?environmentId=82431eae-1244-4855-81bd-9a4bc165f90b
.
[2023-05-24T13:43:46-05:00] Deployment status changed: RUNNING
..
[2023-05-24T13:44:06-05:00] Deployment status changed: AWAITING_APPROVAL
...
[2023-05-24T13:44:36-05:00] Deployment status changed: RUNNING
..
[2023-05-24T13:44:56-05:00] Deployment status changed: AWAITING_APPROVAL
.
[2023-05-24T13:45:06-05:00] Deployment status changed: RUNNING
..
[2023-05-24T13:45:26-05:00] Deployment status changed: SUCCEEDED
[2023-05-24T13:45:26-05:00] Deployment 03fe43c6-ddc1-49d8-8116-b01db0ca0c5a completed with status: SUCCEEDED
[2023-05-24T13:45:26-05:00] Deployment ID: 03fe43c6-ddc1-49d8-8116-b01db0ca0c5a
[2023-05-24T13:45:26-05:00] See the deployment status UI: https://console.cloud.armory.io/deployments/pipeline/03fe43c6-ddc1-49d8-8116-b01db0ca0c5a?environmentId=82431eae-1244-4855-81bd-9a4bc165f90b

```

If you forget to add the `--watch` flag, you can run the `armory deploy status --deploymentID <deployment-id>` command. Use the Deployment ID returned by the `armory deploy start` command. For example:

```bash
armory deploy start -f deployment.yaml
Deployment ID: 9bfb67e9-41c1-41e8-b01f-e7ad6ab9d90e
See the deployment status UI: https://console.cloud.armory.io/deployments/pipeline/9bfb67e9-41c1-41e8-b01f-e7ad6ab9d90e?environmentId=82431eae-1244-4855-81bd-9a4bc165f90b
```

then run:

```bash
armory deploy status --deploymentId 9bfb67e9-41c1-41e8-b01f-e7ad6ab9d90e
```

Output is similar to:

   ```bash
application: sample-application, started: 2023-01-06T20:07:36Z
status: RUNNING
See the deployment status UI: https://console.cloud.armory.io/deployments/pipeline/9bfb67e9-41c1-41e8-b01f-e7ad6ab9d90e? environmentId=82431eae-1244-4855-81bd-9a4bc165f90b
```

This `armory deploy status` command returns a point-in-time status and exits. It does not watch the deployment.


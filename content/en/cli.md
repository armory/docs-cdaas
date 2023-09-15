---
title: Install and Upgrade the CD-as-a-Service CLI
linkTitle: CLI
weight: 10
categories: ["CLI", "Tools"]
tags: ["CLI"]
description: >
  Install the Armory Continuous Deployment-as-a-Service CLI natively on Mac, Linux, or Windows. Learn how to run the CLI in Docker. 
---

## CLI overview

You can install the CLI (`armory`) on your Mac, Linux, or Windows workstation. Additionally, you can run the CLI in Docker. 

On Mac, you can also download, install, and update the CLI using the Armory Version Manager (AVM). The AVM includes additional features such as the ability to list installed CLI versions and to declare which version of the CLI to use.

{{< include "cli/install-cli-tabpane" >}}

## Upgrade the CLI

{{< tabpane text=true right=true >}}
{{% tab header="**Method**:" disabled=true /%}}
{{% tab header="Homebrew" %}}
```bash
brew upgrade armory-cli
```
{{% /tab %}}
{{% tab header="AVM" %}}
```bash
avm install
```
{{% /tab %}}

{{< /tabpane >}}

## Monitor deployments

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
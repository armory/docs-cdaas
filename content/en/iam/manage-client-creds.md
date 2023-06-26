---
title: Create Client Credentials
linkTitle: Client Credentials
description: >
  Create machine-to-machine credentials and assign RBAC roles to them in Armory CD-as-a-Service.
categories: ["IAM", "Guides"]
tags: ["Credentials"]
---

## Overview

A _Client Credential_ is a machine-to-machine credential that the CLI uses to authenticate with CD-as-a-Service when you trigger deployments as part of an external automated workflow. You pass the credential through the `clientID` and `clientSecret` parameters.

Additionally, a Remote Network Agent uses a Client Credential for authentication when communicating with CD-as-a-Service.

## {{% heading "prereq" %}}

* You are an Organization or Tenant Admin within CD-as-a-Service.
* You are familiar with [tenants, users, and RBAC in CD-as-a-Service]({{< ref "iam/_index.md" >}})


## Create a Client Credential

{{< include "client-creds.md" >}}

Armory recommends that you store credentials in a secret engine that is supported by the tool you want to integrate with CD-as-a-Service.

## Assign a role

1. Access the [CD-as-a-Service Console](https://console.cloud.armory.io).
1. Navigate to **Access Management** > **Client Credentials**.
1. Find the credential you want to update. Click the **pencil icon** to open the **Update** screen.
1. In the **Update** screen, place your cursor in the **Select Roles** field and click.
1. Select a role from the drop-down list. Repeat if you want to assign the credential more than one role. Selected roles appear below the **Select Roles** drop-down list.
1. Click the **Update Credential** button.

## Revoke a role

1. Access the [CD-as-a-Service Console](https://console.cloud.armory.io).
1. Navigate to **Access Management** > **Client Credentials**.
1. Find the Client Credential you want to update. Click the **pencil icon** to open the **Update** screen.
1. In the **Update** screen, you can see a credential's roles listed below the **Select Roles** field.
1. Each assigned role has an **x** next to it. Click the **x** to revoke the role.

>Make sure your Client Credential has at least one role!

## {{% heading "nextSteps" %}}

* {{< linkWithTitle "troubleshooting/rbac.md" >}}
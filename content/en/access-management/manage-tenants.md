---
title: Add, View, and Switch Tenants
linkTitle: Tenants
description: >
  Add tenants to your Armory CD-as-a-Service organization.
categories: ["Access Management", "Guides"]
tags: ["Tenants"]
---

## {{% heading "prereq" %}}

* You have the Organization Admin role.
* You have installed the CLI and are logged into CD-as-a-Service.

## Create tenants

Every organization has a `main` tenant. You can create one or more additional tenants using a YAML file and the CLI. Your YAML file should have the following structure:

{{< prism lang="yaml" line-numbers="true" line="" >}}
tenants:
  - <tenant-name-1>
  - <tenant-name-2>
{{< /prism >}}

Run the following command to add those tenants:

{{< prism lang="yaml" line-numbers="true" line="" >}}
armory config apply -f <path-to-tenant-config.yaml>
{{< /prism >}}

## Example

In the following example, you create tenants for two applications and a sandbox.

1. Create a file called `config.yaml`.
1. Add the following content:

   {{< prism lang="yaml" line-numbers="true" line="" >}}
   tenants:
     - potato-facts-app
     - sample-app
     - sandbox{{< /prism >}}

   Save your file.  

1. Run the following command from the directory where you saved your `config.yaml` file:

   {{< prism lang="yaml" line-numbers="true" line="" >}}
   armory config apply -f config.yaml{{< /prism >}}

   Output should be:

   {{< prism lang="bash" line-numbers="true" >}}
   Created tenant: potato-facts-app
   Created tenant: sample-app
   Created tenant: sandbox{{< /prism >}}

1. Confirm your tenants have been added:

   {{< prism lang="bash" line-numbers="true" >}}
   armory config get{{< /prism >}}

   Output should be:

   {{< prism lang="bash" line-numbers="true" >}}
   tenants:
    - main
    - potato-facts-app
    - sample-app
    - sandbox{{< /prism >}}
    
## View tenants

>Non-Admin users only see tenants that they belong to. If users don't have a role belonging to a particular tenant, they don't see those tenants.

You can use the CLI to view your tenants:

{{< prism lang="bash" line-numbers="true" >}}
armory config get
{{< /prism >}}

Output shows the list of tenants. When you only have access to the default tenant, the output is:

{{< prism lang="bash" line-numbers="true" >}}
tenants:
 - main
{{< /prism >}}

You can also use the UI to view the list of tenants you can access. See the [Switch tenants](#switch-tenants) section.

## Switch tenants

You use the UI to switch to the tenant whose resources you want to see. CD-as-a-Service only displays the **Switch Tenants* user content menu item when you have access to more than one tenant.

{{< figure src="/images/cdaas/ui-switch-tenant.jpg" alt="Switch Tenant." >}}

1. Access your user context menu.
1. Hover over **Switch Tenant** to display a list of accessible tenants.
1. Click the tenant you want to switch to.
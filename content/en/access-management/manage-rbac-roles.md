---
title: Create and Manage RBAC Roles
title: RBAC Roles
description: >
  Create an RBAC role using Armory CD-as-a-Service's CLI.
categories: ["Guides"]
tags: [ "Access", "RBAC"]
---

## Create a new RBAC role

By default, a new user has no permission to access functionality within CD-as-a-Service. You can assign a new user the Organization Admin role or create a custom role that defines what the user can see and do in the UI as well as from the CLI.

>All users can start a deployment.

### {{% heading "prereq" %}}

* You are an Organization or Tenant Admin within CD-as-a-Service.
* You are familiar with tenants, users, and RBAC {{< ref "access-management/_index.md" >}}.

### How to create a custom role

You define your roles in a YAML file using the following structure:

{{< prism lang="yaml" line-numbers="true" line="" >}}
roles:
  - name: <role-name>
    tenant: <tenant-name>
    grants:
      - type: <grant-type>
        resource: <resource-type>
        permission: <permission-type>
{{< /prism >}}

* `name`: (Required); String; name of the role
* `tenant`: (Optional); String; name of the tenant; if omitted, the role is an organization-wide role, not bound to a specific tenant
* `grants`: (Required)(Dictionary)

   * `type`: (Required); String; `api`
   * `resource`: (Required); String; one of `organization`, `tenant`, or `deployment`
   * `permission`: (Required); String; `full`

After you have defined your roles, use the CLI to add those roles to CD-as-a-Service.

{{< prism lang="bash" line-numbers="true" line="" >}}
armory login
armory config apply -f <path-to-rbac-config>.yml
{{< /prism >}}

You can check that you created your roles correctly by running `armory config get`.

>**Organization Admin** is a system-defined role that does not appear in your RBAC config.

#### User role examples

**Tenant Admin**

A user with this role can access every screen in the `main` tenant and deploy apps using the CLI.

{{< prism lang="yaml" line-numbers="true" line="" >}}
roles:
  - name: Tenant Admin
    tenant: main
    grants:
      - type: api
        resource: tenant
        permission: full
{{< /prism >}}

**Deployer**

A user with this role can only access the **Deployments** screen in the UI and deploy apps using the CLI.

{{< prism lang="yaml" line-numbers="true" line="" >}}
roles:
  - name: Deployer
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
{{< /prism >}}

### SSO roles

If your organization uses SSO with CD-as-a-Service, you must create your roles using the same names as your SSO groups. For example, your company has the following groups defined in its SSO provider:

1. Engineering-Infra
1. Engineering-Release
1. Engineering-InfoSec

You want to use those groups in CD-as-a-Service, so you need to create roles for those SSO groups. In the following example, `Engineering-Infra` has a Tenant Admin role. `Engineering-Release` and `Engineering-InfoSec` have tenant-scoped deployment roles.

{{< prism lang="yaml" line-numbers="true" line="" >}}
roles:
  - name: Engineering-Infra
    tenant: main
    grants:
      - type: api
        resource: tenant
        permission: full
  - name: Engineering-InfoSec
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
  - name: Engineering-Release
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
{{< /prism >}}


## Update a role

Perform the following to update a role or roles:

1. Update the existing role(s) in your RBAC config file.
1. Log into the CLI and apply the changes:

   {{< prism lang="bash" line-numbers="true" >}}
   armory login
   armory config apply -f <path-to-rbac-config>.yml{{< /prism >}}


For example, you created the following roles:

{{< prism lang="yaml" line-numbers="true" line="" >}}
roles:
  - name: Tenant Admin
    tenant: main
    grants:
      - type: api
        resource: tenant
        permission: full
  - name: Deployer
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
  - name: Tester
    grants:
      - type: api
        resource: deployment
        permission: full
{{< /prism >}}

You notice that the Tester role has no `tenant` defined, which means the role is organization-wide. Update your config file to add the tenant:

{{< prism lang="yaml" line-numbers="true" line="14" >}}
roles:
  - name: Tenant Admin
    tenant: main
    grants:
      - type: api
        resource: tenant
        permission: full
  - name: Deployer
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
  - name: Tester
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
{{< /prism >}}

Execute `armory config apply -f <path-to-rbac-config>.yml` to apply your changes.

You can check that you updated your role correctly by running `armory config get`.

>The role name is case insensitive. "DeployM2m" is the same as "DeployM2M", so if you want to change capitalization in a role name, you must delete the role and add a new role with the name's corrected capitalization.


## Delete a role

Perform the following to delete a role or roles:

1. Add `allowAutoDelete: true` to the top of your RBAC config file.
1. Remove the role(s) from your RBAC config file.
1. Log into the CLI and apply the changes:

   {{< prism lang="bash" line-numbers="true" >}}
   armory login
   armory config apply -f <path-to-rbac-config>.yml{{< /prism >}}


For example, you have a config file with the following roles:

{{< prism lang="yaml" line-numbers="true" line="" >}}
roles:
  - name: Tenant Admin
    tenant: main
    grants:
      - type: api
        resource: tenant
        permission: full
  - name: Deployer
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
  - name: Tester
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
{{< /prism >}}

You want to delete the Tester role. Update your config file by adding `autodelete: true` to the top and removing the Tester role entry:

{{< prism lang="yaml" line-numbers="true" line="" >}}
allowAutoDelete: true
roles:
  - name: Tenant Admin
    tenant: main
    grants:
      - type: api
        resource: tenant
        permission: full
  - name: Deployer
    tenant: main
    grants:
      - type: api
        resource: deployment
        permission: full
{{< /prism >}}

Execute `armory config apply -f <path-to-rbac-config>.yml` to apply your changes.

You can check that you deleted your role by running `armory config get`.

When you delete a role, that role is removed from existing users. You can accidentally remove the ability for your users to perform actions within CD-as-a-Service. A user with no role can still log into the UI but only sees a blank **Deployments** screen:
{{< figure src="/images/cdaas/user-no-role.png" >}}
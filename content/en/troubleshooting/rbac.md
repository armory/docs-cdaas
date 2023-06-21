---
title: Troubleshoot Role-Based Access Control
linktitle: RBAC
weight: 1
description: >
  Solutions for issues you might encounter while using RBAC in Armory Continuous Deployment-as-a-Service.
categories: ["Access Management", "Troubleshooting"]
tags: ["RBAC"]
---

## User sees blank **Deployments** screen

{{< figure src="/images/cdaas/user-no-role.png" alt="User sees the Deployments screen with no deployments." >}}

**Why this happens**
<br>
{{< tabs name="no-role" >}}
{{% tabbody name="No SSO" %}}
The user doesn't have an RBAC role. This happens when:

* The Organization Admin didn't create any RBAC roles.
* The Organization or Tenant Admin didn't assign an existing role when inviting the user.
* The Organization or Tenant Admin deleted a role and didn't assign a new role to affected users.

Organization Admin is a system role. CD-as-a-Service automatically assigns that role to the user who creates a new CD-as-a-Service organization. That role is not auto-assigned to anyone else in the organization. You can, however, assign the Organization Admin role to anyone you invite.

**Fixes**
<br>
* Assign the existing Organization Admin role to the affected user.
* [Create at least one custom RBAC role]({{< ref "access-management/manage-rbac-roles.md" >}}) and then assign that RBAC role to the affected user.

{{% /tabbody %}}
{{% tabbody name="SSO" %}}

* The user doesn't have the correct SSO groups assigned in your company's SSO provider.
* The Organization or Tenant Admin didn't create an RBAC role that corresponds to the SSO group. The CD-as-a-Service RBAC role name must be identical to the SSO group name.

**Fix**
<br>
* [Create RBAC roles]({{< ref "access-management/manage-rbac-roles#sso-roles" >}}) to match the SSO groups that you want to use with CD-as-a-Service.


{{% /tabbody %}}
{{< /tabs >}}



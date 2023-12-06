---
---
{{% alert title="Important" color="info" %}}
* When CDaaS creates an alias as part of a deployment, it creates the alias at the end of the deployment.
* During the deployment that creates the alias, CD-as-a-Service ignores the `setWeight` steps for that function.
* You should only route traffic to the alias after the deployment has completed. 
{{% /alert %}}
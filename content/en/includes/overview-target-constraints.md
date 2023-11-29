You can also configure your deployment targets to use constraints that prevent a deployment from beginning or completing until certain conditions are met. For example, you can configure your deployment to wait for your code to be deployed to your staging environment before promoting that code to production.

CD-as-a-Service offers you multiple constraint options including: 

*  `dependsOn`: Use `dependsOn` to specify a target deployment that must successfully complete prior to starting this target's deployment.
* `beforeDeployment`: You can use this constraint to implement a checklist of things that need to happen before a target starts deploying. For example, you can use the `beforeDeployment` constraints with the [pause step]({{< ref "reference/deployment/config-file/targets#pause" >}}) to require a manual approval.
* `afterDeployment`: You can use this constraint to prevent downstream deployments from starting until some set of post deployment tasks finishes. For example, you can use this with the [runWebhook step]({{< ref "reference/deployment/config-file/targets#run-a-webhook" >}}) to execute a set of end-to-end tests in a staging environment before deploying to production.

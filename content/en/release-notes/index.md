---
title: Release Notes
weight: 900
description: >
  Information about new features and changes, fixes, and improvements in Armory Continuous Deployment-as-a-Service.
---

## 28 Nov 2023

### Support for AWS Lambda

Armory CD-as-a-Service now supports deploying to AWS Lambda. Orchestrate your Lambda function release across multiple AWS Accounts, ensuring they are always tested in staging, then leverage canary deployments in production.

{{< youtube>}}

Learn more:

* [Demo](https://youtu.be/AwThI9wnD-o?feature=shared)
* {{< linkWithTitle "deployment/lambda/index.md" >}}
* {{< linkWithTitle "get-started/lambda/index.md" >}}


## 2023 Sept 29

### Pipeline graph is now available when deploying to a single target

{{< figure src="20230929-pipelinegraph.png" width="80%" height="80%" >}}

Certain functionality, such as trigger nodes and the ability to redeploy an old version, are only available on the pipeline graph. With this change these features are available when deploying to a single target.

## 2023 Sept 15

###  New on the deployment graph: Deployment triggers with source context

{{< figure src="20230915-trigger.png" width="25%" height="25%" >}}

We've added a new element to the deployment graph called                        a Trigger Node which explains how a deployment was
                        triggered by displaying the source system, initiating
                        person, and trigger type. This allows anyone on the team
                        to immediately know the source of a deployment,
                        including who triggered it, and how it maps back to a
                        pull request or commit.

When triggering from GitHub, additional source details
                        will appear on the Trigger Node: PR title, PR number,
                        commit SHA, branches, and in the event of a push tag
                        trigger, the associated tag. Each element in the Source
                        section is a deep link back to GitHub.

If context variables were passed with the trigger, they
                        will appear in a Context Variables section on the
                        Trigger Node.


Trigger Nodes will automatically show up on your
                deployment pipelines. Customers who have already
                configured a GitHub Action will need to adjust the
                workflow token permissions in their configuration to
                view the full set of Source Context information. This
                can be accomplished by adding a permissions block to
                your workflow, and adding a token to the GitHub action's
                env block.

Refer to the updated documentation pages for more information:

* [Monitor Deployments]({{< ref "deployment/monitor-deployment">}}) 
* [Use Armory's GitHub Action to Deploy Your App Using CD-as-a-Service]({{< ref "integrations/ci-systems/gh-action" >}})   

```yaml
permissions:
  contents: read
  pull-requests: read
  statuses: read
```
```yaml
# Add GH_TOKEN to env in the cli-deploy-action step
- name: Deploy
  env:
    GH_TOKEN: '${{ secrets.GITHUB_TOKEN }}'
  uses: armory/cli-deploy-action@main
```

## 2023 Aug 29

### Connected clusters available as deploy targets in the wizard

{{< figure src="fb7256cb-c47d-4cfe-8787-e4c1d492873a.png"  width="80%" height="80%" >}}

Use already connected clusters to set up deployments for
                        your new applications using the wizard. Earlier, using
                        the wizard to set up new applications forced you to
                        install a new Remote Network Agent (RNA), which was not
                        ideal if you already had your cluster connected, leaving
                        you with the option of creating a new deployment file
                        using our docs. CD-as-a-Service enables you to select an
                        already connected cluster when setting up a new
                        application via the wizard and easily onboard new
                        applications. Additionally, we have streamlined RNA
                        installation experience, making it easier to choose
                        between various installation options. The updated RNA
                        install experience is currently live within
                        CD-as-a-Service setup.

## 2023 Aug 04

###  Developer Hub is live - central locations for all the CD-as-a-Service resources

{{< figure src="92952f88-8e72-4a92-9f48-ccb8badc8612.png"  width="80%" height="80%" >}}

The new [Developer Hub](https://developer.armory.io/) provides a central location for all the resources you
need to get started with Armory CD-as-a-Service. The hub includes links to documentation, tutorials and release
notes.

Additionally, the [CD-as-a-Service documentation](https://developer.armory.io/docs) for  has
been revamped with new and updated content to help you
get started with Armory CD-as-a-Service. Navigation is
now structured to make it easier for you to find the
relevant content.

## 2023 July 21

### CLI v1.15.3 returns exit code 3 when there is an ongoing deployment

{{< figure src="44b356e2-688d-44de-9783-7c9c238c0751.png" >}}

The Armory CLI now returns exit code 3 when there is an
                        ongoing deployment. CD-as-a-Service allows only 1
                        deployment to be in progress for an application.
                        Previously, the Armory CLI would print an error message
                        for ongoing deployments, but would return with an exit
                        code 0. This made it harder to determine if the
                        deployment was successfully started or rejected because
                        one was already in progress. We have improved the
                        behavior, as well as improved the error message
                        formatting.

## 2023 July 14

### Can now recreate the deployment object when deploying
               
Historically Armory CD-as-a-Service has managed replica
sets when deploying a Deployment object, and once
deployment was complete there was no Deployment object
in cluster. With this change we can now deploy the
deployment object as well so that existing runbooks
(e.g. restarting a deployment object) can be run on it
if desired.

**To enable this functionality**<
                      
Add the following configuration block to your application's deploy.yml:

```yaml
deploymentConfig:
  keepDeploymentObject: true
```

## 2023 June 05

### View Kubernetes Manifests on deployment graph screen

{{< figure src="00f98b68-0821-47ae-a069-5ba6608b67df.png"  width="80%" height="80%" >}}

 Easily view the Kubernetes manifests deployed using
                        CD-as-a-Service from within the UI. Previously,
                        understanding which manifests were deployed in a
                        deployment required tracking down the manifest files in
                        your source control repository. However, now you can
                        conveniently access and review the manifests directly
                        within the CD-as-a-Service UI. This feature simplifies
                        the process of identifying potential issues with
                        Kubernetes manifests that may not meet your
                        expectations.

To view the Kubernetes resource manifests, simply click
on the "View Deployment Config" link on the deployment
graph page. Then, select the "Kubernetes Manifests" tab
to access and review the manifests.

###  Log in and Sign up using your Google and GithHub account

{{< figure src="5d46b580-5736-447b-8da0-1a66f99f3a0c.png"  width="80%" height="80%" >}}

 You can now sign up and log in for CD-as-a-Service using
                        your Google or GitHub credentials. With our latest
                        update, it's easier than ever to create an account or
                        log in. Simply click on the "Login with Google" or
                        "Login with GitHub" buttons, and you're all set! No more
                        manual data entry required.

For users who have previously created an account using a
username and password, you can now use the social
sign-on option to access your existing account.

Note: If you are using an external Identity Provider
(e.g., Okta, Google Workspace), please ensure that you
use your accounts configured with the external Identity
Providers.

## 2023 June 01

###  New system-provided context variables are now available

Several new armory-provided context variables are now
available for use in your web-hooks and automated canary
analysis configuration.

**{{ armory.namespace }}** - this variable
will inject the namespace to which a target is
deploying.

**{{ armory.accountName }}** - this
variable will inject the name of the account to which a
target is deploying.

**{{ armory.environmentName }}** - this
variable will inject the name of the target to which you
are deploying.

**{{ armory.applicationName }}** - this
variable will inject the name of the application that
you are deploying.

These configuration variables can be useful when passing
this information into a web-hook to simplify web-hook
configuration for certain use-cases by reducing the need
for custom context variables.

## 2023 April 07

###  Added ability to redeploy old version

It is now possible to easily redeploy any old version,
                        by clicking the 'redeploy this version' button, and
                        choosing which environments you want to redeploy to.
                        This can be used for rolling back days or weeks after a
                        version has been fully deployed to production. This
                        option will not be available for older deployments, but
                        is for all future deployments.

[Watch demo](https://drive.google.com/file/d/1Axa1JzS0PVn9YKw07PBSe44d7KJiis_V/view?usp=share_link)

### View deployment configuration

{{< figure src="ac62b53b-8ba5-4860-ba23-52952497d50c.png"  width="80%" height="80%" >}}

It is also now possible to view the configuration of a
                        deployment in the pipeline for easier reference. This is
                        useful for helping new users see how existing
                        deployments are configured. This option will not be
                        available for older deployments, but is for all future
                        deployments.
[Watch demo](https://drive.google.com/file/d/1Axa1JzS0PVn9YKw07PBSe44d7KJiis_V/view?usp=share_link)

### Updated login look and feel

{{< figure src="8eb56fb4-9bcf-4857-8d47-91b40035994d.png"  width="80%" height="80%" >}}

The sign-in experience now has an updated look and feel.

## 2023 April 03

### Can now pass url from Expose Service to Webhook

When defining a webhook, it can now pass the URL of any
                        services exposed using the expose service step to the
                        webhook. This can be used to run automated tests against
                        the exposed service. 

Here is an example that passes the exposed url for the
service 'potato-facts-internal' into a github actions
workflow:

```yaml
- bodyTemplate:
      inline: |-
        { "event_type": "checkLogs", "client_payload": {
            "callbackUri": "{{armory.callbackUri}}/callback", "service":"{{	armory.preview.potato-facts-internal}}"
            }
        }
    headers:
      - key: Authorization
        value: token {{secrets.github_token}}
      - key: Content-Type
        value: application/json
    method: POST
    name: Integration_Tests
    retryCount: 3
    uriTemplate: https://api.github.com/repos/mycompany/myrepo/dispatches
```

## 2023 March 29

### Add Descriptions and context variables to deployments

{{< figure src="b57ebb14-b5f4-4b1d-a552-3221345f21cd.png"  width="80%" height="80%" >}}

 Remove the burden of pre-existing knowledge when looking
                        at application deployments. With descriptions, you can
                        add context about the application within the deployment.
                        You can add things like application owners, link to
                        source control repository, link monitoring dashboards
                        and more. Adding descriptions to deployments can be done
                        simply by adding a `description` field in the
                        deployment manifest and providing it a string value.

```yaml
description: |
  This is a deployment for the sample application. Github link: https://github.com/armory-io/cdaas-examples
context:
  foo: bar
```

Additionally, it is now possible to define context
                        variables in the deployment file. The context variables
                        are accessible from within webhooks and canary analysis.
                        It is still possible to pass context variables at
                        runtime using the `--add-context` flag in the
                        CLI.

Read {{< linkWithTitle "deployment/add-context-variable.md" >}} for more information. 

## 2023 March 14

### Added Ability to Expose an External Preview URL for any Deployed Kubernetes Service

{{< figure src="b414f73f-e8cc-4dce-ab5b-b20f46f80f60.png"  width="80%" height="80%" >}}

We've added support for creating service previews.

Armory can now leverage its remote network agent to
expose a preview URL for any Kubernetes service it
deploys. CD-as-a-Service can generate a
cryptographically secure URL for applications
developers. This url can be shared with teammates and
stakeholders who need to review the deployed
functionality. This enables developers access to
deployed services on-demand without a dependency on
other teams to set up networking.

[Watch a demo](https://drive.google.com/file/d/1Ivfazbb7DGzOOhVRuHZV3x3EyixZenek/view?usp=share_link)

 To enable a preview service for your deployment, add an **expose service** step to your canary or blue/green strategy:

 ```yaml
 - exposeServices: # step name
            services:     # list of services to expose. Service must be included in the manifests being deployed.
            - potato-facts-internal
            - potato-lies-internal
            ttl: # Optional. Sets lifetime of the exposed service preview. After that period service preview automatically expires. Max lifetime cannot exceed 24 hours, Min is 1 minute, default is 5 minutes.
              duration: 30
              unit: MINUTES # SECONDS, MINUTES or HOURS 
 ```

 See {{< linkWithTitle "reference/deployment/config-preview-link/index.md" >}} for more info.

 ## 2023 Feb 05

 ### New Get Started Experience

 {{< figure src="0e2a6219-006f-4f0e-9087-b6b6219bcefb.png"  width="80%" height="80%" >}}

Getting started with CD-as-a-Service is now easier than
                      ever. The new user's onboarding experience sent them
                      into the configuration page, which was slightly
                      confusing. Users are now taken to a dedicated wizard
                      like setup experience. This allows them to easily deploy
                      the sample application and get started with deploying
                      their own application without having to learn a new YAML
                      structure.

 ## 2023 Feb 04

 ###  Canary Deployments Can Now Use Istio Service Mesh

 CD-as-a-Service now supports using the Istio service
                        mesh, which allows you to implement precise control over
                        the exact percentage of traffic received by the next
                        version of your app. When you use a pod-ratio canary
                        strategy, you can only approximately control the correct
                        traffic split. When you use Istio, however, you can
                        achieve fine-grained traffic control over your canary
                        deployments.

To integrate Istio with CD-as-a-Service, add the traffic
management block as a top-level field in your deployment
config file and provide the Istio resource names.

Check out {{< linkWithTitle "traffic-management/istio.md" >}} for more information.

```yaml
trafficManagement:
  - targets: [staging]
    istio:
      - virtualService:
          name: istio-sample-vs
        destinationRule:
          name: istio-sample-dr
```

 ## 2023 Jan 14

 ###  Can now deploy any Kubernetes Manifest
 
 You can now deploy any Kubernetes manifest, including CRDs for Operators without needing a deployment object.

 CD-as-a-Service has historically only supported
                        deploying manifests alongside an object of Kind
                        Deployment. Now, Armory can deploy any set of Kubernetes
                        manifests, not just those with Deployment objects. This
                        enables some new use cases, such as:
* Armory can deploy CRDs for operators such as [Argo Rollouts](https://www.youtube.com/watch?app=desktop&amp;v=7gUmfDB-kvI) or CrossPlane. This allows Armory to orchestrate                            cross-cluster deployments of software that is using                            an Operator within the cluster.
* This also allows deploying standalone workloads that                            are not deployment based, such as CronJobs or                            StatefulSets using CD-as-a-Service.

You do not need any extra configuration to start with
                        deploying operators and other Kubernetes manifests.
                        Simply specify the paths to your Kubernetes resource in
                        the manifests section of your deploy yaml and deploy
                        using the CLI or GitHub Action.

When deploying manifests that do not contain and
                        Deployment object, the 'Strategy' will be ignored. You
                        can still use `beforeDeployment` constraint
                        for manual approvals and other actions. When deploying
                        to an operator use web-hooks in an AfterDeployment
                        constraint to add operator-specific logic that waits for
                        the operator to finish processing the updated CRD.

#### Known issues

Objects of Kind 'Custom Resource Definition' must be deployed before objects of the kinds they create.

 ## 2023 Jan 04

 ###  Invoke webhooks without needing a callback

 You can now use webhooks asynchronously during
                        deployment. Until now, using webhooks required a
                        callback for the deployment to continue or rollback,
                        which was not ideal for use cases like event streaming.
                        `webhooks` now has an optional boolean field
                        `disableCallback`. When you set this field to
                        true, CD-as-a-Service does not wait for the callback to
                        continue deployment.

The following is a sample configuration for defining an asynchronous webhook:

```yaml
webhooks:
  - name: Sample_Integration_tests
    method: POST
    disableCallback: true
    uriTemplate: https://api.cloud.armory.io/sandbox/webhoo
    headers:
      - key: Content-Type
        value: application/json
    bodyTemplate:
      inline: &gt;-
        {
          "callbackUri": "{{armory.callbackUri}}/callback",
          "success": true
        }
    retryCount: 3

strategies:
  canary-20:
    canary:
      steps:
        - setWeight:
            weight: 20
        - runWebhook:
            name: Sample_Integration_tests
```
---
title: "Argo Rollouts Deployment"
linkTitle: "Argo Rollouts Deployment"
description: >
  Use Armory CD-as-a-Service to deploy Argo Rollout Objects across multiple Kubernetes environments.
categories: ["Deployment", "Guides"]
tags: ["Argo Rollouts", "Kubernetes"]
---

## Objectives

In this guide, you learn how to use Argo Rollouts with Armory CD-as-a-Service. 

1. [Create a CD-as-a-Service deployment config file](#create-a-cd-as-a-service-deployment-config-file)
1. [Add your Rollout manifest](#add-your-rollout-manifest)
1. [Deploy your app](#deploy-your-app)
1. [Extend deployment functionality](#extend-functionality-for-rollout-deployments) to use webhooks and to deploy multiple rollouts

## {{% heading "prereq" %}}

Make sure that you have performed the following steps:

- Connected to your Kubernetes cluster and deployed an app using the CLI. See {{< linkWithTitle "get-started/quickstart.md" >}}.

To complete this guide, you need the following:

- Access to a Kubernetes cluster where you have installed the Remote Network Agent (RNA). This cluster acts as the deployment target for the sample app. (Optional) You can connect multiple Kubernetes clusters to deploy to multiple environments
- One or more [Argo Rollout manifests](https://argoproj.github.io/argo-rollouts/features/specification/). For example:

   {{< highlight yaml >}}
   # rollout.yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Rollout
   metadata:
     name: example
     spec:
       replicas: 5
       ...
    {{< /highlight >}}

## Create a CD-as-a-Service deployment config file

Create a file called `armoryDeployment.yaml` with the following contents:

{{< highlight yaml >}}
# armoryDeployment.yaml
version: v1
kind: kubernetes
application: <app-name> 
targets:
  staging:
    account: <cluster-name> # Name of the cluster you entered when installing the RNA. 
    namespace: <namespace>
  production:
    account: <cluster-name> 
    namespace: <namespace>
    constraints:
      dependsOn: [staging]
      beforeDeployment:
        - pause:
            untilApproved: true
manifests:
     - path: <path-to-app-manifest>
{{< /highlight >}}

This example includes multiple targets. You can remove or add targets to match your environment.

Be sure to replace `<app-name>`, `<cluster-name>`, and `<namespace>` placeholders with your own values.

See {{< linkWithTitle "reference/deployment/_index.md" >}} if you want to create a more robust deployment config file. 

## Add your Rollout manifest

1. Go to the `manifests` section in your deployment config file.
1. Add your Argo Rollout manifests in the `manifests[].path` section:

   {{< highlight yaml "hl_lines=5-6" >}}
   # armoryDeployment.yaml
   version: v1
   kind: kubernetes
   ...    
   manifests:
     - path: rollout.yaml
   {{< /highlight >}}


## Deploy your app

1. Ensure you have logged into CD-as-a-Service:

   {{< highlight bash >}}
   armory login
   {{< /highlight >}}


1. Start your deployment using the Armory CLI:

   {{< highlight bash >}}
   armory deploy start -f armoryDeployment.yaml --watch
   {{< /highlight >}}

   Remove the `--watch` flag if you don't want to output deployment status in your terminal.


>If you are only deploying Argo Rollouts, CD-as-a-Service ignores any strategy you configure in your deployment config file. The Rollout follows the strategy defined in the Rollout manifest.

## Extend functionality for Rollout deployments

### Run integration tests using webhooks

You can use webhooks in `afterDeployment` constraints to add specific logic for Argo Rollouts to finish deploying before starting integration tests. For example:

<!-- markdown-link-check-disable -->
{{< highlight yaml "linenos=table,hl_lines=9-12 15-28" >}}
 # armoryDeployment.yaml
version: v1
kind: kubernetes
application: my-application
targets:
  staging:
    account: staging
    namespace: default
    constraints:
      afterDeployment:
        - runWebhook:
            name: Refer to Argo Rollouts for status
manifests:
  - path: rollout.yaml
webhooks:
   - name: Refer to Argo Rollouts for status
     method: POST
     uriTemplate: http://cmd-hook.default:8081/cmd
     networkMode: remoteNetworkAgent
     agentIdentifier: <cluster-name>
     retryCount: 3
     bodyTemplate:
        inline:  >-
        {
        "cmd": "kubectl",
        "arg": "wait -n=default rollout/example --for=condition=Completed --timeout=30m",
        "callbackURL": "{{armory.callbackUri}}/callback"
        }
{{< /highlight >}}
<!-- markdown-link-check-enable-->

This example employs [cmd-hook](https://hub.docker.com/r/demoimages/cmd-hook), which is an open source service deployed in the cluster to execute `kubectl` commands. CD-as-a-Service employs RNA to execute `kubectl` commands for monitoring the state of rollout objects. You can view the source code for `cmd-hook` in the [public repository](https://github.com/stephenatwell/cmdHook).

### Deploy multiple Argo Rollouts

To deploy multiple Argo Rollouts together, you can add more paths to the `manifests` section of the deployment config file:

{{< highlight yaml >}}
manifests:
  - path: rollout-1.yaml
  - path: rollout-2.yaml
  - path: rollout-3.yaml
{{< /highlight >}}


## {{%  heading "nextSteps" %}}

* {{< linkWithTitle "reference/deployment/config-file/_index.md" >}}


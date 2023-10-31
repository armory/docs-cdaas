---
title: Armory CD-as-a-Service Plugin for Spinnaker and Armory Continuous Deployment
linkTitle: Spinnaker Plugin
description: >
  The Armory Continuous Deployment-as-a-Service plugin enables performing canary and blue/green deployments in a single stage from Spinnaker to your Kubernetes deployment target using CD-as-a-Service.
---

<!-- https://www.docsy.dev/docs/adding-content/navigation/ -->


## Overview of the CD-as-a-Service Spinnaker plugin

The Armory Continuous Deployment-as-a-Service Plugin for Spinnaker™ adds new stages to your Armory CD or Spinnaker instance. When you use one of these stages to deploy an app, you can configure how to deploy the stage incrementally by setting percentage thresholds for the deployment. For example, you can deploy the new version of your app to 25% of your target cluster and then wait for a manual judgement or a configurable amount of time. This wait gives you time to assess the impact of your changes. From there, either continue the deployment to the next threshold you set or roll back the deployment.

## Objectives

* Meet the prerequisites specified in the _{{% heading "prereq" %}}_ section.
* [Register your Spinnaker or Armory CD environment](#register-your-environment).
* [Install the CD-as-a-Service Remote Network Agent](#install-the-cd-as-a-service-remote-network-agent).
* [Install the plugin](#install-the-plugin).
* [Use the plugin](#use-the-plugin) to deploy a "Hello World" manifest.

## Plugin compatibility matrix

| Armory CD (Spinnaker) Version | Plugin Version |
|:-------|:-------------------|
| 2.24.x + | (1.24.x)+ | 0.29.x |


## {{% heading "prereq" %}}

**Sign up for CD-as-a-Service**

{{< include "register.md" >}}

### Networking

Your Spinnaker instance and the cluster(s) where you install the CD-as-a-Service Remote Network Agent(s) need specific ports open.

{{< include "req-networking.md" >}}

Additionally, your Armory CD instance needs access to GitHub to download the plugin during installation.

### Target Kubernetes cluster

The Spinnaker plugin does not use Clouddriver to source its accounts. Instead, it uses Remote Network Agents (RNAs) that are deployed in your target Kubernetes clusters. An RNA is a lightweight, scalable service that enables the Spinnaker plugin to interact with your infrastructure. You must install RNAs in every target cluster.

The Helm chart described in [Enable the Armory CD-as-a-Service Remote Network Agent in target Kubernetes clusters](#enable-the-armory-cd-as-a-service-remote-network-agent-in-target-kubernetes-clusters) manages the installation of both of these requirements for you.

## Register your environment

{{< tabpane text=true right=true >}}
{{% tab header="**Environment**:" disabled=true /%}}
{{% tab header="Armory CD" %}}

Register your Armory CD environment so that it can communicate with Armory services. Each environment needs to get registered if you, for example, have production and development environments.

Register your Armory CD [environment](https://docs.armory.io/continuous-deployment/installation/ae-instance-reg/).

{{% /tab %}}
{{% tab header="Spinnaker" %}}

[Create a new CD-as-a-Service credential]({{< ref "/iam/manage-client-creds" >}}) for your Spinnaker instance so it can authenticate with CD-as-a-Service. 

In the CD-as-a-Service Console, go to the **Access Management** > **Client Credentials** screen. Click the **New Credential** button. On the **Create New Client Credential** screen:

   - **Name**: enter a meaningful name for your Spinnaker instance
   - **Select Roles**: select `Deployments Full Access`

Click **Create Credential**. Copy the **Client ID** and **Client Secret** values for use in the _[Install the plugin](#install-the-plugin)_ section.

{{% /tab %}}
{{< /tabpane >}}

## Install the CD-as-a-Service Remote Network Agent

### Create a credential for your RNA

{{< include "client-creds.md" >}}

### Deploy the RNA in your target Kubernetes cluster

{{< include "rna/rna-install-kubectl.md" >}}

### Verify the Agent deployment

Go to the [Agents page in the Configuration UI](https://console.cloud.armory.io/configuration/agents) and verify the connection. If you do not see your cluster, verify that you are in the correct CD-as-a-Service tenant.

> Note that you may see a "No Data message" when first loading the Agent page.

{{< figure src="/media/ui-rna-status.jpg" alt="The Connected Remote Network Agents page shows connected Agents and the following information: Agent Identifier, Agent Version, Connection Time when the connection was established, Last Heartbeat time, Client ID, and IP Address." >}}

If you do not see the RNA for your target deployment cluster, check the logs for the target deployment cluster to see if the RNA is up and running.

You should see messages similar to the following that show your client ID and your account getting registered in Armory CD-as-a-Service:

```
time="2021-07-16T17:41:45Z" level=info msg="registering with uuid: f69daec0-0a32-4ded-b3ed-dc84bc0e93d0"
time="2021-07-16T17:41:45Z" level=info msg="registering with 1 servers"
time="2021-07-16T17:48:30Z" level=info msg="handling registration 01FAR6Y7EDJW1B5G8JQ109D53G"
time="2021-07-16T17:48:30Z" level=info msg="starting agentCreator provider:\"kubernetes\" name:\"account-test\""
```

## Install the plugin

>You can configure Spinnaker secrets as outlined in the [Work with Secrets in Spinnaker](https://docs.armory.io/continuous-deployment/armory-admin/secrets) guide. This means you can set the Client Secret value a secret token instead of the plain text value.

{{< tabpane text=true right=true >}}
{{% tab header="**Method**:" disabled=true /%}}
{{% tab header="Operator" %}}

If you are running Armory CD 2.26.3, `armory.cloud` block goes in a different location. Instead of `spec.spinnakerConfig.spinnaker`, the block needs to go under both `spec.spinnakerConfig.gate` and `spec.spinnakerConfig.orca`. For more information see [Known issues](#known-issues). Additionally there is a `plugins` block that needs to be added.

The installation instructions using the Operator are the same except for where the `armory.cloud` and this `plugins` block go.

In your Kustomize patches directory, create a file named **patch-plugin-deployment.yml** and add the following manifest to it.

```yaml
#patch-plugin-deployment.yml
apiVersion: spinnaker.armory.io/v1alpha2
kind: SpinnakerService
metadata:
  name: spinnaker
  namespace: <namespace>
spec:
  spinnakerConfig:
    profiles:
      gate:
        spinnaker:
          extensibility:
            # This snippet is necessary so that Gate can serve your plugin code to Deck
            deck-proxy:
              enabled: true
              plugins:
                Armory.Deployments:
                  enabled: true
                  version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
            repositories:
              armory-deployment-plugin-releases:
                enabled: true
                url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
      # Global Settings
      spinnaker:
        armory.cloud:
          enabled: true
          iam:
            clientId: <clientId for Spinnaker from earlier>
            clientSecret: <clientSecret for Spinnaker from earlier>
            tokenIssuerUrl: https://auth.cloud.armory.io/oauth/token
          api:
            baseUrl: https://api.cloud.armory.io
        spinnaker:
          extensibility:
            plugins:
              Armory.Deployments:
                enabled: true
                version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
            repositories:
              armory-deployment-plugin-releases:
                url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
```

Then, include the file under the `patchesStrategicMerge` section of your `kustomization` file:

```yaml
bases:
  - spinnaker.yml
patchesStrategicMerge:
  - patches/patch-plugin-deployment.yml
```      

Apply the changes to your Armory CD instance.

```bash
kubectl apply -k <path-to-kustomize-file>.yml
```

{{% /tab %}}
{{% tab header="Halyard" %}}

If you are running Armory CD 2.26.3, `armory.cloud` block needs to go in `gate-local.yml` and `orca-local.yml` instead of `spinnaker-local.yml`. For more information see [Known issues](#known-issues). Other than the change in location, the installation instructions remain the same.

In the `/.hal/default/profiles` directory, add the following configuration to `spinnaker-local.yml`. If the file does not exist, create it and add the configuration.

```yaml
#spinnaker-local.yml
armory.cloud:
  enabled: true
  iam:
    clientId: <clientId for Spinnaker from earlier>
    clientSecret: <clientSecret for Spinnaker from earlier>
    tokenIssuerUrl: https://auth.cloud.armory.io/oauth/token
  api:
    baseUrl: https://api.cloud.armory.io
spinnaker:
  extensibility:
    plugins:
      Armory.Deployments:
        enabled: true
        version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
    repositories:
      armory-deployment-plugin-releases:
        url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
```

In the `/.hal/default/profiles` directory, add the following configuration to `gate-local.yml`. If the file does not exist, create it and add the configuration.

```yaml
#gate-local.yml
spinnaker:
  extensibility:
    # This snippet is necessary so that Gate can serve your plugin code to Deck
    deck-proxy:
      enabled: true
      plugins:
        Armory.Deployments:
          enabled: true
          version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
    repositories:
      armory-deployment-plugin-releases:
        enabled: true
        url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
```

Apply the changes to your Armory CD instance.

```bash
hal deploy apply
```

{{% /tab %}}
{{< /tabpane >}}

### Verify that the plugin is configured

1. Check that all the services are up and running:

   ```bash
   kubectl -n <Armory-CD-namespace> get pods
   ```

2. Navigate to the Armory CD UI.
3. In a new or existing application, create a new pipeline.
4. In this pipeline, select **Add stage** and search for **Kubernetes Progressive**. The stage should appear if the plugin is properly configured.

   {{< figure src="deploy-engine-stage-UI.jpg" alt="The Kubernetes Progressive stage appears in the Type dropdown when you search for it." >}}

5. In the **Basic Settings** section, verify that you can see the target deployment account in the **Account** dropdown.

   {{< figure src="deploy-engine-accounts.png" alt="If the plugin is configured properly, you should see the target deployment account in the Account dropdown." >}}.

## Use the plugin

The plugin provides the following pipeline stages that you can use to deploy your app:

* [Borealis Progressive Deployment YAML](#armory-cd-as-a-service-progressive-deployment-yaml-stage): You create the Armory CD-as-a-Service deployment YAML configuration, so you have access to the full set of options for deploying your app to a single environment.
* [Kubernetes Progressive](#kubernetes-progressive-stage): This is a basic deployment stage with a limited set of options. Blue/green deployment is not supported in Early Access.

### Armory CD-as-a-Service Progressive Deployment YAML stage

{{< alert title="Limitations" color="primary" >}}
* This stage only supports deploying to a single environment.
{{< /alert >}}

This stage uses YAML deployment configuration to deploy your app. The YAML that you create must be in the same format as the [Deployment Config File]({{< ref "reference/deployment/_index.md" >}}) that you would use with the Armory CD-as-a-Service CLI.

You have the following options for adding your Armory CD-as-a-Service deployment YAML configuration:

1. **Text**: You create and store your deployment YAML within Armory CD.
1. **Artifact**: You store your deployment YAML file in source control.

#### {{% heading "prereq" %}}

1. Add the Kubernetes manifest for your app as a pipeline artifact in the Configuration section of your pipeline. Or you can generate it using the 'Bake (Manifest)' stage, as you would for a standard Kubernetes deployment in Armory CD.

1. Prepare your Armory CD-as-a-Service deployment YAML. You can use the [Armory CD-as-a-Service CLI]({{< ref "cli" >}}) to generate a [deployment config file template]({{< ref "deployment/create-deploy-config" >}}). In your deployment YAML `manifests.path` section, you have to specify the file name of the app's Kubernetes manifest artifact, which may vary from the **Display Name** on the **Expected Artifact** screen.

#### Configure the stage

The **Deployment Configuration** section is where you define your Armory CD-as-a-Service progressive deployment and consists of [manifest source](#manifest-source) and [required artifacts to bind](#required-artifacts-to-bind).

##### Manifest source

{{< tabpane text=true right=true >}}
{{% tab header="**Manifest Source**:" disabled=true /%}}
{{% tab header="Text" %}}

1. Choose **Text** for the **Manifest Source**.
1. Paste your deployment file YAML into the **Deployment YAML** text box. For example:

{{< figure src="prog-deploy-yaml.png" alt="Example of a deployment YAML file pasted into the Deployment YAML text box." >}}

{{% /tab %}}
{{% tab header="Artifact" %}}

Before you select **Artifact**, make sure you have added your Armory CD-as-a-Service deployment file as a pipeline artifact.

1. Select **Artifact** as the **Manifest Source**.
1. Select your Armory CD-as-a-Service deployment file from the **Manifest Artifact** drop down list.

{{< figure src="prog-deploy-artifact.png" alt="Example of a deployment YAML file attached as an artifact." >}}

{{% /tab %}}
{{< /tabpane >}}
<br>
<br>

##### Required artifacts to bind

For each manifest you list in the `manifests.path` section of your Armory CD-as-a-Service deployment file, you must bind the artifact to the stage.

For example, if your deployment file specifies:

```yaml
...
manifests:
  - path: manifests/potato-facts.yml
...
```

Then you must bind `potato-facts.yml` as a required artifact:

{{< figure src="req-artifact-to-bind.png" alt="Example of an artifact added to Required Artifacts to Bind" >}}

### Kubernetes Progressive stage

If you have deployed Kubernetes apps before using Armory CD, this page may look familiar. The key difference between a Kubernetes deployment using Armory CD and Armory CD with the Armory CD-as-a-Service Spinnaker Plugin is in the **How to Deploy** section.

The **How to Deploy** section is where you define your progressive deployment and consists of two parts:

**Strategy**

This is the deployment strategy you want to use to deploy your Kubernetes app. As part of the early access program, the **Canary** strategy is available. Canary deployments allow you to roll out changes to a predefined percentage of your cluster and increment from there as you monitor the effects of your changes. If something doesn't look quite right, you can initiate a rollback to a previous known good state.

**Steps**

These settings control how the your Kubernetes deployment behaves as Armory CD-as-a-Service deploys it. You can tune two separate but related characteristics of the deployment:

- **Rollout Ratio**: set the percentage threshold (integer) for how widely an app should get rolled out before pausing.
- **Then wait**: define what triggers the rollout to continue. The trigger can either be a manual approval (**until approved**) or for a set amount of time, either seconds, minutes or hours (integer).

Create a step for each **Rollout Ratio** you want to define. For example, if you want a deployment to pause at 25%, 50%, and 75% of the app rollout, you need to define 3 steps, one for each of those thresholds. The steps have independent **Then wait** behaviors and can be set to all follow the same behavior or different ones.

#### Try out the stage

You can try out the **Kubernetes Progressive** stage using either the `hello-world` sample manifest described below or an artifact that you have. The `hello-world` example deploys NGINX that intentionally takes longer than usual for demonstration purposes.

Perform the following steps:

1. In the Armory CD UI, select an existing app or create a new one.
2. Create a new pipeline.
3. Add a stage to your pipeline with the following attributes:
   - **Type**: select **Kubernetes Progressive**
   - **Stage Name**: provide a descriptive name or use the autogenerated name.
4. In the **Account** field, select the target Kubernetes cluster you want to deploy to. This is a cluster where the Remote Network Agent is installed
5. For **Manifest Source**, ensure that you select your manifest source. If you are using the `hello-world` sample manifest described later, select **Text**.
6. **Using text as the manifest source:**

   In the **Manifest** field, provide your manifest. If you are using the `hello-world` manifest, enter that manifest.

   <details><summary>Show me the <code>hello-world</code> manifest</summary>

   ```yaml
   # A simple nginx deployment with an init container that causes deployment to take longer than usual
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: demo-app
   spec:
     replicas: 10
     selector:
       matchLabels:
         app: demo-app
     template:
       metadata:
         labels:
           app: demo-app
       spec:
         containers:
           - env:
               - name: TEST_ID
                 value: __TEST_ID_VALUE__
             image: 'nginx:1.14.1'
             name: demo-app
             ports:
               - containerPort: 80
                 name: http
                 protocol: TCP
         initContainers:
           - command:
               - sh
               - '-c'
               - sleep 10
             image: 'busybox:stable'
             name: sleep
   ```

   </details>

   **Using an existing artifact**

   Select an existing artifact or define a new one as you would for a standard Kubernetes deployment in Armory CD.

7. In the **How to Deploy** section, configure the **Rollout Ratio** and **Then wait** attributes for the deployment.

   Optionally, add more steps to the deployment to configure the rollout behavior. You do not need to create a step for 100% Rollout Ratio. Armory CD-as-a-Service automatically scales the deployment to 100% after the final step you configure.

8.  Save the pipeline.
9.  Trigger a manual execution of the pipeline.

On the **Pipelines** page of the Armory CD UI, select the pipeline and watch the deployment progress. If you set the **Then wait** behavior of any step to **until approved**, this is where you approve the rollout and allow it to continue. After completing the final step you configured, Armory CD-as-a-Service scales the deployment to 100% of the cluster if needed.

## Known issues and limitations

### Manifest limitations

Armory CD-as-a-Service has the following constraints when deploying a manifest:

- Deploying ReplicaSets is not  supported.
- Deploying Pods is not supported.

### `armory.cloud` block location

In Armory CD 2.26.3, the location of where you put the `armory.cloud` config block is different from other versions. Additionally, there is an additional config block for `spec.spinnakerConfig.profiles.gate.spinnaker.extensibility` that contains information for the plugin named `plugins`.

{{< tabpane text=true right=true >}}
{{% tab header="**Method**:" disabled=true /%}}
{{% tab header="Operator" %}}

Your Kustomize patch file should resemble the following where `armory.cloud` is a child of the `gate` and `orca` blocks instead of a `spinnaker` block:

```yaml
#patch-plugin-deployment.yml
apiVersion: spinnaker.armory.io/v1alpha2
kind: SpinnakerService
metadata:
  name: spinnaker
  namespace: <namespace>
spec:
  spinnakerConfig:
    profiles:
      gate:
        spinnaker:
          extensibility:
            # This snippet is necessary so that Gate can serve your plugin code to Deck
            deck-proxy:
              enabled: true
              plugins:
                Armory.Deployments:
                  enabled: true
                  version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
            plugins:
              Armory.Deployments:
                enabled: true
                version: <Latest-version> # Replace this with the latest version
            repositories:
              armory-deployment-plugin-releases:
                enabled: true
                url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
        # Note how armory.cloud is a child of gate instead of spinnaker
        armory.cloud:
          enabled: true
          iam:
            clientId: <clientId for Spinnaker from earlier>
            clientSecret: <clientSecret for Spinnaker from earlier>
            tokenIssuerUrl: https://auth.cloud.armory.io/oauth/token
          api:
            baseUrl: https://api.cloud.armory.io
      # Note how armory.cloud is a child of orca instead of spinnaker
      orca:
        armory.cloud:
          enabled: true
          iam:
            clientId: <clientId for Spinnaker from earlier>
            clientSecret: <clientSecret for Spinnaker from earlier>
            tokenIssuerUrl: https://auth.cloud.armory.io/oauth/token
          api:
            baseUrl: https://api.cloud.armory.io
        spinnaker:
          extensibility:
            plugins:
              Armory.Deployments:
                enabled: true
                version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
            repositories:
              armory-deployment-plugin-releases:
                url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
```



{{% /tab %}}
{{% tab header="Halyard" %}}

Your `spinnaker-local.yml` file should not have the `armory.cloud` block anymore and only contain the block to install the plugin:

```yaml
#spinnaker-local.yml
spinnaker:
  extensibility:
    plugins:
      Armory.Deployments:
        enabled: true
        version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
    repositories:
      armory-deployment-plugin-releases:
        url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
```

Your `gate-local.yml` file should include the `extensibility` and the `armory.cloud` configurations like the following example:

```yaml
#gate-local.yml
spinnaker:
  extensibility:
    plugins:
      Armory.Deployments:
        enabled: true
        version: <Latest-version> # Replace this with the latest version
    # This snippet is necessary so that Gate can serve your plugin code to Deck
    deck-proxy:
      enabled: true
      plugins:
        Armory.Deployments:
          enabled: true
          version: <Latest-version> # Replace this with the latest version from: https://github.com/armory-plugins/armory-deployment-plugin-releases/releases/
    repositories:
      armory-deployment-plugin-releases:
        enabled: true
        url: https://raw.githubusercontent.com/armory-plugins/armory-deployment-plugin-releases/master/repositories.json
armory.cloud:
  enabled: true
  iam:
    clientId: <clientId for Spinnaker from earlier>
    clientSecret: <clientSecret for Spinnaker from earlier>
    tokenIssuerUrl: https://auth.cloud.armory.io/oauth/token
  api:
    baseUrl: https://api.cloud.armory.io
```

Your `orca-local.yml` file should include the `armory.cloud` configration like the following:

```yaml
#orca-local.yml
armory.cloud:
  enabled: true
  iam:
    clientId: <clientId for Spinnaker from earlier>
    clientSecret: <clientSecret for Spinnaker from earlier>
    tokenIssuerUrl: https://auth.cloud.armory.io/oauth/token
  api:
    baseUrl: https://api.cloud.armory.io
```

{{% /tab %}}
{{< /tabpane >}}

> This product documentation page is Armory confidential information.

## Release notes

You can find the plugin release notes in the [Armory CD-as-a-Service release notes]({{< ref "release-notes/_index.md" >}}).
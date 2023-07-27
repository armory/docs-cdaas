---
title: Configure Advanced Options for Installing a Remote Network Agent in a Production Environment
linktitle: Install - Production
weight: 6
description: >
  Use Helm to configure and install a Remote Network Agent in your production environment. Configure advanced settings like a proxy, a Secrets manager, log output type, Pod attributes, and metrics.
categories: ["Guides"]
tags: [ "Networking", "Remote Network Agent", "CD-as-as-Service Setup"]
---

## Production installation

Armory recommends and supports installing the Remote Network Agent using the `armory/remote-network-agent` Helm chart. Using a `values` file, you can configure advanced options such as:

- Secrets Management outside of Kubernetes (AWS Secrets Manager, AWS S3, Vault Kubernetes Injector)
- Agent Proxy Settings
- Pod Labels
- Pod Annotations
- Pod Env Vars
- Pod Resource Requests / Limits
- Pod DNS Settings 
- Pod Node selection 
- Pod Affinity 
- Pod Tolerations
- Log Configuration
  - output type (JSON vs human-readable text), level, color settings
- Disable Kubernetes cluster mode
- Metrics 


Even if you are not permitted to use Helm in your production environment, Armory recommends customizing your installation in the `values.yml` file. Then you can create Kubernetes manifests using the `helm template` command, which this guide covers in the [Preview the RNA manifests](#preview-the-rna-manifests) section.

## {{% heading "prereq" %}}

* You have installed [Helm](https://helm.sh/docs/intro/quickstart/) v3+.
* You configure advanced options in a `values` file, so you should be familiar with using that file to customize a chart. For more information, see the Helm docs:

  * [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing)
  * [Helm Values Files guide](https://helm.sh/docs/chart_template_guide/values_files/) 

* You have created a namespace for your RNA:  `kubectl create ns armory-rna`. Since you pass the namespace to the `helm` command, you can use a different namespace. This guide assumes you have created an `armory-rna` namespace.

## Where to configure options

You configure options in the `values.yaml` file, which you should download from the [repo](https://github.com/armory-io/remote-network-agent-helm-chart/blob/main/values.yaml).  The file contains explanations and instructions for each config option.

 <details><summary>Show me the values file</summary>
{{< github repo="armory-io/remote-network-agent-helm-chart" file="/values.yaml" lang="yaml" options="" >}}
</details><br>

## Required fields

* `clientId` and `clientSecret`: the Client ID and Client Secret from your Client Credentials; you should encrypt the Client ID and Client Secret as a secret in a supported secrets manager such as [Kubernetes](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/) or [AWS Secrets Manager](https://docs.aws.amazon.com/eks/latest/userguide/manage-secrets.html). 

   For example, to create a Kubernetes secret, execute the following:

   ```bash
   kubectl --namespace armory-rna create secret generic rna-client-credentials --type=string --from-literal=client-secret=<your-client-secret> --from-literal=client-id=<your-client-id>
   ```

   Then you would configure `clientId` and `clientSecret` like this:

   ```yaml
   clientId: encrypted:k8s!n:rna-client-credentials!k:client-id
   clientSecret: encrypted:k8s!n:rna-client-credentials!k:client-secret
   ```

   See the comments in the `values.yaml` file for examples using other secrets managers.

* `agentIdentifier`: the name for your Remote Network Agent

>If you don't configure these in the file, you must pass them on the command line using `--set <key>:<value>`.

## Configure options

### Proxy

Configure your proxy in the `proxy` block. The `values.yaml` file contains detailed comments on allowable values for these fields.

```yaml
proxy:
  enabled: false
  url: <proxy-url>
  nonProxyHosts:
```


### Kubernetes settings

```yaml
kubernetes:
  enableClusterAccountMode: true
  # RBAC permissions granted to the ServiceAccount for the RNA
  clusterRoleRules:
    - apiGroups: [ "*" ]
      resources: [ "*" ]
      verbs: [ "*" ]
  serviceAccount:
    # Annotations to add to the ServiceAccount
    annotations: {}
```

#### Cluster mode

* Enabled
   
  When `enableClusterAccountMode: true`, installation creates a ServiceAccount, ClusterRole, and ClusterRoleBinding. Then installation applies the ServiceAccount with ClusterRoleBinding to the RNA. Lastly, the RNA registers itself as a deployment target within CD-as-a-Service.

* Disabled

  When `enableClusterAccountMode: false`, the RNA only allows you to make network calls to networked resources. You have to configure Kubernetes accounts in the CD-as-a-Service Console to have Kubernetes deployment targets.

#### ServiceAccount permissions

Configure ClusterRole and ServiceAccount in the `kubernetes.clusterRoleRules` and `kubernetes.serviceAccount` blocks.

At a minimum, the RNA needs permissions to create, edit, and delete all `kind` objects that you plan to deploy with CD-as-a-Service, in all namespaces you plan to deploy to. The RNA also requires network access to any monitoring solutions or webhook APIs that you plan to forward through it. 

@TODO add some least privilege use cases and example? or is that out of scope?

See the Kubernetes Documentation's [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) guide for detailed info on configuring permissions.

### Pods


### Metrics

The RNA exposes an endpoint on `:8080/metrics` that can serve Prometheus or OpenMetrics format.

If you have a Prometheus or OpenMetrics scraper installed in your cluster, you can enable the following annotations:

```yaml
 podAnnotations:
   prometheus.io/scrape: "true"
   prometheus.io/path: "/metrics"
   prometheus.io/port: "8080"
   prometheus.io/scheme: "http"
```

### Logging

By default, the RNA logs in human-readable text. However, you can enable structured JSON logging, which is often more appropriate for log aggregation by tools like Splunk and New Relic.

```yaml
log:
  # Can be set to console, console-wide (all the same metadata that gets added to json output) or json
  type: json
  # Disable color output
  disableColor: false
  # debug,info,warn,error
  level: info
```


## Preview the RNA manifests

After you have completed your advanced configuration in the `values.yaml` file, you can use the `helm template` [command](https://helm.sh/docs/helm/helm_template/) to render the Kubernetes manifests.

```bash
helm template armory-rna armory/remote-network-agent --values values.yaml --namespace armory-rna
```



## Install the RNA

1. Set your `kubectl` [context](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-set-context-em-) to connect to the cluster where you want to deploy the RNA:

   ```bash
   kubectl config use-context <NAME>
   ```

1. Install the RNA:

   ```bash
   helm upgrade --install armory-rna armory/remote-network-agent -f <path-to-values.yaml> \
        --namespace <namespace>
   ```

   Replace `<namespace>` with the namespace you created for the RNA.

1. Go to the [Agents page](https://console.cloud.armory.io/configuration/agents) in the CD-as-a-Service Console to verify that your RNA has been installed and is communicating with CD-as-a-Service. If you do not see the RNA, check your cluster logs to see if the RNA is running.


## Use Terraform

Alternately, you can manage the RNA with [Terraform with your Infrastructure as Code (IaC)](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)

```hcl
resource "helm_release" "armory-rna" {
  name            = "armory-rna"
  chart           = "remote-network-agent"
  repository      = "https://armory.jfrog.io/artifactory/charts"
  namespace       = "<namespace>"
  cleanup_on_fail = true
  values = [file("<path-to-values.yaml>")]
}
```

Replace `<namespace>` with the namespace you created for the RNA.

Replace `<path-to-values.yaml>` with the path to your `values.yaml` file.
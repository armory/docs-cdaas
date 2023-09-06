---
title: Install a Remote Network Agent in Production Using Helm
linktitle: Install - Production
weight: 6
description: >
  Use Helm to configure and install a Remote Network Agent in your production environment. Configure advanced settings such as a proxy, a Secrets manager, log output type, Pod attributes, and metrics.
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


## {{% heading "prereq" %}}

* You have installed [Helm](https://helm.sh/docs/intro/quickstart/) v3+.
* You configure advanced options in a `values` file, so you should be familiar with using that file to customize a chart. For more information, see the Helm docs:

  * [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing)
  * [Helm Values Files guide](https://helm.sh/docs/chart_template_guide/values_files/) 

* You have created a namespace for your RNA:  `kubectl create ns armory-rna`. Since you pass the namespace to the `helm` command, you can use a different namespace. This guide assumes you have created an `armory-rna` namespace.

Installation using Helm consists of the following steps:

1. Configure your installation in the  `values.yaml` file, which you should download from the [repo](https://github.com/armory-io/remote-network-agent-helm-chart/blob/main/values.yaml).  

   * [Configure required settings](#configure-required-settngs)
   * [Configure optional settings](#configure-optional-settings)

1. [Generate and preview the manifests](#generate-and-preview-the-manifests)
1. [Install the RNA](#install-the-rna)

<details><summary>Show the values file</summary>
{{< github repo="armory-io/remote-network-agent-helm-chart" file="/values.yaml" lang="yaml" options="" >}}
</details><br>

## Configure required settings

>If you don't configure these in the file, you must pass them on the command line using `--set <key>:<value>`.

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

* `agentIdentifier`: the name of your Remote Network Agent

## Configure optional settings

### Replica count

```yaml
replicaCount: <int>
```

Default: `2` replicas. Change this value to increase the number of replicas.

### Image

The `armory/remote-network-agent` image is in a public Docker registry. If you plan to host the image in a private registry, you should know how to [pull an image from a private registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

```yaml
image:
  repository: armory/remote-network-agent
  pullPolicy: IfNotPresent
  tag: ""

# imagePullSecrets:
#  - name: regcred
imagePullSecrets: []
```

* `image`
  * `repository`: The default is `armory/remote-network-agent`, which is a public Docker image.
  * `pullPolicy`: [Image pull policy](https://kubernetes.io/docs/concepts/containers/images/#image-pull-policy); one of `IfNotPresent`, `Always`, or `Never`.
  * `tag`: Specify a tag only if you want to override the default image tag, which is the chart `appVersion`.
* `imagePullSecrets`: The secret for pulling an image from a private registry. **This field is required only if you are hosting the RNA image in your own private registry**. 

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

See the Kubernetes Documentation's [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) guide for detailed info on configuring permissions.

### Pods

```yaml
podEnvironmentVariables: []
  # - name: FOO
  #   value: bar
podLabels: {}
  # key: value
resources: {}
  # limits:
  #   cpu: 200m
  #   memory: 512Mi
  # requests:
  #   cpu: 100m
  #   memory: 256Mi
priorityClassName: ""
dnsPolicy:
dnsConfig: {}
affinity: {}
nodeSelector: {}
tolerations: []
```

* `podEnvironmentVariables`:  [Environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) to add to the Pods
* `podLabels`: [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) to add to the Pods
* `resources`: Configure Pod requests and limits. See [Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/).
* `priorityClassName`: PriorityClass name. See [Pod Priority and Preemption](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/).
* `dnsPolicy`: Set the Pod's DNS policy. See [Pod's DNS Policy](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy).
* `dnsConfig`: Set the Pod's DNS config. See [Pod's DNS Config](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config).
* `affinity`: Set the Pod's affinities. See [Affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity).
* `nodeSelector`: Set the Pod's `nodeSelector`. See [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/).
* `tolerations`: Set the Pod's tolerations to node taints. See [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/).

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
  type: json
  disableColor: false
  level: info
```

* `type`: log output type; specify one of the following:
  * `console`
  * `console-wide`: all the same metadata that gets added to json output
  * `json`
* `disableColor`: `true|false`; turn off color output 
* `level`: specify one of `debug`, `info`, `warn`, or `error`

## Generate and preview the manifests

After you have completed your advanced configuration in the `values.yaml` file, you can use the `helm template` [command](https://helm.sh/docs/helm/helm_template/) to render the Kubernetes manifests.

```bash
helm template armory-rna armory/remote-network-agent --values values.yaml --namespace armory-rna
```

## Install the RNA

{{< tabpane text=true right=true >}}
{{% tab header="**Tool**:" disabled=true /%}}
{{% tab header="Helm" %}}

```bash
helm upgrade --install armory-rna armory/remote-network-agent -f <path-to-values.yaml> \
    --namespace <namespace>
```

Replace `<namespace>` with the namespace you created for the RNA.
{{< /tab >}}
{{% tab header="Terraform" %}}

You can manage the RNA with [Terraform with your Infrastructure as Code (IaC)](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)

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

* Replace `<namespace>` with the namespace you created for the RNA.
* Replace `<path-to-values.yaml>` with the path to your `values.yaml` file.

{{% /tab %}}
{{< /tabpane >}}

Go to the [Agents page](https://console.cloud.armory.io/configuration/agents) in the CD-as-a-Service Console to verify that your RNA has been installed and is communicating with CD-as-a-Service. If you do not see the RNA, check your cluster logs to see if the RNA is running.

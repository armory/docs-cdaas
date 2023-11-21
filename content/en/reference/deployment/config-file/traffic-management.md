---
title: Traffic Management Config
description: >
  Declare AWS Lambda aliases. Declare Istio or Linkerd traffic management for all or specific Kubernetes targets. Configure Istio settings such as virtual service and destination rule. Configure Linkerd settings like root service, canary service, active service, and traffic split.
---

## Traffic management section

`trafficManagement.`

## AWS Lambda

You declare your AWS Lambda alias per target in this section. CD-as-a-Service uses [aliases](https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html) when routing traffic from the previous version to the latest version of your function.

```yaml
trafficManagement:
  - targets: ["<target-name>"]
    alias:
      - function:  <function-name>
        aliasName: <function-alias>
```

* `targets`: the list of targets using this alias
* `function`: This is the same value as `artifacts.functionName` and `providerOptions.lambda.name`. See {{< linkWithTitle "reference/deployment/config-file/artifacts.md" >}} for details on those sections.
* `aliasName`: The alias name, such as "live-version". Your function's alias must already exist in the AWS Lambda console.

This example declares a traffic split canary strategy. You must declare your function's alias for each deployment target that uses the traffic split strategy.

{{< readfile  file="/includes/code/lambda-traffic-split-snippet.yaml" code="true" lang="yaml" >}}

## Kubernetes

You configure your service mesh per target in this section.

### SMI targets

`trafficManagement.targets.smi`

{{< include "dep-file/tm-smi-config.md" >}}

### Istio targets

`trafficManagment.targets.istio`

See {{< linkWithTitle "traffic-management/istio.md" >}} for a detailed example.

{{< include "dep-file/tm-istio-config.md" >}}

### Kubernetes targets

`trafficManagement.targets.kubernetes`

{{< include "dep-file/tm-k8s-service.md" >}}

---
title: Traffic Management Config
description: >
  Declare Istio or Linkerd traffic management for all or specific Kubernetes targets. Configure Istio settings such as virtual service and destination rule. Configure Linkerd settings like root service, canary service, active service, and traffic split.
---

## Traffic management section

`trafficManagement.`

You configure your service mesh per target in this section. If you omit the `target` entry, CD-as-a-Service applies the config to all targets.

```yaml
trafficManagement:
  - targets: ["<target-name>"]
```

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

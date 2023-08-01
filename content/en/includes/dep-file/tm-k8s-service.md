---
---

```yaml
trafficManagement:
  - targets: ["<target1>", "<target2>"]
    kubernetes:
      - activeService: "<activeServiceName>"
        previewService: "<previewServiceName>"
```

* `targets`: Comma-delimited list of deployment targets.

* `kubernetes.activeService`: (Required if configuring a `kubernetes` block)(Blue/Green) the name of a Kubernetes `Service`. Its service selector should target a Kubernetes `Deployment` resource in your deployment's manifests. The `Service` should exist at the time of deployment.

* `kubernetes.previewService`: (Optional)(Blue/Green) the name of a Kubernetes `Service`. Its service selector should target a Kubernetes `Deployment` resource in your deployment's manifests. The `Service` should exist at the time of deployment.
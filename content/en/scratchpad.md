---
title: Scratchpad
weight: 999
draft: true
---

## codeblock in tabpane

{{< include "cli/install-cli-tabpane.md" >}}

## bash

```bash
kubectl create ns armory-rna; 
kubectl --namespace armory-rna create secret generic rna-client-credentials \
--type=string \
--from-literal=client-secret="<client-secret>" \
--from-literal=client-id="<client-id>";
kubectl apply -f "https://api.cloud.armory.io/kubernetes/agent/manifest?agentIdentifier=sample-cluster&namespace=armory-rna"
```

## yaml

yaml with lines highlighted


{{< highlight yaml "linenos=table, hl_lines=5 10 22-27" >}}
version: v1
kind: kubernetes
application: potato-facts
targets:
  staging:
    account: my-cdaas-cluster
    namespace: potato-facts-staging
    strategy: rolling
  prod:
    account: my-cdaas-cluster
    namespace: potato-facts-prod
    strategy: rolling
    constraints:
      dependsOn: ["staging"]
manifests:
  - path: manifests/potato-facts-v1.yaml
  - path: manifests/potato-facts-service.yaml
  - path: manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: manifests/prod-namespace.yaml
    targets: ["prod"]
strategies:
  rolling:
    canary:
      steps:
        - setWeight:
            weight: 100
{{< /highlight >}}

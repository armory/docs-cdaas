---
title: Manifests Config
weight: 4
description: >
  Declare the path to the Kubernetes manifests to use for your deployment. You can also specify manifests per deployment target.
---

## `manifests.`

{{< prism lang="yaml"  line-numbers="true" >}}
manifests:
  # Directory containing manifests
  - path: /path/to/manifest/directory
    targets: ["<targetName1>", "<targetName2>"]
  # Specific manifest file
  - path: /path/to/specific/manifest.yaml
    targets: ["<targetName3>", "<targetName4>"]
{{< /prism >}}  

### `manifests.path`

The path to a manifest file that you want to deploy or the directory where your manifests are stored. If you specify a directory, such as `/deployments/manifests/configmaps`, Armory CD-as-a-Service reads all the YAML files in the directory and deploys the manifests to the target you specified in `targets`.

### `manifests.path.targets`

(Optional). If you omit this option, the manifests are deployed to all targets listed in the deployment file. A comma-separated list of deployment targets that you want to deploy the manifests to. Make sure to enclose each target in quotes. Use the name you defined in `targets.<targetName>` to refer to a deployment target.

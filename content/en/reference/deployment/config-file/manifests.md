---
title: Manifests Config
description: >
  Declare the path to the Kubernetes manifests to use for your deployment. You can also specify manifests per deployment target.
---

## Manifests section

`manifests.`

```yaml
manifests:
  - path:
    targets:
```

## Path

`manifests.path`

Required

The path to a manifest(s) that you want to deploy. You have the following options for specifying the path:

* Path to a directory

  The path is relative to the deployment config file. When you specify a directory, CD-as-a-Service reads all the YAML files in the directory and deploys the manifests to the target you specified in `targets`. 

  ```yaml
  manifests:
    - path: deployments/manifests/configmaps
  ```

* Path to a specific local file

  The path is relative to the deployment config file. If your directory is at root and your manifests are in a "manifests" folder, your config is:
  
  ```yaml
  manifests:
    - path: manifests/sample-app.yml
    - path: manifests/sample-app-namespace-prod.yml
  ```

* URL to a specific file

  In this example, you store your manifests in GitHub. 
  * Org: "my-company"
  * Repo: "my-app"
  * Manifests location: "manifests" directory

  ```yaml
  manifests:
    - path: https://raw.githubusercontent.com/my-company/my-app/main/manifests/potato-facts-v1.yaml
    - path: https://raw.githubusercontent.com/my-company/my-app/main/manifests/potato-facts-service.yaml
  ```

### Targets

`manifests.path.targets`

```yaml
manifests:
  - path: /path/to/manifest
    targets: ["<targetName1>", "<targetName2>"]
```

Optional

A comma-separated list of deployment targets that you want to deploy the manifests to. If you omit this option, CD-as-a-Service deploys the manifests to all targets listed in the deployment file. Make sure to enclose each target in quotes. Use the name you defined in `targets.<targetName>` to refer to a deployment target.

## Example

```yaml
manifests:
  - path: manifests/potato-facts.yaml
  - path: manifests/potato-facts-service.yaml
  - path: manifests/dev-namespace.yaml
    targets: ["dev"]
  - path: manifests/staging-namespace.yaml
    targets: ["staging"]
  - path: manifests/infosec-namespace.yaml
    targets: ["infosec"]
  - path: manifests/prod-namespace.yaml
    targets: ["prod"]
```
